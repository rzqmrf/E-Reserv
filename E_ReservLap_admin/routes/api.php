<?php

use App\Http\Controllers\Api\BookingController;
use App\Http\Controllers\Api\FieldController;
use App\Http\Controllers\Api\PaymentController;
use App\Http\Controllers\Api\ScheduleController;
use App\Http\Controllers\Api\SlotController;
use App\Http\Controllers\Api\UserController;
use App\Http\Controllers\Api\AnalyticsController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;

// ── API Resources ─────────────────────────────────
Route::apiResource('users', UserController::class);
Route::apiResource('fields', FieldController::class);
Route::apiResource('schedules', ScheduleController::class);
Route::apiResource('bookings', BookingController::class);
Route::apiResource('payments', PaymentController::class);
Route::apiResource('slots', SlotController::class);

// ── Analytics AI Routes ─────────────────────────────
Route::prefix('analytics')->group(function () {
    Route::get('/summary',            [AnalyticsController::class, 'summary']);
    Route::get('/daily-revenue',      [AnalyticsController::class, 'dailyRevenue']);
    Route::get('/monthly-revenue',    [AnalyticsController::class, 'monthlyRevenue']);
    Route::get('/field-performance',  [AnalyticsController::class, 'fieldPerformance']);
    Route::get('/booking-status',     [AnalyticsController::class, 'bookingStatus']);
    Route::get('/neural-network-data',[AnalyticsController::class, 'neuralNetworkData']);
    Route::get('/python-prediction',  [AnalyticsController::class, 'pythonPrediction']);
    Route::get('/ai-status',          [AnalyticsController::class, 'aiStatus']);
    Route::get('/peak-hours',         [AnalyticsController::class, 'peakHours']);
});

// ── Custom Routes ─────────────────────────────────
Route::get('fields/{fieldId}/slots', [SlotController::class, 'byFieldAndDate']);
Route::post('slots/generate', [SlotController::class, 'generate']);

Route::get('fields/{fieldId}/schedules', [ScheduleController::class, 'byField']);
Route::get('users/{userId}/bookings', [BookingController::class, 'byUser']);

// ── Midtrans Webhook ──────────────────────────────
Route::post('midtrans/webhook', [PaymentController::class, 'webhook']);

// ── Payments (legacy) ────────────────────────────
Route::post('/payments/snap-token', [PaymentController::class, 'getSnapToken']);
Route::post('/payments/store', [PaymentController::class, 'store']);
Route::post('/payments/webhook', [PaymentController::class, 'webhook']);
Route::get('/payments', [PaymentController::class, 'index']);


// untuk api auth
Route::post('/login', [AuthController::class, 'apilogin']);
Route::post('/register', [AuthController::class, 'apiregister']);
Route::post('/forgot-password', [AuthController::class, 'forgotPassword']);

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/user', function (Request $request) {
        return response()->json(['data' => $request->user()]);
    });
});

// Route to serve storage files with CORS headers for Flutter Web
Route::get('/storage/{path}', function ($path) {
    $path = str_replace('..', '', $path);
    $fullPath = storage_path('app/public/' . $path);
    if (!file_exists($fullPath) || is_dir($fullPath)) {
        abort(404);
    }
    return response()->file($fullPath);
})->where('path', '.*');
