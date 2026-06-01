# 🏟️ E-Reserv: Sports Field Booking System

E-Reserv adalah sistem reservasi lapangan olahraga digital modern terintegrasi yang dirancang untuk mempermudah pengguna memesan berbagai jenis lapangan (Futsal, Badminton, Basket, dll.) secara langsung, serta memudahkan administrator dalam mengelola jadwal lapangan melalui panel admin berbasis web.

Proyek ini terdiri dari dua komponen utama:
1. **Backend & Admin Panel (`E_ReservLap_admin/`)**: API backend dan panel monitoring admin yang dibangun menggunakan framework **Laravel 11**.
2. **Mobile Client (`E-Reserv/`)**: Aplikasi mobile multiplatform yang dibangun menggunakan **Flutter** dengan tampilan premium bergaya *sporty-tech* dan performa responsif.

---

## 🚀 Fitur Utama Sistem

Sistem ini telah dioptimalkan secara mendalam dengan fitur-fitur tingkat lanjut:
* **Autentikasi Aman & Selaras**: Alur pendaftaran dan login yang aman (Laravel Sanctum), diselaraskan antara validasi minimal 6 karakter di sisi Flutter dan backend. Dilengkapi *null-guard safety* untuk mencegah kegagalan login akibat salah email.
* **Pemesanan Berbasis Durasi Jam**: Alur baru di mana pengguna memilih jam mulai dan menentukan durasi jam sewa secara fleksibel. Waktu selesai (`end_time`) dihitung secara otomatis oleh sistem.
* **Perhitungan Harga Otomatis & Dinamis**: Total harga sewa dihitung otomatis di sisi backend dan frontend menggunakan formula: `Total = Tarif Lapangan per Jam × Durasi Sewa × Jumlah Orang`.
* **Manajemen Sisa Kapasitas Real-time**: Kapasitas slot dihitung langsung (*live*) dengan menjumlahkan kuota pesanan berstatus *approved* dan *pending* untuk mencegah pemesanan berlebih (*overcapacity*).
* **Indikator Ketersediaan Lapangan**: Slot jam yang sudah penuh terisi otomatis berwarna merah dan dikunci (`(Penuh)`) di aplikasi client, sehingga tidak dapat dipilih oleh pengguna lain.
* **Pemisahan Riwayat Aman (Token-based)**: Riwayat pemesanan disaring secara aman berdasarkan token pengguna yang masuk. Pengguna biasa hanya dapat melihat riwayatnya sendiri, sementara web admin tetap dapat memonitor seluruh pemesanan.
* **Filter Carousel Kategori Lapangan**: Menu penyaring horisontal interaktif yang memungkinkan pencarian lapangan secara instan berdasarkan olahraga favorit di halaman Beranda dan Daftar Lapangan.
* **Layar Detail Imersif**: Dilengkapi spanduk gambar imersif, kartu detail melayang, timeline tanggal horisontal, serta laci ringkasan biaya bergaya struk belanja.

---

## 📁 Struktur Repositori

```text
E-Reserv/ (Root)
├── E-Reserv/              # Kode Program Aplikasi Flutter (Frontend)
└── E_ReservLap_admin/     # Kode Program API & Web Admin Laravel (Backend)
```

---

## 🛠️ Panduan Instalasi & Setup

Ikuti langkah-langkah di bawah ini untuk menjalankan proyek ini di lingkungan lokal Anda.

### 1. Setup Backend (Laravel 12)

#### Persyaratan Sistem
* PHP >= 8.2
* Composer
* MySQL Database

#### Langkah Setup:
1. Masuk ke direktori backend:
   ```bash
   cd E_ReservLap_admin
   ```
2. Instal dependensi PHP menggunakan Composer:
   ```bash
   composer install
   ```
3. Salin file konfigurasi lingkungan `.env`:
   ```bash
   copy .env.example .env
   ```
4. Buat database kosong bernama `e-reserv` di MySQL Anda, lalu sesuaikan konfigurasi database Anda di dalam file `.env`:
   ```env
   DB_CONNECTION=mysql
   DB_HOST=127.0.0.1
   DB_PORT=3306
   DB_DATABASE=e-reserv
   DB_USERNAME=root
   DB_PASSWORD=
   ```
5. Generate application key:
   ```bash
   php artisan key:generate
   ```
6. Jalankan migrasi database beserta data awal (seeder):
   ```bash
   php artisan migrate --seed
   ```
7. **[SANGAT PENTING]** Hubungkan folder storage Laravel ke public folder agar foto lapangan dapat diakses oleh aplikasi Flutter:
   ```bash
   php artisan storage:link
   ```
8. Jalankan server lokal Laravel:
   ```bash
   php artisan serve
   ```
   *Secara default server akan berjalan pada alamat `http://localhost:8000`.*

---

### 2. Setup Frontend (Flutter)

#### Persyaratan Sistem
* Flutter SDK (versi terbaru direkomendasikan)
* Android Studio / VS Code dengan Flutter plugin
* Koneksi internet untuk mengambil paket pub

#### Langkah Setup:
1. Masuk ke direktori frontend:
   ```bash
   cd E-Reserv
   ```
2. Ambil paket dependensi Dart/Flutter:
   ```bash
   flutter pub get
   ```
3. Jalankan aplikasi pada perangkat pilihan Anda (Web Chrome, Emulator Android, atau Windows Desktop):
   ```bash
   flutter run
   ```

---

## 📝 Catatan Penting untuk yang Mengekloning Repositori

Jika Anda baru saja menduplikasi (*clone*) proyek ini, perhatikan catatan-catatan teknis berikut agar sistem berjalan tanpa hambatan:

### 1. Pemuatan Gambar Lapangan Lokal
Karena gambar-gambar lapangan dalam seeder menggunakan path penyimpanan lokal Laravel (seperti `images/futsal_international.jpg`), gambar tersebut memerlukan file fisik di server.
* **Langkah agar Gambar Lapangan Muncul**: 
  Silakan buat direktori `storage/app/public/images/` di proyek Laravel Anda, lalu masukkan file foto lapangan dengan nama yang sesuai di dalam folder tersebut:
  * `futsal_international.jpg`
  * `futsal_standard.jpg`
  * `badminton_1.jpg`
  * `badminton_2.jpg`
  * `basket.jpg`
* Jika file fisik tersebut belum ada di folder storage, aplikasi Flutter secara otomatis akan menampilkan emoji olahraga yang manis sebagai cadangan (*fallback*).

### 2. Alamat IP untuk Emulator Android (`10.0.2.2`)
* Jika Anda menguji aplikasi Flutter menggunakan **Emulator Android**, emulator tidak akan bisa mengakses server backend menggunakan kata kunci `localhost` (karena merujuk pada dirinya sendiri).
* Sistem ini **sudah dikonfigurasi secara cerdas** untuk mendeteksi platform:
  * Pada **Android Emulator**, API request dan pemuatan gambar akan otomatis diarahkan ke **`http://10.0.2.2:8000`**.
  * Pada **Web Chrome / Windows Desktop**, ia akan otomatis diarahkan ke **`http://localhost:8000`**.
  * Konfigurasi ini aman dan bebas dari crash tipe *web platform evaluation check* (`kIsWeb` guard diimplementasikan untuk mencegah kegagalan `Platform` check di browser).

### 3. Akun Pengguna Default (Hasil Seeder)
Anda dapat menggunakan akun-akun bawaan berikut setelah berhasil menjalankan perintah `--seed` pada Laravel:
* **Admin Web Dashboard**:
  * Email: `admin@gmail.com`
  * Password: `password` (Akses eksklusif melalui Panel Admin Web Laravel)
* **User Mobile App**:
  * Anda dapat melakukan pendaftaran (registrasi) akun baru secara langsung dari aplikasi Flutter, atau menggunakan data user lain yang terdaftar di tabel `users`.
