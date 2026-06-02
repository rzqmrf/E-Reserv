@extends('layouts.user')

@section('styles')
<style>
    .header-page {
        padding: 20px;
        background: var(--white);
        position: sticky;
        top: 0;
        z-index: 100;
        box-shadow: 0 2px 10px rgba(0,0,0,0.02);
    }

    .header-page h2 {
        font-size: 20px;
        font-weight: 700;
        margin-bottom: 15px;
    }

    .search-bar {
        position: relative;
        margin-bottom: 15px;
    }

    .search-bar i {
        position: absolute;
        left: 15px;
        top: 50%;
        transform: translateY(-50%);
        color: var(--text-gray);
    }

    .search-bar input {
        width: 100%;
        padding: 12px 12px 12px 45px;
        border-radius: 15px;
        border: 1px solid #E2E8F0;
        background: #F7FAFC;
        font-size: 14px;
        outline: none;
        transition: border-color 0.3s;
    }

    .search-bar input:focus {
        border-color: var(--primary);
    }

    .filter-section {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 0 20px;
        margin-bottom: 20px;
    }

    .filter-section span {
        font-size: 14px;
        font-weight: 600;
    }

    .toggle-switch {
        position: relative;
        display: inline-block;
        width: 44px;
        height: 24px;
    }

    .toggle-switch input { display: none; }

    .slider {
        position: absolute;
        cursor: pointer;
        top: 0; left: 0; right: 0; bottom: 0;
        background-color: #CBD5E0;
        transition: .4s;
        border-radius: 24px;
    }

    .slider:before {
        position: absolute;
        content: "";
        height: 18px; width: 18px;
        left: 3px; bottom: 3px;
        background-color: white;
        transition: .4s;
        border-radius: 50%;
    }

    input:checked + .slider { background-color: var(--primary); }
    input:checked + .slider:before { transform: translateX(20px); }

    .field-list {
        padding: 0 20px;
    }

    @media (min-width: 769px) {
        .field-list {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 25px;
        }
    }

    .field-item {
        background: var(--white);
        border-radius: 20px;
        padding: 12px;
        display: flex;
        gap: 15px;
        margin-bottom: 15px;
        box-shadow: var(--shadow);
        text-decoration: none;
        color: var(--text-dark);
    }

    .field-item-img {
        width: 80px;
        height: 80px;
        border-radius: 15px;
        overflow: hidden;
        flex-shrink: 0;
    }

    .field-item-img img {
        width: 100%;
        height: 100%;
        object-fit: cover;
    }

    .field-item-content {
        flex-grow: 1;
        display: flex;
        flex-direction: column;
        justify-content: space-between;
    }

    .field-item-top {
        display: flex;
        justify-content: space-between;
        align-items: flex-start;
    }

    .field-item-top h4 {
        font-size: 16px;
        font-weight: 600;
    }

    .field-status {
        font-size: 10px;
        padding: 2px 8px;
        border-radius: 10px;
        font-weight: 700;
    }

    .status-available { background: #E6FFFA; color: #38B2AC; }
    .status-full { background: #FFF5F5; color: #F56565; }

    .field-item-bottom {
        display: flex;
        justify-content: space-between;
        align-items: center;
    }

    .location {
        font-size: 12px;
        color: var(--text-gray);
    }

    .btn-lihat {
        padding: 6px 15px;
        font-size: 12px;
        border-radius: 8px;
    }
</style>
@endsection

@section('content')
<div class="header-page">
    <h2>Lapangan</h2>
    <div class="search-bar">
        <i class="fa-solid fa-magnifying-glass"></i>
        <input type="text" placeholder="Cari lapangan...">
    </div>
</div>

<div class="filter-section">
    <span>Paling Tersedia</span>
    <label class="toggle-switch">
        <input type="checkbox">
        <span class="slider"></span>
    </label>
</div>

<div class="field-list">
    @forelse($lapangans as $field)
    <a href="{{ route('lapangan.slot', $field->id) }}" class="field-item">
        <div class="field-item-img">
            {{-- Menggunakan gambar dinamis jika ada, jika tidak pakai placeholder --}}
            <img src="{{ $field->foto_lapangan ? asset('storage/' . $field->foto_lapangan) : 'https://via.placeholder.com/80x80?text=No+Image' }}" alt="{{ $field->name }}" onerror="this.onerror=null;this.src='https://via.placeholder.com/80x80?text=No+Image';">
        </div>
        <div class="field-item-content">
            <div class="field-item-top">
                <div>
                    <h4>{{ $field->name }}</h4>
                    <span class="location"><i class="fa-solid fa-location-dot"></i> {{ $field->type }} • Indoor</span>
                </div>
                <span class="field-status {{ $field->status == 'active' ? 'status-available' : 'status-full' }}">
                    {{ $field->status == 'active' ? 'Tersedia' : 'Penuh' }}
                </span>
            </div>
            <div class="field-item-bottom">
                <span class="field-price" style="font-weight: 700; color: var(--primary); font-size: 14px;">Rp {{ number_format($field->price, 0, ',', '.') }}</span>
                <div class="btn-primary btn-lihat">Lihat</div>
            </div>
        </div>
    </a>
    @empty
    <div style="text-align: center; padding: 40px;">
        <p style="color: var(--text-gray);">Belum ada lapangan yang ditambahkan admin.</p>
    </div>
    @endforelse
</div>
@endsection