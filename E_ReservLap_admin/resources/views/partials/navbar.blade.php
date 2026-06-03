<nav class="navbar">
    <div class="logo">reserv</div>
    <ul class="nav-links">
        <li><a href="/">Home</a></li>
        <li><a href="/about">About</a></li>
        <li><a href="/contact">Contact</a></li>
        <li><a href="/features">Features</a></li>
        @auth
            <li><a href="/dashboard" class="btn btn-primary" style="padding:7px 18px;font-size:14px">Dashboard</a></li>
        @else
            <li><a href="{{ route('login') }}" class="btn btn-primary" style="padding:7px 18px;font-size:14px">Masuk</a></li>
        @endauth
    </ul>
</nav>
