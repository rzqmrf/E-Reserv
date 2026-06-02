@extends('layouts.user')

@section('styles')
<style>
    body {
        background-color: #F5F7FA;
    }

    .home-header {
        background: #F5F7FA;
        padding: 25px 20px 10px;
        color: var(--text-dark);
    }

    .header-content {
        max-width: 1200px;
        margin: 0 auto;
    }

    .logo-text {
        font-size: 24px;
        font-weight: 800;
        color: var(--text-dark);
        margin-bottom: 25px;
    }

    /* Welcome Card Styling */
    .welcome-card {
        background: linear-gradient(135deg, #0088FF 0%, #0066FF 100%);
        border-radius: 24px;
        padding: 25px;
        color: white;
        position: relative;
        box-shadow: 0 10px 30px rgba(0, 136, 255, 0.2);
        margin-bottom: 30px;
    }

    .status-badge {
        display: inline-flex;
        align-items: center;
        background: rgba(255, 255, 255, 0.2);
        padding: 6px 12px;
        border-radius: 50px;
        font-size: 11px;
        font-weight: 600;
        margin-bottom: 15px;
        backdrop-filter: blur(4px);
    }

    .status-dot {
        width: 8px;
        height: 8px;
        background: #22C55E;
        border-radius: 50%;
        margin-right: 8px;
        box-shadow: 0 0 10px #22C55E;
    }

    .welcome-card h2 {
        font-size: 26px;
        font-weight: 700;
        margin-bottom: 8px;
    }

    .welcome-card p {
        font-size: 14px;
        opacity: 0.9;
        margin-bottom: 25px;
    }

    .card-actions {
        display: flex;
        gap: 15px;
    }

    .btn-card {
        flex: 1;
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 10px;
        padding: 12px;
        border-radius: 14px;
        font-weight: 700;
        font-size: 14px;
        text-decoration: none;
        transition: all 0.3s;
    }

    .btn-white {
        background: white;
        color: #0088FF;
    }

    .btn-outline {
        background: rgba(255, 255, 255, 0.1);
        border: 1.5px solid rgba(255, 255, 255, 0.5);
        color: white;
    }

    /* Features Section */
    .section-header {
        margin-bottom: 20px;
    }

    .section-header h3 {
        font-size: 18px;
        font-weight: 700;
        margin-bottom: 4px;
    }

    .section-header p {
        font-size: 13px;
        color: #718096;
    }

    .features-grid {
        display: grid;
        grid-template-columns: repeat(3, 1fr);
        gap: 12px;
        margin-bottom: 35px;
    }

    .feature-card {
        background: white;
        padding: 20px 10px;
        border-radius: 20px;
        display: flex;
        flex-direction: column;
        align-items: center;
        text-align: center;
        box-shadow: 0 4px 15px rgba(0,0,0,0.03);
    }

    .feature-icon {
        width: 45px;
        height: 45px;
        background: #EBF8FF;
        border-radius: 12px;
        display: flex;
        align-items: center;
        justify-content: center;
        color: #0088FF;
        font-size: 18px;
        margin-bottom: 12px;
    }

    .feature-card h4 {
        font-size: 13px;
        font-weight: 700;
        margin-bottom: 4px;
    }

    .feature-card span {
        font-size: 10px;
        color: #A0AEC0;
        line-height: 1.3;
    }

    /* Available Fields Section */
    .fields-header {
        display: flex;
        justify-content: space-between;
        align-items: flex-end;
        margin-bottom: 20px;
    }

    .fields-header h3 {
        font-size: 18px;
        font-weight: 700;
        margin-bottom: 4px;
    }

    .fields-header p {
        font-size: 13px;
        color: #718096;
    }

    .btn-see-all {
        color: #0088FF;
        text-decoration: none;
        font-weight: 700;
        font-size: 13px;
    }

    .fields-container {
        display: grid;
        grid-template-columns: repeat(2, 1fr);
        gap: 15px;
        padding-bottom: 100px;
    }

    @media (max-width: 480px) {
        .fields-container {
            grid-template-columns: 1fr;
        }
    }

    .field-card {
        background: white;
        border-radius: 24px;
        overflow: hidden;
        box-shadow: 0 4px 15px rgba(0,0,0,0.03);
        padding: 10px;
    }

    .field-img-wrapper {
        position: relative;
        height: 150px;
        border-radius: 18px;
        overflow: hidden;
        margin-bottom: 15px;
    }

    .field-img-wrapper img {
        width: 100%;
        height: 100%;
        object-fit: cover;
    }

    .status-pill {
        position: absolute;
        top: 10px;
        right: 10px;
        padding: 4px 10px;
        border-radius: 50px;
        font-size: 10px;
        font-weight: 700;
        box-shadow: 0 2px 10px rgba(0,0,0,0.1);
    }

    .status-available {
        background: #E6FFFA;
        color: #22C55E;
    }

    .status-unavailable {
        background: #FFF5F5;
        color: #F56565;
    }

    .field-details h4 {
        font-size: 15px;
        font-weight: 700;
        margin-bottom: 6px;
    }

    .field-meta {
        font-size: 12px;
        color: #718096;
        margin-bottom: 4px;
        display: flex;
        align-items: center;
        gap: 5px;
    }

    .field-footer {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-top: 15px;
    }

    .field-price {
        font-size: 13px;
        font-weight: 700;
        color: #0088FF;
    }

    .btn-select {
        background: #0088FF;
        color: white;
        text-decoration: none;
        padding: 8px 20px;
        border-radius: 12px;
        font-size: 12px;
        font-weight: 700;
        box-shadow: 0 4px 10px rgba(0, 136, 255, 0.2);
    }

    /* Web responsiveness */
    @media (min-width: 769px) {
        .fields-container {
            grid-template-columns: repeat(3, 1fr);
        }
    }
</style>
@endsection

@section('content')
<div class="home-header">
    <div class="header-content">
        <div class="logo-text">E-ReservLap</div>
        
        <div class="welcome-card">
            <div class="status-badge">
                <div class="status-dot"></div>
                Sistem Aktif
            </div>
            <h2>Halo, {{ explode(' ', Auth::user()->name)[0] }} 👋</h2>
            <p>Reservasi Lapangan olahraga mudah & cepat</p>
            
            <div class="card-actions">
                <a href="{{ route('lapangan.index') }}" class="btn-card btn-white">
                    <i class="fa-solid fa-layer-group"></i> Lihat
                </a>
                <a href="{{ route('status.index') }}" class="btn-card btn-outline">
                    <i class="fa-solid fa-clock-rotate-left"></i> Riwayat
                </a>
            </div>
        </div>

        <div class="section-header">
            <h3>Fitur Unggulan</h3>
            <p>Semua yang anda butuhkan</p>
        </div>

        <div class="features-grid">
            <div class="feature-card">
                <div class="feature-icon"><i class="fa-solid fa-clock"></i></div>
                <h4>Cek Jadwal</h4>
                <span>Lihat Slot dan Kapasitas</span>
            </div>
            <div class="feature-card">
                <div class="feature-icon"><i class="fa-solid fa-hand-pointer"></i></div>
                <h4>Booking Mudah</h4>
                <span>Proses cepat & simpel</span>
            </div>
            <div class="feature-card">
                <div class="feature-icon"><i class="fa-solid fa-credit-card"></i></div>
                <h4>Bayar Online</h4>
                <span>Via Midtrans</span>
            </div>
        </div>

        <div class="fields-header">
            <div>
                <h3>Lapangan Tersedia</h3>
                <p>{{ $lapangans->count() }} lapangan siap</p>
            </div>
            <a href="{{ route('lapangan.index') }}" class="btn-see-all">Lihat Semua</a>
        </div>

        <div class="fields-container">
            @forelse($lapangans as $field)
            <div class="field-card">
                <div class="field-img-wrapper">
                    @php
                        $images = [
                            'Futsal' => 'https://images.unsplash.com/photo-1574629810360-7efbbe195018?auto=format&fit=crop&q=80&w=400',
                            'Badminton' => 'https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?auto=format&fit=crop&q=80&w=400',
                            'Basket' => 'https://images.unsplash.com/photo-1546519638-68e109498ffc?auto=format&fit=crop&q=80&w=400',
                        ];
                        $image = $field->foto_lapangan ? asset('storage/' . $field->foto_lapangan) : ($images[$field->type] ?? 'https://images.unsplash.com/photo-1574629810360-7efbbe195018?auto=format&fit=crop&q=80&w=400');
                    @endphp
                    <img src="{{ $image }}" alt="{{ $field->name }}">
                    <div class="status-pill {{ $field->status == 'available' ? 'status-available' : 'status-unavailable' }}">
                        {{ ucfirst($field->status == 'available' ? 'Tersedia' : 'Penuh') }}
                    </div>
                </div>
                <div class="field-details">
                    <h4>{{ $field->name }}</h4>
                    <div class="field-meta">
                        <i class="fa-solid fa-building-circle-check"></i> Indoor - {{ $field->type }}
                    </div>
                    <div class="field-meta">
                        <i class="fa-solid fa-users"></i> Kapasitas {{ $field->capacity }} orang
                    </div>
                    <div class="field-footer">
                        <div class="field-price">Rp {{ number_format($field->price, 0, ',', '.') }}/jam</div>
                        <a href="{{ route('lapangan.slot', $field->id) }}" class="btn-select">Lihat</a>
                    </div>
                </div>
            </div>
            @empty
            <p>Tidak ada lapangan tersedia.</p>
            @endforelse
        </div>
    </div>
</div>
@endsection