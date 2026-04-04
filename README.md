# E-ReservLap — Flutter (User App)

Aplikasi mobile untuk user melakukan reservasi lapangan olahraga.

## Struktur lib/

```
lib/
├── main.dart                        # Entry point + Splash Screen
│
├── theme/
│   └── app_theme.dart               # Warna & tema global
│
├── models/                          # 5 Entitas
│   ├── user.dart                    # Entitas User
│   ├── field.dart                   # Entitas Field (Lapangan)
│   ├── schedule.dart                # Entitas Schedule (Jadwal)
│   ├── booking.dart                 # Entitas Booking
│   └── payment.dart                 # Entitas Payment
│
├── services/                        # Koneksi ke backend Laravel
│   ├── api_service.dart             # Base HTTP client (ganti BASE_URL)
│   ├── auth_service.dart            # Login, register, logout
│   ├── field_service.dart           # Get lapangan & jadwal
│   ├── booking_service.dart         # Buat & lihat booking
│   └── payment_service.dart         # Buat & upload bukti bayar
│
├── widgets/
│   ├── common_widgets.dart          # Widget reusable (Button, InfoRow, dll)
│   └── field_card.dart              # Card lapangan
│
└── screens/
    ├── home_screen.dart             # Beranda
    ├── fields_screen.dart           # Daftar lapangan + search
    ├── booking_screen.dart          # Form booking + kalkulasi harga
    ├── payment_screen.dart          # Pilih metode + upload bukti
    └── status_screen.dart           # Riwayat & status booking
```

## 5 Entitas & Relasi

```
User ──────< Booking >────── Field
                │               │
              Payment        Schedule
```

| Entitas  | Tabel Laravel     | Keterangan                        |
|----------|-------------------|-----------------------------------|
| User     | users             | Data pengguna aplikasi            |
| Field    | fields            | Data lapangan olahraga            |
| Schedule | schedules         | Jadwal buka/tutup tiap lapangan   |
| Booking  | bookings          | Transaksi reservasi               |
| Payment  | payments          | Data pembayaran per booking       |

## Setup

```bash
# 1. Copy folder lib/ ke project Flutter kamu
# 2. Tambahkan dependency di pubspec.yaml
flutter pub get

# 3. Jalankan
flutter run
```

## Cara Sambung ke Laravel (untuk teman backend)

Buka file `lib/services/api_service.dart`, ganti BASE_URL:

```dart
static const String baseUrl = 'http://127.0.0.1:8000/api';
// ganti dengan URL server Laravel
// contoh: 'https://e-reservlap.com/api'
```

Lalu di setiap file `*_service.dart`, uncomment bagian HTTP call
dan hapus/comment bagian dummy data.

### Endpoint yang dibutuhkan dari Laravel:

| Method | Endpoint                        | Keterangan               |
|--------|---------------------------------|--------------------------|
| POST   | /api/login                      | Login user               |
| POST   | /api/register                   | Register user            |
| POST   | /api/logout                     | Logout                   |
| GET    | /api/user                       | Profil user login        |
| GET    | /api/fields                     | Semua lapangan           |
| GET    | /api/fields/{id}                | Detail lapangan          |
| GET    | /api/fields/{id}/schedules      | Jadwal lapangan          |
| POST   | /api/bookings                   | Buat booking baru        |
| GET    | /api/bookings                   | Booking milik user       |
| GET    | /api/bookings/{id}              | Detail booking           |
| POST   | /api/payments                   | Buat payment             |
| POST   | /api/payments/{id}/upload-proof | Upload bukti bayar       |

### Format Response Laravel (JSON):

```json
{
  "status": "success",
  "message": "...",
  "data": { ... }
}
```

## Dependency

| Package         | Kegunaan                    |
|-----------------|-----------------------------|
| `http ^1.2.0`   | HTTP request ke Laravel API |
| `cupertino_icons` | Icon iOS style            |
