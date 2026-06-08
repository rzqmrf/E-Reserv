@extends('layouts.user')

@section('styles')
<style>
    .profile-header {
        background: var(--white);
        padding: 40px 20px;
        text-align: center;
        border-bottom-left-radius: 30px;
        border-bottom-right-radius: 30px;
        box-shadow: var(--shadow);
        margin-bottom: 30px;
    }

    .avatar-wrapper {
        width: 100px;
        height: 100px;
        background: var(--primary-light);
        border-radius: 50%;
        margin: 0 auto 15px;
        display: flex;
        align-items: center;
        justify-content: center;
        color: var(--primary);
        font-size: 40px;
        border: 4px solid var(--white);
        box-shadow: 0 4px 15px rgba(0,0,0,0.1);
    }

    .profile-header h2 {
        font-size: 22px;
        margin-bottom: 5px;
    }

    .profile-header p {
        font-size: 14px;
        color: var(--text-gray);
    }

    .profile-menu {
        padding: 0 20px;
    }

    .menu-group {
        background: var(--white);
        border-radius: 20px;
        overflow: hidden;
        box-shadow: var(--shadow);
        margin-bottom: 20px;
    }

    .menu-item-row {
        display: flex;
        align-items: center;
        padding: 18px 20px;
        text-decoration: none;
        color: var(--text-dark);
        border-bottom: 1px solid #f7f7f7;
        transition: background 0.3s;
    }

    .menu-item-row:last-child { border-bottom: none; }
    .menu-item-row:active { background: #f9f9f9; }
    .menu-item-row.active {
        background: var(--primary-light);
        color: var(--primary);
    }

    .menu-item-row i {
        width: 35px;
        font-size: 18px;
        color: var(--primary);
    }

    .menu-item-row span {
        flex-grow: 1;
        font-size: 15px;
        font-weight: 500;
    }

    .menu-item-row .fa-chevron-right {
        font-size: 12px;
        color: #CBD5E0;
    }

    .logout-btn {
        width: 100%;
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 10px;
        padding: 15px;
        background: #FFF5F5;
        color: #F56565;
        border: none;
        border-radius: 15px;
        font-weight: 700;
        cursor: pointer;
        margin-top: 20px;
    }

    .profile-section {
        background: var(--white);
        border-radius: 20px;
        box-shadow: var(--shadow);
        padding: 22px;
        margin: 0 20px 20px;
        scroll-margin-top: 90px;
    }

    .profile-section.is-hidden {
        display: none;
    }

    .section-title {
        display: flex;
        align-items: center;
        gap: 10px;
        font-size: 18px;
        margin-bottom: 8px;
    }

    .section-title i {
        color: var(--primary);
    }

    .section-desc {
        color: var(--text-gray);
        font-size: 14px;
        line-height: 1.6;
        margin-bottom: 18px;
    }

    .form-grid {
        display: grid;
        gap: 14px;
    }

    .form-group label {
        display: block;
        font-size: 13px;
        font-weight: 700;
        margin-bottom: 7px;
    }

    .form-control {
        width: 100%;
        border: 1px solid #E2E8F0;
        border-radius: 13px;
        padding: 13px 14px;
        font-size: 14px;
        color: var(--text-dark);
        outline: none;
        transition: border 0.2s, box-shadow 0.2s;
    }

    .form-control:focus {
        border-color: var(--primary);
        box-shadow: 0 0 0 4px rgba(0, 136, 255, 0.08);
    }

    .action-row {
        display: flex;
        justify-content: flex-end;
        margin-top: 18px;
    }

    .save-btn {
        border: none;
        border-radius: 13px;
        padding: 13px 18px;
        background: var(--primary);
        color: var(--white);
        font-weight: 700;
        cursor: pointer;
    }

    .alert {
        margin: 0 20px 18px;
        border-radius: 14px;
        padding: 14px 16px;
        font-size: 14px;
        line-height: 1.5;
    }

    .alert-success {
        background: #E6FFFA;
        color: #047857;
        border: 1px solid #A7F3D0;
    }

    .alert-danger {
        background: #FFF5F5;
        color: #C53030;
        border: 1px solid #FED7D7;
    }

    .info-list {
        display: grid;
        gap: 12px;
    }

    .info-item {
        display: flex;
        gap: 12px;
        padding: 14px;
        background: #F8FAFF;
        border: 1px solid #EDF2F7;
        border-radius: 14px;
        color: var(--text-gray);
        font-size: 14px;
        line-height: 1.5;
    }

    .info-item i {
        color: var(--primary);
        margin-top: 3px;
    }

    @media (min-width: 769px) {
        .profile-layout {
            display: grid;
            grid-template-columns: 360px 1fr;
            gap: 22px;
            padding: 0 20px 30px;
        }

        .profile-menu {
            padding: 0;
            position: sticky;
            top: 95px;
            align-self: start;
        }

        .profile-content .profile-section,
        .profile-content .alert {
            margin-left: 0;
            margin-right: 0;
        }
    }
</style>
@endsection

@section('content')
@php($user = Auth::user())

<div class="profile-header">
    <div class="avatar-wrapper">
        <i class="fa-solid fa-user"></i>
    </div>
    <h2>{{ $user->name }}</h2>
    <p>{{ $user->email }}</p>
    <div class="badge badge-success" style="margin-top: 10px;">{{ ucfirst($user->role) }}</div>
</div>

<div class="profile-layout">
    <div class="profile-menu">
        <div class="menu-group">
            <a href="#edit-profile" class="menu-item-row active" data-profile-tab="edit-profile">
                <i class="fa-solid fa-user-pen"></i>
                <span>Edit Profil</span>
                <i class="fa-solid fa-chevron-right"></i>
            </a>
            <a href="#notifications" class="menu-item-row" data-profile-tab="notifications">
                <i class="fa-solid fa-bell"></i>
                <span>Notifikasi</span>
                <i class="fa-solid fa-chevron-right"></i>
            </a>
            <a href="#security" class="menu-item-row" data-profile-tab="security">
                <i class="fa-solid fa-shield-halved"></i>
                <span>Keamanan Akun</span>
                <i class="fa-solid fa-chevron-right"></i>
            </a>
        </div>

        <div class="menu-group">
            <a href="#help" class="menu-item-row" data-profile-tab="help">
                <i class="fa-solid fa-circle-question"></i>
                <span>Bantuan & FAQ</span>
                <i class="fa-solid fa-chevron-right"></i>
            </a>
            <a href="#about-app" class="menu-item-row" data-profile-tab="about-app">
                <i class="fa-solid fa-circle-info"></i>
                <span>Tentang Aplikasi</span>
                <i class="fa-solid fa-chevron-right"></i>
            </a>
        </div>

        <form method="POST" action="{{ route('logout') }}">
            @csrf
            <button type="submit" class="logout-btn">
                <i class="fa-solid fa-right-from-bracket"></i>
                <span>Keluar Akun</span>
            </button>
        </form>
    </div>

    <div class="profile-content">
        @if (session('success'))
            <div class="alert alert-success">{{ session('success') }}</div>
        @endif

        @if ($errors->any())
            <div class="alert alert-danger">
                @foreach ($errors->all() as $error)
                    <div>{{ $error }}</div>
                @endforeach
            </div>
        @endif

        <section class="profile-section" id="edit-profile">
            <h3 class="section-title"><i class="fa-solid fa-user-pen"></i> Edit Profil</h3>
            <p class="section-desc">Perbarui data akun yang digunakan saat melakukan reservasi lapangan.</p>

            <form method="POST" action="{{ route('profile.update') }}">
                @csrf
                @method('PUT')
                <div class="form-grid">
                    <div class="form-group">
                        <label for="name">Nama Lengkap</label>
                        <input type="text" id="name" name="name" class="form-control" value="{{ old('name', $user->name) }}" required>
                    </div>
                    <div class="form-group">
                        <label for="email">Email</label>
                        <input type="email" id="email" name="email" class="form-control" value="{{ old('email', $user->email) }}" required>
                    </div>
                    <div class="form-group">
                        <label for="phone">Nomor WhatsApp</label>
                        <input type="text" id="phone" name="phone" class="form-control" value="{{ old('phone', $user->phone) }}" placeholder="Contoh: 08123456789">
                    </div>
                </div>
                <div class="action-row">
                    <button type="submit" class="save-btn">Simpan Profil</button>
                </div>
            </form>
        </section>

        <section class="profile-section is-hidden" id="notifications">
            <h3 class="section-title"><i class="fa-solid fa-bell"></i> Notifikasi</h3>
            <p class="section-desc">Informasi notifikasi reservasi dan pembayaran akun Anda.</p>
            <div class="info-list">
                <div class="info-item">
                    <i class="fa-solid fa-circle-check"></i>
                    <div>Status booking dapat dipantau melalui menu Status setelah reservasi dibuat.</div>
                </div>
                <div class="info-item">
                    <i class="fa-solid fa-wallet"></i>
                    <div>Informasi pembayaran akan diperbarui otomatis setelah transaksi berhasil diproses.</div>
                </div>
                <div class="info-item">
                    <i class="fa-brands fa-whatsapp"></i>
                    <div>Nomor WhatsApp pada profil digunakan sebagai kontak saat proses booking.</div>
                </div>
            </div>
        </section>

        <section class="profile-section is-hidden" id="security">
            <h3 class="section-title"><i class="fa-solid fa-shield-halved"></i> Keamanan Akun</h3>
            <p class="section-desc">Ganti password akun secara berkala agar akun tetap aman.</p>

            <form method="POST" action="{{ route('profile.password') }}">
                @csrf
                @method('PUT')
                <div class="form-grid">
                    <div class="form-group">
                        <label for="current_password">Password Saat Ini</label>
                        <input type="password" id="current_password" name="current_password" class="form-control" autocomplete="current-password" required>
                    </div>
                    <div class="form-group">
                        <label for="password">Password Baru</label>
                        <input type="password" id="password" name="password" class="form-control" autocomplete="new-password" required>
                    </div>
                    <div class="form-group">
                        <label for="password_confirmation">Konfirmasi Password Baru</label>
                        <input type="password" id="password_confirmation" name="password_confirmation" class="form-control" autocomplete="new-password" required>
                    </div>
                </div>
                <div class="action-row">
                    <button type="submit" class="save-btn">Ubah Password</button>
                </div>
            </form>
        </section>

        <section class="profile-section is-hidden" id="help">
            <h3 class="section-title"><i class="fa-solid fa-circle-question"></i> Bantuan & FAQ</h3>
            <p class="section-desc">Panduan singkat penggunaan akun dan reservasi.</p>
            <div class="info-list">
                <div class="info-item">
                    <i class="fa-solid fa-calendar-days"></i>
                    <div>Pilih menu Lapangan, buka detail lapangan, pilih slot tersedia, lalu selesaikan booking.</div>
                </div>
                <div class="info-item">
                    <i class="fa-solid fa-file-invoice"></i>
                    <div>Riwayat dan status reservasi dapat dilihat melalui menu Status.</div>
                </div>
                <div class="info-item">
                    <i class="fa-solid fa-headset"></i>
                    <div>Jika terjadi kendala, hubungi admin pengelola lapangan dengan menyertakan kode booking.</div>
                </div>
            </div>
        </section>

        <section class="profile-section is-hidden" id="about-app">
            <h3 class="section-title"><i class="fa-solid fa-circle-info"></i> Tentang Aplikasi</h3>
            <p class="section-desc">E-ReservLap adalah sistem reservasi lapangan olahraga digital untuk membantu pengguna melihat jadwal, melakukan booking, dan memantau status reservasi secara online.</p>
            <div class="info-list">
                <div class="info-item">
                    <i class="fa-solid fa-layer-group"></i>
                    <div>Menyediakan daftar lapangan dan slot jadwal yang dapat dipesan pengguna.</div>
                </div>
                <div class="info-item">
                    <i class="fa-solid fa-clock"></i>
                    <div>Membantu mengurangi benturan jadwal melalui data slot yang tersimpan di sistem.</div>
                </div>
            </div>
        </section>
    </div>
</div>
@endsection

@section('scripts')
<script>
    document.addEventListener('DOMContentLoaded', function () {
        const tabs = document.querySelectorAll('[data-profile-tab]');
        const sections = document.querySelectorAll('.profile-section');

        function showProfileSection(sectionId, shouldScroll = false) {
            const target = document.getElementById(sectionId);
            if (!target) return;

            sections.forEach(section => {
                section.classList.toggle('is-hidden', section.id !== sectionId);
            });

            tabs.forEach(tab => {
                tab.classList.toggle('active', tab.dataset.profileTab === sectionId);
            });

            history.replaceState(null, '', '#' + sectionId);

            if (shouldScroll) {
                target.scrollIntoView({ behavior: 'smooth', block: 'start' });
            }
        }

        tabs.forEach(tab => {
            tab.addEventListener('click', function (event) {
                event.preventDefault();
                showProfileSection(tab.dataset.profileTab, true);
            });
        });

        const initialSection = window.location.hash ? window.location.hash.slice(1) : 'edit-profile';
        showProfileSection(initialSection);
    });
</script>
@endsection
