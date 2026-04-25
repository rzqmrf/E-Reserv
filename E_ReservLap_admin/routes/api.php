<?php

use App\Http\Controllers\Api\BookingController;
use App\Http\Controllers\Api\FieldController;
use App\Http\Controllers\Api\PaymentController;
use App\Http\Controllers\Api\ScheduleController;
use App\Http\Controllers\Api\SlotController;
use App\Http\Controllers\Api\UserController;
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

// ── Custom Routes ─────────────────────────────────
Route::get('fields/{fieldId}/slots', [SlotController::class, 'byFieldAndDate']);
Route::post('slots/generate', [SlotController::class, 'generate']);

Route::get('fields/{fieldId}/schedules', [ScheduleController::class, 'byField']);
Route::get('users/{userId}/bookings', [BookingController::class, 'byUser']);

// ── Midtrans Webhook ──────────────────────────────
Route::post('midtrans/webhook', [PaymentController::class, 'webhook']);

// ── Payments (legacy) ────────────────────────────
Route::post('/payments/store', [PaymentController::class, 'store']);
Route::post('/payments/webhook', [PaymentController::class, 'webhook']);
Route::get('/payments', [PaymentController::class, 'index']);


// untuk api auth
Route::post('/login', [AuthController::class, 'apilogin']);
Route::post('/register', [AuthController::class, 'apiregister']);

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/user', function (Request $request) {
        return response()->json(['data' => $request->user()]);
    });
});
