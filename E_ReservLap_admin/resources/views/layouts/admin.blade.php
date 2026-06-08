<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <title>Admin — @yield('title')</title>
    <link rel="stylesheet" href="{{ asset('css/style.css') }}">
    <style>
    /* ── ADMIN LAYOUT ────────────────────────────────── */
    .admin-wrapper {
        display: flex;
        min-height: 100vh;
        background: var(--bg);
    }

    /* Sidebar */
    .admin-sidebar {
        width: 240px;
        flex-shrink: 0;
        background: var(--surface);
        border-right: 1px solid var(--border);
        display: flex;
        flex-direction: column;
        position: sticky;
        top: 0;
        height: 100vh;
        overflow-y: auto;
    }

    .sidebar-brand {
        padding: 28px 24px 20px;
        border-bottom: 1px solid var(--border);
    }

    .sidebar-brand .logo {
        font-family: 'Space Grotesk', monospace;
        font-size: 1.1rem;
        font-weight: 700;
        color: var(--primary);
        letter-spacing: -0.5px;
    }

    .sidebar-brand .logo::before { content: '[ '; color: var(--text-3); font-weight: 400; }
    .sidebar-brand .logo::after  { content: ' ]'; color: var(--text-3); font-weight: 400; }

    .sidebar-brand p {
        font-size: 11px;
        color: var(--text-3);
        margin-top: 4px;
        font-weight: 500;
        letter-spacing: .3px;
        text-transform: uppercase;
    }

    .sidebar-nav {
        padding: 16px 12px;
        flex: 1;
        display: flex;
        flex-direction: column;
        gap: 4px;
    }

    .sidebar-label {
        font-size: 10px;
        font-weight: 700;
        color: var(--text-3);
        letter-spacing: 1px;
        text-transform: uppercase;
        padding: 12px 12px 6px;
    }

    .sidebar-link {
        display: flex;
        align-items: center;
        gap: 10px;
        padding: 10px 14px;
        border-radius: var(--radius-md);
        font-size: 14px;
        font-weight: 600;
        color: var(--text-2);
        transition: background var(--transition), color var(--transition);
        text-decoration: none;
    }

    .sidebar-link:hover {
        background: var(--bg);
        color: var(--text);
    }

    .sidebar-link.active {
        background: var(--primary-lt);
        color: var(--primary-dk);
    }

    .sidebar-link .icon {
        font-size: 16px;
        width: 20px;
        text-align: center;
        flex-shrink: 0;
    }

    .sidebar-footer {
        padding: 16px 12px;
        border-top: 1px solid var(--border);
    }

    .sidebar-footer a,
    .sidebar-footer button {
        display: flex;
        align-items: center;
        gap: 10px;
        width: 100%;
        padding: 10px 14px;
        border-radius: var(--radius-md);
        font-size: 13px;
        font-weight: 600;
        color: var(--text-3);
        transition: background var(--transition), color var(--transition);
        text-decoration: none;
    }

    .sidebar-footer button {
        background: transparent;
        border: 0;
        cursor: pointer;
        font-family: inherit;
        text-align: left;
    }

    .sidebar-footer a:hover,
    .sidebar-footer button:hover {
        background: var(--bg);
        color: var(--text-2);
    }

    .logout-form {
        margin: 8px 0 0;
    }

    .logout-button:hover {
        color: #dc2626;
    }

    /* Main */
    .admin-main {
        flex: 1;
        display: flex;
        flex-direction: column;
        min-width: 0;
    }

    /* Topbar */
    .admin-topbar {
        height: 60px;
        background: var(--surface);
        border-bottom: 1px solid var(--border);
        display: flex;
        align-items: center;
        justify-content: space-between;
        padding: 0 32px;
        position: sticky;
        top: 0;
        z-index: 50;
    }

    .topbar-title {
        font-size: 15px;
        font-weight: 700;
        color: var(--text);
    }

    .topbar-right {
        display: flex;
        align-items: center;
        gap: 16px;
    }

    .topbar-badge {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        background: var(--primary-lt);
        color: var(--primary-dk);
        border-radius: 100px;
        padding: 5px 14px;
        font-size: 12px;
        font-weight: 700;
    }

    /* Content */
    .admin-content {
        flex: 1;
        padding: 32px;
    }

    /* Responsive */
    @media (max-width: 768px) {
        .admin-sidebar { display: none; }
        .admin-content { padding: 20px; }
        .admin-topbar  { padding: 0 20px; }
    }
    </style>
</head>
<body>

<div class="admin-wrapper">

    {{-- SIDEBAR --}}
    <aside class="admin-sidebar">
        <div class="sidebar-brand">
            <div class="logo">reserv</div>
            <p>Admin Panel</p>
        </div>

        <nav class="sidebar-nav">
            <span class="sidebar-label">Menu</span>

            <a href="/admin" class="sidebar-link {{ request()->is('admin') ? 'active' : '' }}">
                <span class="icon">🏠</span> Dashboard
            </a>

            <span class="sidebar-label">Manajemen</span>

            <a href="/admin/analytics" class="sidebar-link {{ request()->is('admin/analytics') ? 'active' : '' }}">
                <span class="icon">🧠</span> AI Analytics
            </a>

            <a href="/admin/users" class="sidebar-link {{ request()->is('admin/users') ? 'active' : '' }}">
                <span class="icon">👤</span> Users
            </a>

            <a href="/admin/fields" class="sidebar-link {{ request()->is('admin/fields') ? 'active' : '' }}">
                <span class="icon">🏟️</span> Fields
            </a>

            <a href="/admin/slots" class="sidebar-link {{ request()->is('admin/slots') ? 'active' : '' }}">
                <span class="icon">🕐</span> Slots
            </a>

            <a href="/admin/schedules" class="sidebar-link {{ request()->is('admin/schedules') ? 'active' : '' }}">
            <span class="icon">📅</span> Schedules
            </a>

            <a href="/admin/bookings" class="sidebar-link {{ request()->is('admin/bookings') ? 'active' : '' }}">
                <span class="icon">📋</span> Bookings
            </a>

            <a href="/admin/payments" class="sidebar-link {{ request()->is('admin/payments') ? 'active' : '' }}">
                <span class="icon">💳</span> Payments
            </a>
        </nav>

        <div class="sidebar-footer">
            <a href="/">
                <span>🔙</span> Kembali ke Website
            </a>
            <form method="POST" action="{{ route('logout') }}" class="logout-form">
                @csrf
                <button type="submit" class="logout-button">
                    <span>Keluar</span>
                </button>
            </form>
        </div>
    </aside>

    {{-- MAIN --}}
    <div class="admin-main">

        {{-- TOPBAR --}}
        <div class="admin-topbar">
            <span class="topbar-title">@yield('title')</span>
            <div class="topbar-right">
                <span class="topbar-badge">⚡ E-ReservLap</span>
            </div>
        </div>

        {{-- CONTENT --}}
        <div class="admin-content">
            @yield('content')
        </div>

    </div>
</div>

<script src="{{ asset('js/script.js') }}"></script>
</body>
</html>
