<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Payment;
use App\Models\Booking;
use Illuminate\Http\Request;
use Midtrans\Config;
use Midtrans\Snap;
use Midtrans\Notification;

class PaymentController extends Controller
{
    public function __construct()
    {
        Config::$serverKey    = config('midtrans.server_key');
        Config::$clientKey    = config('midtrans.client_key');
        Config::$isProduction = config('midtrans.is_production');
        Config::$isSanitized  = config('midtrans.is_sanitized');
        Config::$is3ds        = config('midtrans.is_3ds');
    }

    // midtrans atau manual
    public function store(Request $request)
    {
        $request->validate([
            'booking_id' => 'required|exists:bookings,id',
            'method'     => 'nullable|string',
        ]);

        $booking = Booking::with(['user', 'field'])->findOrFail($request->booking_id);
        $method = $request->input('method', 'midtrans');

        // buat atau get payment
        $payment = Payment::updateOrCreate(
            ['booking_id' => $booking->id],
            [
                'amount' => $booking->total_price,
                'method' => $method,
                'status' => 'unpaid',
            ]
        );

        $snapToken = null;

        // snap token
        if ($method === 'midtrans') {
            // Parameter Midtrans
            $params = [
                'transaction_details' => [
                    'order_id'     => $booking->booking_code . '-' . time(), // timestamp unique
                    'gross_amount' => (int) $booking->total_price,
                ],
                'customer_details' => [
                    'first_name' => $booking->user->name,
                    'email'      => $booking->user->email,
                    'phone'      => $booking->user->phone ?? '',
                ],
                'item_details' => [
                    [
                        'id'       => $booking->field->id,
                        'price'    => (int) $booking->total_price, // include durasi langsung gross amount
                        'quantity' => 1, 
                        'name'     => $booking->field->name,
                    ],
                ],
            ];

            try {
                $snapToken = Snap::getSnapToken($params);
                $payment->update(['snap_token' => $snapToken]);
            } catch (\Exception $e) {
                // Log error or handle it
            }
        }

        return response()->json([
            'snap_token' => $snapToken,
            'payment'    => $payment,
        ]);
    }


    // Webhook dari Midtrans atau Bypass Lokal → otomatis update status
    public function webhook(Request $request)
    {
        // Cek input order_id dari request data body dulu jikalau kiriman bypass lokal
        $orderId = $request->input('order_id');

        // Jikalau data kosong (berarti ini webhook asli Midtrans SDK), ambil dari Notification object bawaan
        if (empty($orderId)) {
            $notification = new Notification();
            $orderId           = $notification->order_id;
            $transactionStatus = $notification->transaction_status;
        } else {
            // Jikalau input order_id ada, berarti kiriman bypass dari Flutter
            $transactionStatus = $request->input('transaction_status');
        }

        // POTONG BUNTUT TIMESTAMP: Jikalau order_id mengandung tanda '-', potong dan ambil kode depannya aja
        if (str_contains($orderId, '-')) {
            $orderId = explode('-', $orderId)[0];
        }

        // Cari booking berdasarkan booking_code asli yang udah bersih
        $booking = Booking::where('booking_code', $orderId)->first();
        
        if (!$booking) {
            return response()->json(['message' => 'Kode booking ' . $orderId . ' tidak ditemukan di DB'], 404);
        }

        $payment = Payment::where('booking_id', $booking->id)->firstOrFail();

        if ($transactionStatus == 'capture' || $transactionStatus == 'settlement') {
            $payment->update(['status' => 'paid', 'paid_at' => now()]);
            $booking->update(['status' => 'approved']);
        } elseif (in_array($transactionStatus, ['cancel', 'deny', 'expire'])) {
            $payment->update(['status' => 'failed']);
            $booking->update(['status' => 'rejected']);
        } elseif ($transactionStatus == 'pending') {
            $payment->update(['status' => 'unpaid']);
            $booking->update(['status' => 'pending']);
        }

        return response()->json(['message' => 'Webhook berhasil diproses, status DB terupdate!']);
    }

    // Lihat semua payment (untuk dashboard admin)
    public function index()
    {
        return response()->json(
            Payment::with(['booking.user', 'booking.field'])->latest()->get()
        );
    }

    // Lihat detail payment
    public function show($id)
    {
        $payment = Payment::with(['booking.user', 'booking.field'])->findOrFail($id);
        return response()->json($payment);
    }

    public function getSnapToken(Request $request)
    {
        return $this->store($request);
    } 
}