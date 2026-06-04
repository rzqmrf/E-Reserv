<?php

use App\Http\Controllers\AuthController;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Route;

// ── Web Pages ─────────────────────────────────────
Route::get('/', fn() => view('home'))->name('home');
Route::get('/about', fn() => view('about'));
Route::get('/contact', fn() => view('contact'));
Route::get('/features', fn() => view('features'));

// ── Admin Pages ───────────────────────────────────
Route::middleware(['auth', 'role:admin'])->prefix('admin')->group(function () {
    Route::get('/', fn() => view('admin.dashboard'))->name('admin.dashboard');
    Route::get('/analytics', fn() => view('admin.analytics'));
    Route::get('/fields', fn() => view('admin.fields'));
    Route::get('/schedules', fn() => view('admin.schedules'));
    Route::get('/bookings', fn() => view('admin.bookings'));
    Route::get('/payments', fn() => view('admin.payments'));
    Route::get('/slots', fn() => view('admin.slots'));
    Route::get('/users', fn() => view('admin.users'))->name('admin.users');
});


Route::get('login', [AuthController::class, 'showLogin'])->name('login'); // Menampilkan form
Route::post('login', [AuthController::class, 'login'])->name('login.process'); // Proses submit
Route::get('register', fn() => view('auth.Register'))->name('register'); // Menampilkan form daftar
Route::post('register', [AuthController::class, 'register'])->name('register.process'); // Proses daftar

Route::middleware('auth')->group(function () {

    // Proses Logout
    Route::post('logout', function () {
        Auth::logout();
        request()->session()->invalidate();
        request()->session()->regenerateToken();
        return redirect()->route('login');
    })->name('logout');

    // Central Dashboard (Logika Pengalihan)
    Route::get('/dashboard', function () {
        if (Auth::user()->role === 'admin') {
            return redirect()->route('admin.dashboard');
        }
        return redirect()->route('user.home');
    });


    // KHUSUS USER BIASA
    Route::middleware('role:user')->group(function () {
        Route::get('/home', function() {
            $lapangans = \App\Models\Field::where('status', 'available')->latest()->take(3)->get();
            return view('Home.Home', compact('lapangans'));
        })->name('user.home');

        Route::get('/lapangan', function() {
            $lapangans = \App\Models\Field::where('status', 'available')->get();
            return view('Home.Lapangan', compact('lapangans'));
        })->name('lapangan.index');

        Route::get('/status', function() {
            $bookings = \App\Models\Booking::where('user_id', Auth::id())->with('field')->latest()->get();
            return view('Home.Status', compact('bookings'));
        })->name('status.index');

        Route::get('/profile', function() {
            return view('Home.Profile');
        })->name('profile.index');

        Route::get('/lapangan/{id}/slot', function($id) {
            $field = \App\Models\Field::findOrFail($id);
            $slots = \App\Models\Slot::where('field_id', $id)
                ->where('date', '>=', now()->toDateString())
                ->orderBy('date')
                ->orderBy('start_time')
                ->get();

            // Tambahkan dynamic attribute untuk JSON serialization
            $slots->each(function($slot) {
                $slot->remaining_capacity = $slot->remaining_capacity;
                $slot->has_host = \App\Models\Booking::where('slot_id', $slot->id)
                    ->whereIn('status', ['pending', 'approved'])
                    ->exists();
                // Ambil info nama host jika ada
                if ($slot->has_host) {
                    $hostBooking = \App\Models\Booking::where('slot_id', $slot->id)
                        ->whereIn('status', ['pending', 'approved'])
                        ->with('user')
                        ->first();
                    $slot->host_name = $hostBooking && $hostBooking->user ? $hostBooking->user->name : null;
                    $slot->host_phone = $hostBooking && $hostBooking->user ? $hostBooking->user->phone : null;
                } else {
                    $slot->host_name = null;
                    $slot->host_phone = null;
                }
            });

            return view('Home.Slot', compact('field', 'slots'));
        })->name('lapangan.slot');
    });
});
