# 📱 SJ Order App - Sistem Pemesanan Fasilitas Kantor

<div align="center">

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)
![Flutter](https://img.shields.io/badge/Flutter-3.11.0+-success.svg)
![Laravel](https://img.shields.io/badge/Laravel-10.x+-red.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)

**Aplikasi mobile untuk memesan ruangan dan kendaraan kantor dengan sistem validasi jadwal otomatis dan alur approval berlapis.**

[📲 Download APK](#installation) • [📖 Dokumentasi](#dokumentasi) • [🐛 Report Bug](#support) • [💡 Request Feature](#support)

</div>

---

## 🎯 Fitur Utama

### ✨ Fitur Pemesanan
- **Booking Ruangan & Kendaraan** - Pesan fasilitas kantor dengan interface yang user-friendly
- **Smart Schedule Validation** - Sistem otomatis mencegah double-booking (jam bentrok)
- **Buffer Time 30 Menit** - Jeda minimal 30 menit sebelum & sesudah booking untuk setup/cleanup
- **Real-time Availability** - Lihat ketersediaan fasilitas secara real-time
- **Booking Code** - Setiap booking mendapat kode unik untuk tracking
- **Multiple Booking Types** - Support untuk ruangan meeting, kendaraan operasional, dll

### 🔐 Sistem Approval Berlapis
- **Approval by Division Lead** - Persetujuan dari pemimpin divisi
- **Final Approval by GA (General Affairs)** - Konfirmasi akhir dari departemen GA
- **Status Tracking** - Pantau status booking dari pending hingga approved
- **Rejection Management** - Jika ditolak, karyawan bisa submit ulang

### 📊 Admin Features
- **Manage Ruangan** - Tambah/edit/hapus data ruangan kantor
- **Manage Kendaraan** - Manage data kendaraan operasional
- **View All Bookings** - Dashboard lengkap semua pemesanan
- **Approval Dashboard** - Kelola approval untuk divisi
- **Reports & Analytics** - Laporan penggunaan fasilitas

### 🔔 Notifikasi & Alerts
- **Real-time Notifications** - Notifikasi instant ketika booking dikonfirmasi/ditolak
- **Schedule Alerts** - Alert otomatis untuk booking yang akan dimulai
- **Conflict Warnings** - Peringatan jika memilih jadwal yang bentrok

### 👥 User Roles
- **Karyawan** - Bisa membuat booking fasilitas
- **Division Lead** - Approve/reject booking dari divisinya
- **General Affairs (GA)** - Final approval untuk semua booking
- **Admin** - Full access, manage sistem

---

## 🏗️ Struktur Aplikasi

```
sj_order_app/
├── lib/
│   ├── main.dart                          # Entry point aplikasi
│   ├── models/                            # Data models
│   │   ├── booking_model.dart
│   │   ├── room_model.dart
│   │   ├── vehicle_model.dart
│   │   └── user_model.dart
│   ├── screens/                           # UI Screens
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   └── register_screen.dart
│   │   ├── booking/
│   │   │   ├── create_booking_screen.dart
│   │   │   ├── booking_list_screen.dart
│   │   │   └── booking_detail_screen.dart
│   │   ├── approval/
│   │   │   ├── approval_list_screen.dart
│   │   │   └── approval_detail_screen.dart
│   │   └── admin/
│   │       ├── room_management_screen.dart
│   │       ├── vehicle_management_screen.dart
│   │       └── dashboard_screen.dart
│   ├── widgets/                           # Reusable widgets
│   │   ├── booking_time_picker_widget.dart
│   │   ├── facility_selection_widget.dart
│   │   └── approval_card_widget.dart
│   ├── services/                          # API services
│   │   ├── api_service.dart
│   │   ├── auth_service.dart
│   │   └── booking_service.dart
│   ├── providers/                         # State management
│   │   ├── auth_provider.dart
│   │   ├── booking_provider.dart
│   │   └── approval_provider.dart
│   └── utils/                             # Utilities
│       ├── constants.dart
│       ├── validators.dart
│       └── date_time_utils.dart
├── android/                               # Android native code
├── ios/                                   # iOS native code
├── pubspec.yaml                           # Project dependencies
└── README.md                              # Dokumentasi ini
```

---

## 🚀 Quick Start

### Prerequisites
Pastikan sudah terinstall:
- **Flutter SDK** (v3.11.0 atau lebih tinggi)
  - [Download Flutter](https://flutter.dev/docs/get-started/install)
- **Android Studio** atau **VS Code**
- **Dart** (included dengan Flutter)
- **PHP & Laravel** untuk backend
  - [Download PHP](https://www.php.net/downloads)
  - [Laravel Documentation](https://laravel.com/docs)

### 1️⃣ Persiapan Backend (Laravel)

```bash
# Clone atau copy backend project
cd C:\laravel-project\sj-order-api

# Install dependencies
composer install

# Copy .env file
copy .env.example .env

# Generate app key
php artisan key:generate

# Konfigurasi database di .env
# DB_HOST=127.0.0.1
# DB_PORT=3306
# DB_DATABASE=sj_order_db
# DB_USERNAME=root
# DB_PASSWORD=

# Run migrations
php artisan migrate

# Generate Sanctum tokens (untuk API authentication)
php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider"

# Start Laravel server
php artisan serve
# Server running di: http://127.0.0.1:8000
```

### 2️⃣ Setup Flutter Project

```bash
# Navigate ke project directory
cd C:\Users\dimas\AndroidStudioProjects\sj_order_app

# Install Flutter dependencies
flutter pub get

# Update dependencies jika diperlukan
flutter pub upgrade
```

### 3️⃣ Konfigurasi API URL

Buka file `lib/services/api_service.dart` dan sesuaikan:

```dart
class ApiService {
  // Ganti dengan URL backend Anda
  static const String baseUrl = 'http://192.168.1.100:8000/api';
  // atau untuk localhost: 'http://10.0.2.2:8000/api' (Android Emulator)
}
```

### 4️⃣ Jalankan Aplikasi

```bash
# List available devices
flutter devices

# Run on Android Emulator
flutter run

# Run dengan mode release (lebih cepat)
flutter run --release

# Run dengan specific device
flutter run -d <device-id>
```

---

## 📲 Cara Menggunakan Aplikasi

### 🔓 Login
1. Buka aplikasi
2. Masukkan email dan password karyawan
3. Tap "Login"
4. Sistem akan mengecek role Anda secara otomatis

### 📅 Membuat Booking Baru

1. **Tap "Buat Booking"** di home screen
2. **Pilih Jenis Fasilitas**
   - Ruangan (Meeting Room, Training Room, dll)
   - Kendaraan (Mobil Operasional, Minibus, dll)
3. **Pilih Fasilitas Spesifik**
   - Lihat daftar ruangan/kendaraan yang tersedia
4. **Pilih Tanggal & Waktu**
   - Calendar picker untuk memilih tanggal
   - Time picker untuk jam mulai dan selesai
   - Sistem otomatis validasi ketersediaan
5. **Isi Detail Booking**
   - Tujuan penggunaan
   - Jumlah peserta
   - Catatan khusus (jika ada)
6. **Review & Submit**
   - Cek ulang data
   - Tap "Ajukan Booking"

### ⏳ Tracking Status Booking

1. **Buka "Riwayat Booking"**
2. **Lihat Status:**
   - 🟡 **Pending Division** - Menunggu approval Division Lead
   - 🟡 **Pending GA** - Sudah disetujui divisi, tunggu GA
   - 🟢 **Approved** - Approved! Siap digunakan
   - 🔴 **Rejected** - Ditolak, lihat alasan ditolak
3. **Tap booking untuk melihat detail lengkap**

### 👤 Admin Panel

1. **Login dengan akun admin**
2. **Menu Admin:**
   - **Manajemen Ruangan** - Tambah/edit/hapus ruangan
   - **Manajemen Kendaraan** - Atur data kendaraan
   - **Dashboard** - Lihat statistik penggunaan
   - **Approval** - Review semua booking untuk approval

---

## 🔧 Konfigurasi & Setup Lanjutan

### Database Schema

**Tabel: bookings**
```sql
- id (Primary Key)
- booking_code (Unique)
- user_id (Foreign Key -> users)
- division_id (Foreign Key -> divisions)
- booking_type (room/vehicle)
- room_id (nullable, Foreign Key -> rooms)
- vehicle_id (nullable, Foreign Key -> vehicles)
- booking_date (DATE)
- start_time (TIME)
- end_time (TIME)
- purpose (TEXT)
- participants_count (INT)
- destination (VARCHAR, untuk vehicle)
- status (pending_division/pending_ga/approved/rejected_division/rejected_ga)
- division_approval_by (Foreign Key -> users)
- division_approval_at (TIMESTAMP)
- division_approval_notes (TEXT)
- ga_approval_by (Foreign Key -> users)
- ga_approval_at (TIMESTAMP)
- ga_approval_notes (TEXT)
- rejection_reason (TEXT)
- created_at & updated_at (TIMESTAMPS)
```

**Tabel: rooms**
```sql
- id (Primary Key)
- name (VARCHAR)
- capacity (INT) - jumlah maksimal peserta
- location (VARCHAR)
- is_active (BOOLEAN)
- created_at & updated_at
```

**Tabel: vehicles**
```sql
- id (Primary Key)
- name (VARCHAR) - e.g., "Mobil Operasional 1"
- license_plate (VARCHAR) - nomor polisi
- capacity (INT) - jumlah penumpang
- vehicle_type (VARCHAR) - Mobil, Minibus, Truck, dll
- is_active (BOOLEAN)
- created_at & updated_at
```

### Validasi Schedule

Fitur **Smart Schedule Validation** bekerja dengan logika:

1. ✅ Tidak boleh ada 2 booking dengan **jam & fasilitas yang sama**
2. ✅ Perlu **jeda minimal 30 menit** sebelum & sesudah booking
3. ✅ Hanya check booking yang **sudah approved** (pending tidak dihitung)

**Contoh:**
- ✅ Booking 1: 09:00-10:00 → Boleh booking 2: 10:30-11:30 (jeda 30 menit)
- ❌ Booking 1: 09:00-10:00 → Tidak boleh booking 2: 10:15-11:00 (jeda kurang)
- ❌ Booking 1: 09:00-10:00 → Tidak boleh booking 2: 09:30-10:30 (overlap)

---

## 📱 Teknologi yang Digunakan

### Frontend (Flutter)
| Teknologi | Versi | Fungsi |
|-----------|-------|--------|
| Flutter | 3.11.0+ | Framework mobile |
| Dart | 3.11.0+ | Programming language |
| Provider | 6.1.0 | State management |
| HTTP | 1.1.0 | HTTP client untuk API |
| Shared Preferences | 2.2.2 | Local storage |
| Intl | 0.19.0 | Internationalization & formatting |

### Backend (Laravel)
| Teknologi | Fungsi |
|-----------|--------|
| Laravel | Web framework |
| PHP 8+ | Server-side language |
| MySQL/MariaDB | Database |
| Laravel Sanctum | API authentication |
| Carbon | Date/time handling |

---

## 🔐 Security Features

✅ **Token-based Authentication** - Menggunakan Laravel Sanctum  
✅ **Input Validation** - Validasi di frontend dan backend  
✅ **Authorization Checks** - Role-based access control  
✅ **HTTPS Support** - Production-ready SSL encryption  
✅ **CORS Configuration** - Secure cross-origin requests  
✅ **SQL Injection Prevention** - Parameterized queries  

---

## 🐛 Troubleshooting

### ❌ Error: "Failed to connect to server"
```
Solusi:
1. Pastikan Laravel server sedang berjalan (php artisan serve)
2. Cek API_URL di lib/services/api_service.dart
3. Untuk Android Emulator, gunakan: http://10.0.2.2:8000/api
4. Untuk Physical Device, gunakan IP lokal: http://192.168.x.x:8000/api
5. Cek firewall/antivirus yang mungkin memblokir koneksi
```

### ❌ Error: "Undefined class 'Timer'"
```
Solusi:
Tambahkan import di file yang bermasalah:
import 'dart:async';
```

### ❌ Error: "Named parameters outside group"
```
Solusi:
Pastikan named parameters di function dibungkus dengan kurung kurawal {}
Contoh:
// ❌ Salah
void booking(String name, int age, {String? notes)

// ✅ Benar
void booking(String name, int age, {String? notes})
```

### ❌ Booking Masih Bisa Bentrok (Double-Booking)
```
Solusi:
1. Pastikan BookingScheduleValidator.php sudah di-import di controller
2. Validasi dilakukan sebelum save:
   $validation = $this->isTimeSlotAvailable([
       'booking_type' => $request->booking_type,
       'booking_date' => $request->booking_date,
       'start_time' => $request->start_time,
       'end_time' => $request->end_time,
       'room_id' => $request->room_id,
       'vehicle_id' => $request->vehicle_id,
   ]);
   
   if (!$validation['available']) {
       return response()->json(['error' => $validation['message']], 422);
   }
3. Cek database untuk memastikan booking tersimpan dengan benar
```

### ❌ Approval Tidak Berfungsi
```
Solusi:
1. Pastikan user yang login memiliki role 'division_lead' atau 'ga'
2. Cek tabel bookings, status harus 'pending_division' atau 'pending_ga'
3. Backend endpoint untuk approval:
   PATCH /api/bookings/{id}/approve
   PATCH /api/bookings/{id}/reject
4. Validasi response dari server
```

---

## 📦 Build & Deploy

### Build APK Release

```bash
# Build APK untuk production
flutter build apk --release

# File output: build/app/outputs/flutter-apk/app-release.apk

# Build App Bundle (untuk Google Play Store)
flutter build appbundle --release
# File output: build/app/outputs/bundle/release/app-release.aab
```

### Deploy ke Device/Emulator

```bash
# Install ke connected device
flutter install

# Run di background
flutter run --release &
```

---

## 🤝 Contributing

Kami terbuka untuk kontribusi! Silakan:

1. Fork repository
2. Buat feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push ke branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📝 API Documentation

### Authentication
```
POST /api/auth/login
Body: {
  "email": "user@example.com",
  "password": "password123"
}
Response: {
  "token": "...",
  "user": {...}
}
```

### Create Booking
```
POST /api/bookings
Headers: Authorization: Bearer {token}
Body: {
  "booking_type": "room",
  "room_id": 1,
  "booking_date": "2026-04-10",
  "start_time": "09:00",
  "end_time": "10:00",
  "purpose": "Meeting",
  "participants_count": 5
}
```

### Get Available Slots
```
GET /api/bookings/available-slots?booking_type=room&facility_id=1&booking_date=2026-04-10
Response: {
  "available_slots": [...],
  "busy_slots": [...],
  "operating_hours": {...}
}
```

### Approve Booking
```
PATCH /api/bookings/{id}/approve
Headers: Authorization: Bearer {token}
Body: {
  "notes": "Disetujui"
}
```

---

## 📞 Support & Feedback

Punya pertanyaan atau ditemukan bug?

- 📧 Email: support@sj-order-app.com
- 🐛 GitHub Issues: [Report Bug](https://github.com/dimashendripamungkas45-ux/sj-order-app/issues)
- 💬 Discussions: [Join Discussion](https://github.com/dimashendripamungkas45-ux/sj-order-app/discussions)

---

## 📄 License

Project ini dilisensikan di bawah **MIT License** - lihat file [LICENSE](LICENSE) untuk detail.

---

## 👨‍💻 Author

**Dimas Hendri Pamungkas**
- GitHub: [@dimashendripamungkas45-ux](https://github.com/dimashendripamungkas45-ux)
- Email: dimashendripamungkas@example.com

---

## 🙏 Acknowledgments

Terima kasih kepada:
- **Flutter Community** - untuk dokumentasi dan dukungan luar biasa
- **Laravel Community** - untuk framework yang robust
- **Team** - untuk feedback dan testing

---

<div align="center">

**Made with ❤️ by Dimas Hendri Pamungkas** <br>
✨ Special thanks to my support system: **Putri Naila** ✨
<br>
[⬆ Kembali ke Atas](#-sj-order-app---sistem-pemesanan-fasilitas-kantor)

</div>

