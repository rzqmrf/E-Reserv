@extends('layouts.user')

@section('styles')
<style>
    .header-field {
        background: var(--white);
        padding: 20px;
        display: flex;
        align-items: center;
        gap: 15px;
        box-shadow: 0 2px 10px rgba(0,0,0,0.02);
    }

    .back-btn {
        width: 35px; height: 35px;
        display: flex; align-items: center; justify-content: center;
        border-radius: 10px;
        background: #f7fafc;
        color: var(--text-dark);
        text-decoration: none;
    }

    .header-field h2 { font-size: 18px; font-weight: 700; }

    /* Date Selection */
    .date-selection {
        padding: 20px;
        overflow-x: auto;
        display: flex;
        gap: 12px;
        margin-bottom: 10px;
    }

    .date-selection::-webkit-scrollbar { display: none; }

    .date-card {
        min-width: 65px;
        padding: 12px;
        background: var(--white);
        border-radius: 15px;
        text-align: center;
        box-shadow: var(--shadow);
        border: 2px solid transparent;
        cursor: pointer;
        transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    }

    .date-card.active {
        border-color: var(--primary);
        background: var(--primary-light);
        transform: translateY(-2px);
    }

    .date-card span:first-child {
        display: block;
        font-size: 10px;
        color: var(--text-gray);
        margin-bottom: 5px;
        text-transform: uppercase;
    }

    .date-card span:last-child {
        font-size: 16px;
        font-weight: 700;
    }

    /* Slots Grid */
    .slot-grid {
        padding: 0 20px;
        display: grid;
        grid-template-columns: repeat(3, 1fr);
        gap: 12px;
        margin-bottom: 120px;
    }

    @media (max-width: 576px) {
        .slot-grid {
            grid-template-columns: repeat(2, 1fr);
        }
    }

    .slot-card {
        background: var(--white);
        padding: 15px;
        border-radius: 15px;
        display: flex;
        flex-direction: column;
        justify-content: center;
        align-items: center;
        box-shadow: var(--shadow);
        border: 1.5px solid var(--border);
        cursor: pointer;
        transition: all 0.25s ease;
        text-align: center;
        gap: 4px;
    }

    .slot-time { font-weight: 700; font-size: 14px; color: var(--text-dark); }
    
    .slot-status { font-size: 11px; font-weight: 700; display: block; }
    .slot-count { font-size: 10px; color: var(--text-gray); }

    .slot-card.available { border-left: 4px solid #38B2AC; }
    .slot-card.full { border-left: 4px solid #F56565; opacity: 0.55; cursor: not-allowed; }
    .slot-card.selected { border-color: var(--primary); background: var(--primary-light); box-shadow: 0 8px 20px rgba(0, 136, 255, 0.12); transform: translateY(-2px); }

    /* Bottom Slide-up Bar */
    .booking-bar {
        position: fixed;
        bottom: 0;
        left: 0;
        right: 0;
        background: var(--white);
        box-shadow: 0 -10px 30px rgba(0,0,0,0.08);
        border-top-left-radius: 28px;
        border-top-right-radius: 28px;
        padding: 20px 24px 30px;
        z-index: 990;
        display: flex;
        justify-content: space-between;
        align-items: center;
        transform: translateY(100%);
        transition: transform 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        max-width: 1200px;
        margin: 0 auto;
    }

    .booking-bar.show {
        transform: translateY(0);
    }

    @media (max-width: 768px) {
        .booking-bar {
            bottom: 60px; /* Above mobile navigation bar */
            flex-direction: column;
            gap: 15px;
            padding: 16px 20px 20px;
        }
        .booking-bar-info {
            width: 100%;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .booking-bar-btn {
            width: 100%;
        }
    }

    .info-start-title { font-size: 14px; font-weight: 800; color: var(--text-dark); }
    .info-capacity-desc { font-size: 12px; color: var(--text-gray); margin-top: 2px; }
    .info-host-desc { font-size: 11px; color: var(--primary); font-weight: 700; margin-top: 2px; }

    .price-value-container { text-align: right; }
    .price-value { font-size: 18px; font-weight: 800; color: var(--primary); }
    .price-lbl { font-size: 10px; color: var(--text-gray); }

    .btn-main-booking {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        gap: 8px;
        background: var(--primary);
        color: var(--white);
        padding: 12px 28px;
        border-radius: 14px;
        font-weight: 700;
        font-size: 14px;
        border: none;
        cursor: pointer;
        text-decoration: none;
        box-shadow: 0 6px 18px rgba(0,136,255,0.25);
        transition: all 0.25s ease;
    }
    .btn-main-booking:hover {
        background: #0074db;
        transform: translateY(-1px);
    }
    .btn-main-booking:active {
        transform: scale(0.98);
    }

    /* Checkout Modal Overlay */
    .modal-overlay {
        position: fixed;
        top: 0; left: 0; right: 0; bottom: 0;
        background: rgba(0,0,0,0.55);
        backdrop-filter: blur(4px);
        display: flex;
        align-items: center;
        justify-content: center;
        z-index: 1050;
        opacity: 0;
        pointer-events: none;
        transition: opacity 0.3s ease;
    }
    .modal-overlay.show {
        opacity: 1;
        pointer-events: auto;
    }

    .checkout-modal {
        background: var(--white);
        width: 100%;
        max-width: 500px;
        max-height: 90vh;
        overflow-y: auto;
        border-radius: 28px;
        box-shadow: 0 20px 40px rgba(0,0,0,0.15);
        padding: 24px;
        transform: scale(0.9);
        transition: transform 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    }
    .modal-overlay.show .checkout-modal {
        transform: scale(1);
    }

    .modal-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 20px;
    }
    .modal-header h3 { font-size: 18px; font-weight: 800; }
    .close-modal-btn {
        background: #f7fafc;
        border: none;
        width: 32px; height: 32px;
        border-radius: 50%;
        cursor: pointer;
        display: flex; align-items: center; justify-content: center;
        color: var(--text-gray);
        font-weight: bold;
    }

    /* Section Step Labels */
    .step-label-row {
        display: flex;
        align-items: center;
        gap: 8px;
        margin-bottom: 12px;
        margin-top: 16px;
    }
    .step-number {
        width: 22px; height: 22px;
        background: var(--primary-light);
        color: var(--primary);
        border-radius: 50%;
        display: flex; align-items: center; justify-content: center;
        font-size: 11px; font-weight: 800;
    }
    .step-text { font-size: 14px; font-weight: 700; color: var(--text-dark); }

    /* Form Fields Styling */
    .checkout-card {
        background: var(--white);
        border: 1px solid var(--border);
        border-radius: 18px;
        padding: 16px;
        margin-bottom: 16px;
        box-shadow: var(--shadow);
    }

    .form-group {
        display: flex;
        flex-direction: column;
        gap: 6px;
        margin-bottom: 12px;
    }
    .form-group:last-child { margin-bottom: 0; }
    .form-label { font-size: 12px; font-weight: 700; color: var(--text-dark); }
    .form-input-wrapper {
        position: relative;
        display: flex;
        align-items: center;
    }
    .form-input-wrapper i {
        position: absolute;
        left: 14px;
        color: var(--text-gray);
        font-size: 14px;
    }
    .form-input-field {
        width: 100%;
        padding: 12px 14px 12px 38px;
        border-radius: 12px;
        border: 1.5px solid var(--border);
        outline: none;
        font-family: inherit;
        font-size: 13px;
        transition: border-color 0.25s;
    }
    .form-input-field:focus {
        border-color: var(--primary);
    }

    /* Counter Control Row */
    .counter-row {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 8px 0;
    }
    .counter-label {
        font-size: 13px;
        font-weight: 700;
        color: var(--text-dark);
    }
    .counter-control {
        display: flex;
        align-items: center;
        gap: 12px;
    }
    .btn-counter {
        width: 32px; height: 32px;
        border-radius: 8px;
        border: 1.5px solid var(--border);
        background: var(--white);
        cursor: pointer;
        display: flex; align-items: center; justify-content: center;
        font-size: 16px; font-weight: bold;
        color: var(--text-dark);
        transition: all 0.2s;
    }
    .btn-counter.enabled {
        background: var(--primary-light);
        border-color: rgba(0, 136, 255, 0.2);
        color: var(--primary);
    }
    .counter-val { font-size: 14px; font-weight: 800; min-width: 40px; text-align: center; }

    /* Private Toggle */
    .toggle-row {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding-top: 8px;
    }
    .toggle-label-container {
        display: flex;
        flex-direction: column;
        gap: 2px;
    }
    .toggle-title { font-size: 13px; font-weight: 700; }
    .toggle-subtitle { font-size: 10px; color: var(--text-gray); }

    .switch {
        position: relative;
        display: inline-block;
        width: 46px;
        height: 24px;
    }
    .switch input { display: none; }
    .switch-slider {
        position: absolute;
        cursor: pointer;
        top: 0; left: 0; right: 0; bottom: 0;
        background-color: #ccc;
        transition: .4s;
        border-radius: 34px;
    }
    .switch-slider:before {
        position: absolute;
        content: "";
        height: 18px;
        width: 18px;
        left: 3px;
        bottom: 3px;
        background-color: white;
        transition: .4s;
        border-radius: 50%;
    }
    input:checked + .switch-slider {
        background-color: var(--primary);
    }
    input:checked + .switch-slider:before {
        transform: translateX(22px);
    }

    /* Info Alert Banner */
    .info-banner {
        background: var(--primary-light);
        border: 1px solid rgba(0, 136, 255, 0.15);
        border-radius: 16px;
        padding: 14px;
        margin-bottom: 16px;
    }
    .info-banner-title {
        display: flex;
        align-items: center;
        gap: 6px;
        font-size: 13px;
        font-weight: 800;
        color: var(--primary);
        margin-bottom: 6px;
    }
    .info-banner-desc {
        font-size: 11px;
        color: var(--text-gray);
        line-height: 1.4;
    }

    /* Payment Method Selector */
    .payment-method-card {
        display: flex;
        align-items: center;
        gap: 12px;
        padding: 12px;
        border-radius: 14px;
        border: 1.5px solid var(--border);
        background: #fcfcfc;
        cursor: pointer;
        margin-bottom: 8px;
        transition: all 0.2s;
    }
    .payment-method-card.selected {
        border-color: var(--primary);
        background: var(--white);
        box-shadow: 0 4px 12px rgba(0, 136, 255, 0.08);
    }
    .payment-method-card .method-icon {
        width: 38px; height: 38px;
        background: #f3f3f3;
        border-radius: 8px;
        display: flex; align-items: center; justify-content: center;
        font-size: 18px;
    }
    .payment-method-card.selected .method-icon {
        background: var(--primary-light);
    }
    .payment-method-card .method-info {
        flex: 1;
    }
    .payment-method-card .method-title {
        font-size: 13px;
        font-weight: 700;
        color: var(--text-dark);
    }
    .payment-method-card .method-subtitle {
        font-size: 10px;
        color: var(--text-gray);
    }
    .payment-method-card .method-check {
        color: var(--text-gray);
        font-size: 16px;
    }
    .payment-method-card.selected .method-check {
        color: var(--primary);
    }

    /* Manual Bank Details */
    .bank-details {
        background: #fbfbfb;
        border: 1px dashed var(--primary);
        padding: 12px;
        border-radius: 12px;
        margin-top: 10px;
        font-size: 12px;
        color: var(--text-dark);
    }
    .bank-details p { margin-bottom: 4px; }
    .bank-details p:last-child { margin-bottom: 0; }

    /* Struk Rincian Biaya */
    .receipt-box {
        background: rgba(0, 136, 255, 0.04);
        border: 1px solid rgba(0, 136, 255, 0.1);
        border-radius: 18px;
        padding: 16px;
        margin-top: 16px;
    }
    .receipt-title { font-size: 13px; font-weight: 800; color: var(--text-dark); margin-bottom: 10px; }
    .receipt-row {
        display: flex;
        justify-content: space-between;
        align-items: center;
        font-size: 12px;
        margin-bottom: 6px;
        color: var(--text-gray);
    }
    .receipt-row.total {
        margin-top: 10px;
        padding-top: 10px;
        border-top: 1.5px dashed var(--border);
        color: var(--text-dark);
        font-weight: 800;
    }
    .receipt-row.total .total-price-text {
        font-size: 16px;
        color: var(--primary);
    }

    /* Loading Spinner */
    .loading-spinner {
        display: inline-block;
        width: 16px; height: 16px;
        border: 2.5px solid rgba(255,255,255,0.3);
        border-top-color: white;
        border-radius: 50%;
        animation: spin 0.8s linear infinite;
    }
    @keyframes spin { to { transform: rotate(360deg); } }
</style>
@endsection

@section('content')
<div class="header-field">
    <a href="{{ route('lapangan.index') }}" class="back-btn"><i class="fa-solid fa-chevron-left"></i></a>
    <h2>{{ $field->name }}</h2>
</div>

{{-- Calendar Selector --}}
<div class="date-selection">
    @php
        $dates = $slots->pluck('date')->unique()->map(function($date) {
            return \Carbon\Carbon::parse($date);
        });
    @endphp
    @forelse($dates as $index => $date)
    <div class="date-card {{ $index == 0 ? 'active' : '' }}" data-date="{{ $date->format('Y-m-d') }}" onclick="selectDate('{{ $date->format('Y-m-d') }}', this)">
        <span>{{ $date->isoFormat('ddd') }}</span>
        <span>{{ $date->format('d') }}</span>
    </div>
    @empty
    <div style="padding: 10px; font-size: 12px; color: var(--text-gray);">Belum ada jadwal slot yang tersedia.</div>
    @endforelse
</div>

{{-- Legend --}}
<div class="container" style="margin-bottom: 15px;">
    <div style="display: flex; gap: 15px;">
        <span style="font-size: 11px; display: flex; align-items: center; gap: 5px;">
            <div style="width: 10px; height: 10px; background: #38B2AC; border-radius: 2px;"></div> Tersedia
        </span>
        <span style="font-size: 11px; display: flex; align-items: center; gap: 5px;">
            <div style="width: 10px; height: 10px; background: #F56565; border-radius: 2px;"></div> Penuh
        </span>
        <span style="font-size: 11px; display: flex; align-items: center; gap: 5px;">
            <div style="width: 10px; height: 10px; background: var(--primary); border-radius: 2px;"></div> Dipilih
        </span>
    </div>
</div>

{{-- Slots Grid --}}
<div class="slot-grid" id="slots-container">
    @forelse($slots as $slot)
    <div class="slot-card {{ $slot->remaining_capacity > 0 ? 'available' : 'full' }}" 
         data-id="{{ $slot->id }}" 
         data-date="{{ $slot->date->format('Y-m-d') }}" 
         data-time="{{ substr($slot->start_time, 0, 5) }}"
         data-end-time="{{ substr($slot->end_time, 0, 5) }}"
         data-capacity="{{ $slot->remaining_capacity }}"
         data-has-host="{{ $slot->has_host ? 'true' : 'false' }}"
         data-host-name="{{ $slot->host_name }}"
         data-host-phone="{{ $slot->host_phone }}"
         onclick="selectSlot(this)">
        <div class="slot-time">{{ substr($slot->start_time, 0, 5) }} WIB</div>
        <div class="slot-status" style="color: {{ $slot->remaining_capacity > 0 ? '#38B2AC' : '#F56565' }}">
            {{ $slot->remaining_capacity > 0 ? 'Tersedia' : 'Penuh' }}
        </div>
        <div class="slot-count">{{ $slot->remaining_capacity > 0 ? 'Sisa ' . $slot->remaining_capacity . ' slot' : 'Slot Habis' }}</div>
    </div>
    @empty
    <div style="grid-column: 1 / -1; text-align: center; padding: 40px;">
        <p style="color: var(--text-gray);">Jadwal belum tersedia untuk lapangan ini.</p>
    </div>
    @endforelse
</div>

{{-- Bottom Slide-up Booking Bar --}}
<div class="booking-bar" id="booking-bar">
    <div class="booking-bar-info">
        <div>
            <div class="info-start-title" id="bar-slot-time">Mulai: --:-- WIB</div>
            <div class="info-capacity-desc" id="bar-slot-capacity">Sisa Kapasitas: - slot</div>
            <div class="info-host-desc" id="bar-slot-host" style="display: none;"></div>
        </div>
    </div>
    <div style="display: flex; align-items: center; gap: 20px;">
        <div class="price-value-container">
            <div class="price-value" id="bar-total-price">Rp 0</div>
            <div class="price-lbl" id="bar-price-unit">/ jam</div>
        </div>
        <button class="btn-main-booking" id="bar-submit-btn" onclick="openCheckoutModal()">
            <span>Pesan Sekarang</span>
            <i class="fa-solid fa-arrow-right"></i>
        </button>
    </div>
</div>

{{-- Checkout Modal Overlay --}}
<div class="modal-overlay" id="checkout-modal-overlay">
    <div class="checkout-modal">
        <div class="modal-header">
            <h3>Konfirmasi Booking</h3>
            <button class="close-modal-btn" onclick="closeCheckoutModal()">✕</button>
        </div>

        {{-- Ticket Overview --}}
        <div class="checkout-card" style="display: flex; gap: 12px; align-items: center; background: var(--bg); border: none;">
            <div style="font-size: 32px; width: 50px; height: 50px; background: var(--white); border-radius: 12px; display: flex; align-items: center; justify-content: center;">
                @php
                    $emojis = ['Futsal' => '⚽', 'Badminton' => '🏸', 'Basket' => '🏀', 'Voli' => '🏐', 'Tenis Meja' => '🏓', 'Tenis' => '🎾'];
                    $emoji = $emojis[$field->type] ?? '🏟️';
                @endphp
                {{ $emoji }}
            </div>
            <div>
                <h4 style="font-size: 14px; font-weight: 800;">{{ $field->name }}</h4>
                <p style="font-size: 11px; color: var(--text-gray);">{{ $field->type }} · Indoor</p>
            </div>
        </div>

        {{-- Form --}}
        <div class="step-label-row">
            <div class="step-number">1</div>
            <div class="step-text">Data & Konfigurasi Sewa</div>
        </div>

        <div class="checkout-card">
            <div class="form-group">
                <label class="form-label">Nomor WhatsApp</label>
                <div class="form-input-wrapper">
                    <i class="fa-brands fa-whatsapp"></i>
                    <input type="text" id="wa-number" class="form-input-field" placeholder="Contoh: 08123456789" value="{{ Auth::user()->phone }}">
                </div>
            </div>

            <div class="counter-row">
                <span class="counter-label">Durasi Sewa</span>
                <div class="counter-control">
                    <button class="btn-counter" id="btn-dec-duration" onclick="adjustDuration(-1)">-</button>
                    <span class="counter-val" id="val-duration">1 jam</span>
                    <button class="btn-counter enabled" id="btn-inc-duration" onclick="adjustDuration(1)">+</button>
                </div>
            </div>

            <div class="counter-row">
                <span class="counter-label">Jumlah Orang</span>
                <div class="counter-control">
                    <button class="btn-counter" id="btn-dec-person" onclick="adjustPerson(-1)">-</button>
                    <span class="counter-val" id="val-person">1</span>
                    <button class="btn-counter enabled" id="btn-inc-person" onclick="adjustPerson(1)">+</button>
                </div>
            </div>

            {{-- Private Toggle --}}
            <div class="toggle-row" id="private-toggle-row">
                <div class="toggle-label-container">
                    <span class="toggle-title">Sewa Privat (Main Sendiri)</span>
                    <span class="toggle-subtitle">Kunci slot waktu agar orang lain tidak bisa bergabung</span>
                </div>
                <label class="switch">
                    <input type="checkbox" id="private-checkbox" onchange="togglePrivate(this.checked)">
                    <span class="switch-slider"></span>
                </label>
            </div>
        </div>

        {{-- Info Banner for Joiner --}}
        <div class="info-banner" id="joiner-info-banner" style="display: none;">
            <div class="info-banner-title">
                <i class="fa-solid fa-circle-info"></i> Informasi Gabung Slot
            </div>
            <div class="info-banner-desc">
                Lapangan ini telah disewa dan dibayar penuh oleh Host ke pemilik lapangan. Anda tidak perlu membayar sewa lagi lewat aplikasi. Anda dapat berpatungan secara offline dengan Host di lokasi lapangan.
            </div>
        </div>

        {{-- Step 2: Payment Method (Only for Host) --}}
        <div id="payment-method-section">
            <div class="step-label-row">
                <div class="step-number">2</div>
                <div class="step-text">Metode Pembayaran</div>
            </div>

            <div class="payment-method-card selected" id="method-midtrans" onclick="setPaymentMethod('midtrans')">
                <div class="method-icon">💳</div>
                <div class="method-info">
                    <div class="method-title">Midtrans (Otomatis)</div>
                    <div class="method-subtitle">Transfer Bank, QRIS, E-Wallet, Kartu Kredit</div>
                </div>
                <div class="method-check" id="check-midtrans"><i class="fa-solid fa-circle-check"></i></div>
            </div>

            <div class="payment-method-card" id="method-manual" onclick="setPaymentMethod('manual')">
                <div class="method-icon">🏦</div>
                <div class="method-info">
                    <div class="method-title">Transfer Manual</div>
                    <div class="method-subtitle">Transfer ke Rekening Bank (Upload Bukti)</div>
                </div>
                <div class="method-check" id="check-manual"><i class="fa-regular fa-circle"></i></div>
            </div>

            <div class="bank-details" id="bank-details" style="display: none;">
                <p><strong>Informasi Rekening Transfer:</strong></p>
                <p>Bank BCA: <strong>1234567890</strong></p>
                <p>A.N. <strong>E-Reserv Sports Center</strong></p>
            </div>
        </div>

        {{-- Receipt / Struk --}}
        <div class="receipt-box">
            <div class="receipt-title">Rincian Estimasi Biaya</div>
            <div class="receipt-row">
                <span>Harga per Jam</span>
                <span id="receipt-price-per-hour">Rp {{ number_format($field->price, 0, ',', '.') }}</span>
            </div>
            <div class="receipt-row">
                <span>Durasi</span>
                <span id="receipt-duration">1 jam</span>
            </div>
            <div class="receipt-row">
                <span>Jumlah Orang</span>
                <span id="receipt-person">1 orang (tidak mempengaruhi harga)</span>
            </div>
            <div class="receipt-row total">
                <span>Total Pembayaran</span>
                <span class="total-price-text" id="receipt-total-price">Rp 0</span>
            </div>
        </div>

        {{-- Confirm Button --}}
        <button class="btn-submit" id="btn-confirm-checkout" onclick="submitBooking()" style="margin-top: 24px; padding: 14px; width: 100%; border-radius: 12px; display: flex; align-items: center; justify-content: center; gap: 8px; font-weight: 800;">
            <span id="btn-text">Lanjut ke Pembayaran</span>
        </button>
    </div>
</div>
@endsection

@section('scripts')
<script src="https://app.sandbox.midtrans.com/snap/snap.js" data-client-key="{{ config('midtrans.client_key') }}"></script>
<script>
    // State Variables
    let selectedDate = '';
    let selectedSlotId = null;
    let selectedSlotData = null;
    let durationHours = 1;
    let personCount = 1;
    let isPrivate = false;
    let paymentMethod = 'midtrans';
    
    const fieldPrice = {{ $field->price }};
    const allSlots = @json($slots);

    // Initial load
    document.addEventListener('DOMContentLoaded', () => {
        // Select first date card automatically if exists
        const firstCard = document.querySelector('.date-card');
        if (firstCard) {
            firstCard.click();
        }
    });

    function selectDate(dateStr, element) {
        selectedDate = dateStr;
        
        // Update active class
        document.querySelectorAll('.date-card').forEach(c => c.classList.remove('active'));
        element.classList.add('active');

        // Reset slot selection
        selectedSlotId = null;
        selectedSlotData = null;
        document.querySelectorAll('.slot-card').forEach(c => c.classList.remove('selected'));
        hideBookingBar();

        // Filter slot grid
        document.querySelectorAll('.slot-card').forEach(c => {
            const slotDate = c.getAttribute('data-date');
            if (slotDate === dateStr) {
                c.style.display = 'flex';
            } else {
                c.style.display = 'none';
            }
        });
    }

    function selectSlot(element) {
        if (element.classList.contains('full')) return;

        const slotId = parseInt(element.getAttribute('data-id'));
        const isSelected = element.classList.contains('selected');

        document.querySelectorAll('.slot-card').forEach(c => c.classList.remove('selected'));

        if (isSelected) {
            selectedSlotId = null;
            selectedSlotData = null;
            hideBookingBar();
        } else {
            element.classList.add('selected');
            selectedSlotId = slotId;
            
            // Get slot details from attributes
            selectedSlotData = {
                id: slotId,
                startTime: element.getAttribute('data-time'),
                endTime: element.getAttribute('data-end-time'),
                capacity: parseInt(element.getAttribute('data-capacity')),
                hasHost: element.getAttribute('data-has-host') === 'true',
                hostName: element.getAttribute('data-host-name'),
                hostPhone: element.getAttribute('data-host-phone')
            };

            // Reset booking configs based on slot type (Host vs Joiner)
            resetBookingConfigs();
            showBookingBar();
        }
    }

    function resetBookingConfigs() {
        durationHours = 1;
        personCount = 1;
        isPrivate = false;

        // If Joiner (already has host)
        if (selectedSlotData.hasHost) {
            // Disable duration control (locked to 1 hour)
            document.getElementById('btn-dec-duration').classList.remove('enabled');
            document.getElementById('btn-inc-duration').classList.remove('enabled');
            document.getElementById('private-toggle-row').style.display = 'none';
            document.getElementById('joiner-info-banner').style.display = 'block';
            document.getElementById('payment-method-section').style.display = 'none';
        } else {
            // Host
            document.getElementById('btn-dec-duration').classList.remove('enabled');
            document.getElementById('btn-inc-duration').classList.add('enabled');
            document.getElementById('private-toggle-row').style.display = 'flex';
            document.getElementById('joiner-info-banner').style.display = 'none';
            document.getElementById('payment-method-section').style.display = 'block';
        }

        // Initialize person counter styling
        updatePersonButtons();
        updateCheckoutUI();
    }

    function updatePersonButtons() {
        const decBtn = document.getElementById('btn-dec-person');
        const incBtn = document.getElementById('btn-inc-person');

        if (personCount > 1) {
            decBtn.classList.add('enabled');
        } else {
            decBtn.classList.remove('enabled');
        }

        if (personCount < selectedSlotData.capacity) {
            incBtn.classList.add('enabled');
        } else {
            incBtn.classList.remove('enabled');
        }
    }

    function adjustDuration(delta) {
        if (selectedSlotData.hasHost) return; // Joiner cannot change duration

        const newDuration = durationHours + delta;
        if (newDuration >= 1) {
            durationHours = newDuration;
            document.getElementById('val-duration').textContent = `${durationHours} jam`;
            document.getElementById('btn-dec-duration').className = durationHours > 1 ? 'btn-counter enabled' : 'btn-counter';
            updateCheckoutUI();
        }
    }

    function adjustPerson(delta) {
        const newPerson = personCount + delta;
        if (newPerson >= 1 && newPerson <= selectedSlotData.capacity) {
            personCount = newPerson;
            document.getElementById('val-person').textContent = personCount;
            updatePersonButtons();
            updateCheckoutUI();
        }
    }

    function togglePrivate(val) {
        isPrivate = val;
    }

    function setPaymentMethod(method) {
        paymentMethod = method;
        
        // Update cards class
        document.getElementById('method-midtrans').className = method === 'midtrans' ? 'payment-method-card selected' : 'payment-method-card';
        document.getElementById('method-manual').className = method === 'manual' ? 'payment-method-card selected' : 'payment-method-card';

        // Update icons
        document.getElementById('check-midtrans').innerHTML = method === 'midtrans' ? '<i class="fa-solid fa-circle-check"></i>' : '<i class="fa-regular fa-circle"></i>';
        document.getElementById('check-manual').innerHTML = method === 'manual' ? '<i class="fa-solid fa-circle-check"></i>' : '<i class="fa-regular fa-circle"></i>';

        // Bank details section
        document.getElementById('bank-details').style.display = method === 'manual' ? 'block' : 'none';

        updateCheckoutUI();
    }

    function updateCheckoutUI() {
        const isJoiner = selectedSlotData ? selectedSlotData.hasHost : false;
        const price = isJoiner ? 0 : (fieldPrice * durationHours);

        // Format Currency Helper
        const formattedPrice = 'Rp ' + price.toLocaleString('id-ID');

        // Update Slide-up bar
        document.getElementById('bar-slot-time').textContent = `Mulai: ${selectedSlotData.startTime} WIB`;
        document.getElementById('bar-slot-capacity').textContent = `Sisa Kapasitas: ${selectedSlotData.capacity} slot`;
        
        const hostEl = document.getElementById('bar-slot-host');
        if (isJoiner) {
            hostEl.style.display = 'block';
            hostEl.textContent = `Host: ${selectedSlotData.hostName}`;
            document.getElementById('bar-total-price').textContent = 'Gratis';
            document.getElementById('bar-price-unit').textContent = 'Patungan offline';
            document.getElementById('bar-submit-btn').querySelector('span').textContent = 'Gabung Slot';
        } else {
            hostEl.style.display = 'none';
            document.getElementById('bar-total-price').textContent = formattedPrice;
            document.getElementById('bar-price-unit').textContent = '/ jam';
            document.getElementById('bar-submit-btn').querySelector('span').textContent = 'Pesan Sekarang';
        }

        // Update Modal elements
        document.getElementById('receipt-duration').textContent = `${durationHours} jam`;
        document.getElementById('receipt-person').textContent = `${personCount} orang (tidak mempengaruhi harga)`;
        document.getElementById('receipt-total-price').textContent = isJoiner ? 'Rp 0 (Gabung Slot)' : formattedPrice;

        const btnText = document.getElementById('btn-text');
        if (isJoiner) {
            btnText.textContent = 'Konfirmasi Bergabung';
        } else {
            btnText.textContent = paymentMethod === 'midtrans' ? 'Bayar Sekarang' : 'Konfirmasi Booking';
        }
    }

    function showBookingBar() {
        document.getElementById('booking-bar').classList.add('show');
    }

    function hideBookingBar() {
        document.getElementById('booking-bar').classList.remove('show');
    }

    function openCheckoutModal() {
        document.getElementById('checkout-modal-overlay').classList.add('show');
    }

    function closeCheckoutModal() {
        document.getElementById('checkout-modal-overlay').classList.remove('show');
    }

    async function submitBooking() {
        const waNumber = document.getElementById('wa-number').value.trim();
        if (!waNumber) {
            alert('Silakan isi nomor WhatsApp untuk memudahkan komunikasi!');
            return;
        }

        const isJoiner = selectedSlotData.hasHost;
        const finalPrice = isJoiner ? 0 : (fieldPrice * durationHours);

        const btn = document.getElementById('btn-confirm-checkout');
        const btnText = document.getElementById('btn-text');
        
        // Show loading state
        btn.disabled = true;
        btnText.innerHTML = '<span class="loading-spinner"></span> Memproses...';

        try {
            // 1. Create Booking via API
            const response = await fetch('/api/bookings', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Accept': 'application/json'
                },
                body: JSON.stringify({
                    user_id: {{ Auth::id() }},
                    field_id: {{ $field->id }},
                    date: selectedDate,
                    start_time: selectedSlotData.startTime,
                    duration_hours: durationHours,
                    total_price: finalPrice,
                    person_count: personCount,
                    is_private: isPrivate ? 1 : 0
                })
            });

            if (!response.ok) {
                const errorData = await response.json();
                throw new Error(errorData.message || 'Gagal membuat reservasi');
            }

            const resJson = await response.json();
            const booking = resJson.data;

            // 2. Handle Payment/Checkout Flow
            if (finalPrice === 0) {
                // Free Joiner Booking: langsung redirect ke Status
                alert('Berhasil bergabung dengan slot sewa!');
                window.location.href = '{{ route("status.index") }}';
                return;
            }

            // Host Booking with positive price
            if (paymentMethod === 'midtrans') {
                // Call API to create Payment & get Snap Token
                const payResponse = await fetch('/api/payments', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'Accept': 'application/json'
                    },
                    body: JSON.stringify({
                        booking_id: booking.id,
                        method: 'midtrans'
                    })
                });

                if (!payResponse.ok) {
                    throw new Error('Gagal memproses token pembayaran Midtrans');
                }

                const payJson = await payResponse.json();
                const snapToken = payJson.snap_token;

                // Open Midtrans Snap UI
                snap.pay(snapToken, {
                    onSuccess: async function(result) {
                        // Bypass payment in backend local development
                        try {
                            await fetch('/api/payments/webhook', {
                                method: 'POST',
                                headers: { 'Content-Type': 'application/json' },
                                body: JSON.stringify({
                                    order_id: booking.booking_code,
                                    transaction_status: 'settlement',
                                    gross_amount: finalPrice.toString()
                                })
                            });
                        } catch(e) { console.error('Bypass error: ', e); }

                        alert('Pembayaran Sukses! Selamat berolahraga.');
                        window.location.href = '{{ route("status.index") }}';
                    },
                    onPending: function(result) {
                        alert('Pembayaran Menunggu! Silakan selesaikan pembayaran Anda.');
                        window.location.href = '{{ route("status.index") }}';
                    },
                    onError: function(result) {
                        alert('Pembayaran Gagal! Silakan coba lagi.');
                        window.location.href = '{{ route("status.index") }}';
                    },
                    onClose: function() {
                        alert('Anda menutup popup pembayaran. Anda dapat membayar nanti di halaman Status.');
                        window.location.href = '{{ route("status.index") }}';
                    }
                });
            } else {
                // Manual Bank Transfer
                const payResponse = await fetch('/api/payments', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'Accept': 'application/json'
                    },
                    body: JSON.stringify({
                        booking_id: booking.id,
                        method: 'manual'
                    })
                });

                if (!payResponse.ok) {
                    throw new Error('Gagal mencatat pembayaran manual');
                }

                alert('Booking Berhasil! Silakan lakukan transfer bank dan upload bukti pembayaran di halaman Status.');
                window.location.href = '{{ route("status.index") }}';
            }

        } catch (error) {
            alert('Kesalahan: ' + error.message);
            // Reset loading state
            btn.disabled = false;
            btnText.textContent = paymentMethod === 'midtrans' ? 'Bayar Sekarang' : 'Konfirmasi Booking';
        }
    }
</script>
@endsection
