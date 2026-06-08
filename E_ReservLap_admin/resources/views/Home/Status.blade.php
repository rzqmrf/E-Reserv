@extends('layouts.user')

@section('styles')
<style>
    .header-page {
        padding: 20px;
        background: var(--white);
        margin-bottom: 20px;
    }

    .header-page h2 {
        font-size: 20px;
        font-weight: 700;
    }

    .status-list {
        padding: 0 20px;
    }

    .booking-card {
        background: var(--white);
        border-radius: 20px;
        padding: 20px;
        margin-bottom: 20px;
        box-shadow: var(--shadow);
    }

    .booking-card-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 15px;
        padding-bottom: 10px;
        border-bottom: 1px solid #f0f0f0;
    }

    .booking-date {
        font-size: 12px;
        color: var(--text-gray);
        font-weight: 600;
    }

    .booking-id {
        font-size: 10px;
        background: #f0f4f8;
        padding: 2px 8px;
        border-radius: 5px;
        color: #4a5568;
    }

    .status-badge {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        width: fit-content;
        padding: 6px 10px;
        border-radius: 999px;
        font-size: 11px;
        font-weight: 800;
        margin-bottom: 14px;
    }

    .status-badge.pending { background: #FFFAF0; color: #DD6B20; }
    .status-badge.approved { background: #EBF8FF; color: #3182CE; }
    .status-badge.completed { background: #E6FFFA; color: #2C7A7B; }
    .status-badge.rejected { background: #FFF5F5; color: #C53030; }

    .booking-card-body h4 {
        font-size: 18px;
        margin-bottom: 15px;
    }

    /* Stepper */
    .stepper {
        display: flex;
        justify-content: space-between;
        margin-bottom: 20px;
        position: relative;
    }

    .stepper::before {
        content: "";
        position: absolute;
        top: 10px;
        left: 0;
        right: 0;
        height: 2px;
        background: #E2E8F0;
        z-index: 1;
    }

    .step {
        position: relative;
        z-index: 2;
        background: var(--white);
        padding: 0 5px;
        display: flex;
        flex-direction: column;
        align-items: center;
        gap: 5px;
    }

    .step-circle {
        width: 20px;
        height: 20px;
        border-radius: 50%;
        background: #CBD5E0;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 10px;
        color: white;
    }

    .step.active .step-circle { background: var(--primary); }
    .step.completed .step-circle { background: #38B2AC; }

    .step-label {
        font-size: 10px;
        font-weight: 600;
        color: var(--text-gray);
    }

    .step.active .step-label { color: var(--primary); }
    .step.completed .step-label { color: #38B2AC; }

    .booking-details {
        background: #F7FAFC;
        padding: 12px;
        border-radius: 12px;
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 10px;
    }

    .detail-item {
        display: flex;
        flex-direction: column;
    }

    .detail-label {
        font-size: 10px;
        color: var(--text-gray);
        margin-bottom: 2px;
    }

    .detail-value {
        font-size: 12px;
        font-weight: 700;
    }

    .booking-actions {
        display: flex;
        gap: 10px;
        margin-top: 14px;
    }

    .btn-pay {
        width: 100%;
        border: none;
        border-radius: 12px;
        padding: 12px 16px;
        background: var(--primary);
        color: var(--white);
        font-size: 14px;
        font-weight: 800;
        cursor: pointer;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        gap: 8px;
        transition: transform 0.2s, opacity 0.2s;
    }

    .btn-pay:active {
        transform: scale(0.98);
    }

    .btn-pay:disabled {
        cursor: not-allowed;
        opacity: 0.65;
    }

    /* Empty State */
    .empty-state {
        text-align: center;
        padding: 60px 20px;
    }

    .empty-state i {
        font-size: 80px;
        color: var(--primary-light);
        margin-bottom: 20px;
    }

    .empty-state h3 {
        font-size: 18px;
        margin-bottom: 10px;
    }

    .empty-state p {
        font-size: 14px;
        color: var(--text-gray);
        margin-bottom: 25px;
    }
</style>
@endsection

@section('content')
<div class="header-page">
    <h2>Status Booking</h2>
</div>

<div class="status-list">
    @forelse($bookings as $booking)
    @php
        $bookingEnd = \Carbon\Carbon::parse($booking->date . ' ' . $booking->end_time);
        $isPending = $booking->status === 'pending';
        $isApproved = $booking->status === 'approved';
        $isRejected = $booking->status === 'rejected';
        $isCompleted = $isApproved && $bookingEnd->isPast();
        $isPaid = $isApproved || optional($booking->payment)->status === 'paid' || (int) $booking->total_price === 0;

        $statusClass = $isRejected ? 'rejected' : ($isCompleted ? 'completed' : ($isApproved ? 'approved' : 'pending'));
        $statusLabel = $isRejected ? 'Ditolak' : ($isCompleted ? 'Selesai' : ($isApproved ? 'Sudah Dibayar' : 'Menunggu Pembayaran'));
    @endphp
    <div class="booking-card">
        <div class="booking-card-header">
            <span class="booking-date">{{ \Carbon\Carbon::parse($booking->date)->isoFormat('LL') }}</span>
            <span class="booking-id">#RES-{{ $booking->id }}</span>
        </div>
        <div class="booking-card-body">
            <h4>{{ $booking->field->name }}</h4>
            <div class="status-badge {{ $statusClass }}">
                <i class="fa-solid {{ $isRejected ? 'fa-circle-xmark' : ($isCompleted ? 'fa-circle-check' : ($isApproved ? 'fa-credit-card' : 'fa-clock')) }}"></i>
                {{ $statusLabel }}
            </div>
            
            <div class="stepper">
                <div class="step {{ !$isPending && !$isRejected ? 'completed' : ($isPending ? 'active' : '') }}">
                    <div class="step-circle">{!! !$isPending && !$isRejected ? '<i class="fa-solid fa-check"></i>' : '1' !!}</div>
                    <span class="step-label">Menunggu</span>
                </div>
                <div class="step {{ $isPaid && !$isRejected ? 'completed' : ($isPending ? '' : 'active') }}">
                    <div class="step-circle">{!! $isPaid && !$isRejected ? '<i class="fa-solid fa-check"></i>' : '2' !!}</div>
                    <span class="step-label">Bayar</span>
                </div>
                <div class="step {{ $isCompleted ? 'completed' : ($isApproved ? 'active' : '') }}">
                    <div class="step-circle">{!! $isCompleted ? '<i class="fa-solid fa-check"></i>' : '3' !!}</div>
                    <span class="step-label">Selesai</span>
                </div>
            </div>

            <div class="booking-details">
                <div class="detail-item">
                    <span class="detail-label">Waktu</span>
                    <span class="detail-value">{{ \Carbon\Carbon::parse($booking->start_time)->format('H:i') }} - {{ \Carbon\Carbon::parse($booking->end_time)->format('H:i') }}</span>
                </div>
                <div class="detail-item">
                    <span class="detail-label">Total Biaya</span>
                    <span class="detail-value" style="color: var(--primary);">Rp {{ number_format($booking->total_price, 0, ',', '.') }}</span>
                </div>
            </div>

            @if($booking->status === 'pending' && $booking->total_price > 0)
                <div class="booking-actions">
                    <button
                        type="button"
                        class="btn-pay"
                        onclick="payBooking(this, {{ $booking->id }}, '{{ $booking->booking_code }}', {{ (int) $booking->total_price }})"
                    >
                        <i class="fa-solid fa-credit-card"></i>
                        Bayar Sekarang
                    </button>
                </div>
            @endif
        </div>
    </div>
    @empty
    <div class="empty-state">
        <i class="fa-solid fa-receipt"></i>
        <h3>Belum ada booking</h3>
        <p>Riwayat booking anda akan muncul di sini setelah anda melakukan pemesanan.</p>
        <a href="{{ route('lapangan.index') }}" class="btn-primary" style="text-decoration: none;">Cari Lapangan</a>
    </div>
    @endforelse
</div>
@endsection

@section('scripts')
<script src="https://app.sandbox.midtrans.com/snap/snap.js" data-client-key="{{ config('midtrans.client_key') }}"></script>
<script>
async function payBooking(button, bookingId, bookingCode, amount) {
    const originalText = button.innerHTML;
    button.disabled = true;
    button.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Memproses...';

    try {
        const response = await fetch('/api/payments', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json'
            },
            body: JSON.stringify({
                booking_id: bookingId,
                method: 'midtrans'
            })
        });

        if (!response.ok) {
            throw new Error('Gagal membuat pembayaran.');
        }

        const data = await response.json();
        if (!data.snap_token) {
            throw new Error('Token Midtrans tidak tersedia.');
        }

        snap.pay(data.snap_token, {
            onSuccess: async function() {
                await markPaymentPaid(bookingCode, amount);
                alert('Pembayaran berhasil.');
                window.location.reload();
            },
            onPending: function() {
                alert('Pembayaran masih pending. Silakan selesaikan transaksi.');
                window.location.reload();
            },
            onError: function() {
                alert('Pembayaran gagal. Silakan coba lagi.');
                button.disabled = false;
                button.innerHTML = originalText;
            },
            onClose: function() {
                button.disabled = false;
                button.innerHTML = originalText;
            }
        });
    } catch (error) {
        alert(error.message);
        button.disabled = false;
        button.innerHTML = originalText;
    }
}

async function markPaymentPaid(bookingCode, amount) {
    await fetch('/api/payments/webhook', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            order_id: bookingCode,
            transaction_status: 'settlement',
            gross_amount: amount.toString()
        })
    });
}
</script>
@endsection
