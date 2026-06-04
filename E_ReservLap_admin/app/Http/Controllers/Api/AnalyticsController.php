<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Booking;
use App\Models\Payment;
use App\Models\Field;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Http;
use Carbon\Carbon;

class AnalyticsController extends Controller
{
    /**
     * Ringkasan statistik keuangan utama
     */
    public function summary()
    {
        $totalRevenue     = Payment::where('status', 'paid')->sum('amount');
        $monthRevenue     = Payment::where('status', 'paid')
                            ->whereMonth('paid_at', now()->month)
                            ->whereYear('paid_at', now()->year)
                            ->sum('amount');
        $lastMonthRevenue = Payment::where('status', 'paid')
                            ->whereMonth('paid_at', now()->subMonth()->month)
                            ->whereYear('paid_at', now()->subMonth()->year)
                            ->sum('amount');

        $totalBookings  = Booking::count();
        $paidPayments   = Payment::where('status', 'paid')->count();
        $pendingPayments = Payment::where('status', 'unpaid')->count();
        $failedPayments  = Payment::where('status', 'failed')->count();

        $growth = $lastMonthRevenue > 0
            ? round((($monthRevenue - $lastMonthRevenue) / $lastMonthRevenue) * 100, 1)
            : ($monthRevenue > 0 ? 100 : 0);

        return response()->json([
            'total_revenue'     => $totalRevenue,
            'month_revenue'     => $monthRevenue,
            'last_month_revenue'=> $lastMonthRevenue,
            'revenue_growth'    => $growth,
            'total_bookings'    => $totalBookings,
            'paid_payments'     => $paidPayments,
            'pending_payments'  => $pendingPayments,
            'failed_payments'   => $failedPayments,
            'avg_transaction'   => $paidPayments > 0 ? round($totalRevenue / $paidPayments) : 0,
            'total_users'       => User::count(),
            'total_fields'      => Field::count(),
        ]);
    }

    /**
     * Pendapatan harian untuk 30 hari terakhir
     */
    public function dailyRevenue()
    {
        $start = now()->subDays(29)->startOfDay();
        $data  = [];

        for ($i = 0; $i < 30; $i++) {
            $date = Carbon::parse($start)->addDays($i);
            $revenue = Payment::where('status', 'paid')
                ->whereDate('paid_at', $date->toDateString())
                ->sum('amount');
            $bookings = Booking::whereDate('date', $date->toDateString())->count();

            $data[] = [
                'date'     => $date->format('d M'),
                'revenue'  => (float) $revenue,
                'bookings' => (int) $bookings,
            ];
        }

        return response()->json($data);
    }

    /**
     * Pendapatan bulanan untuk 12 bulan terakhir
     */
    public function monthlyRevenue()
    {
        $data = [];
        for ($i = 11; $i >= 0; $i--) {
            $date  = now()->subMonths($i);
            $revenue = Payment::where('status', 'paid')
                ->whereYear('paid_at', $date->year)
                ->whereMonth('paid_at', $date->month)
                ->sum('amount');
            $bookings = Booking::whereYear('date', $date->year)
                ->whereMonth('date', $date->month)
                ->count();

            $data[] = [
                'month'    => $date->format('M Y'),
                'revenue'  => (float) $revenue,
                'bookings' => (int) $bookings,
            ];
        }
        return response()->json($data);
    }

    /**
     * Performa per lapangan
     */
    public function fieldPerformance()
    {
        $fields = Field::withCount('bookings')
            ->get()
            ->map(function ($field) {
                $revenue = Payment::where('status', 'paid')
                    ->whereHas('booking', fn($q) => $q->where('field_id', $field->id))
                    ->sum('amount');
                return [
                    'id'        => $field->id,
                    'name'      => $field->name,
                    'bookings'  => $field->bookings_count,
                    'revenue'   => (float) $revenue,
                    'status'    => $field->status,
                ];
            });

        return response()->json($fields);
    }

    /**
     * Distribusi status booking
     */
    public function bookingStatus()
    {
        $statuses = Booking::select('status', DB::raw('count(*) as count'))
            ->groupBy('status')
            ->get();

        return response()->json($statuses);
    }

    /**
     * Data untuk prediksi Neural Network — pendapatan harian 60 hari
     * (sebagai dataset training & prediksi)
     */
    public function neuralNetworkData()
    {
        return response()->json($this->buildNeuralNetworkData());
    }

    public function pythonPrediction()
    {
        $history = $this->buildNeuralNetworkData();

        try {
            $response = Http::timeout(10)->post(
                rtrim(config('services.ai.url'), '/') . '/predict',
                ['history' => $history]
            );

            if ($response->successful()) {
                return response()->json($response->json());
            }
        } catch (\Throwable $e) {
            // Python service is required for AI prediction.
        }

        return response()->json([
            'message' => 'Python AI service belum aktif. Jalankan service di ' . config('services.ai.url') . '.',
            'source' => 'python_ai_service',
        ], 503);
    }

    public function aiStatus()
    {
        try {
            $response = Http::timeout(3)->get(rtrim(config('services.ai.url'), '/') . '/health');

            if ($response->successful()) {
                return response()->json([
                    'online' => true,
                    'source' => 'python_ai_service',
                    'service_url' => config('services.ai.url'),
                    'detail' => $response->json(),
                ]);
            }
        } catch (\Throwable $e) {
            // The UI will show that Python AI is offline.
        }

        return response()->json([
            'online' => false,
            'source' => 'python_ai_service',
            'service_url' => config('services.ai.url'),
            'detail' => [
                'status' => 'offline',
                'model' => 'Python AI Service',
            ],
        ]);
    }

    private function buildNeuralNetworkData(): array
    {
        $data = [];
        for ($i = 59; $i >= 0; $i--) {
            $date    = now()->subDays($i);
            $revenue = Payment::where('status', 'paid')
                ->whereDate('paid_at', $date->toDateString())
                ->sum('amount');
            $bookings = Booking::whereDate('date', $date->toDateString())->count();

            $data[] = [
                'day'      => 60 - $i,
                'date'     => $date->format('d M'),
                'revenue'  => (float) $revenue,
                'bookings' => (int) $bookings,
                'dow'      => (int) $date->dayOfWeek, // day of week
                'dom'      => (int) $date->day,       // day of month
            ];
        }

        return $data;
    }

    /**
     * Jam tersibuk berdasarkan booking
     */
    public function peakHours()
    {
        $data = Booking::select(
                DB::raw("HOUR(start_time) as hour"),
                DB::raw('COUNT(*) as count')
            )
            ->groupBy(DB::raw("HOUR(start_time)"))
            ->orderBy('hour')
            ->get();

        return response()->json($data);
    }
}
