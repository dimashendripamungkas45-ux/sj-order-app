# 📚 MANUAL BOOK - SJ Order App
## Panduan Lengkap Penggunaan Aplikasi Pemesanan Fasilitas Kantor

---

## 📑 Daftar Isi
1. [Instalasi & Setup](#instalasi--setup)
2. [Login & Autentikasi](#login--autentikasi)
3. [Dashboard Utama](#dashboard-utama)
4. [Membuat Booking](#membuat-booking)
5. [Manajemen Booking](#manajemen-booking)
6. [Approval Workflow](#approval-workflow)
7. [Admin Features](#admin-features)
8. [FAQ & Troubleshooting](#faq--troubleshooting)

---

## 🔧 Instalasi & Setup

### Langkah 1: Download Aplikasi

#### Opsi A: Install dari APK (Recommended)
1. Download file `app-release.apk` dari GitHub releases
2. Transfer ke Android phone Anda
3. Buka file manager → Cari file APK
4. Tap file → Tap "Install"
5. Tunggu proses instalasi selesai

#### Opsi B: Build dari Source
```bash
# 1. Clone repository
git clone https://github.com/dimashendripamungkas45-ux/sj-order-app.git

# 2. Navigate ke folder
cd sj_order_app

# 3. Install dependencies
flutter pub get

# 4. Run aplikasi
flutter run --release
```

### Langkah 2: Koneksi Server

Sebelum membuka aplikasi, pastikan:
- ✅ Backend Laravel server sudah running (`php artisan serve`)
- ✅ Smartphone connected ke internet / WiFi yang sama dengan server
- ✅ Firewall tidak memblokir koneksi

---

## 🔐 Login & Autentikasi

### Login Pertama Kali

#### Step 1: Buka Aplikasi
- Tap icon aplikasi "SJ Order App" di home screen
- Aplikasi akan loading sebentar
- Anda akan diarahkan ke halaman **Login**

#### Step 2: Masukkan Credentials
```
┌─────────────────────────────┐
│    SJ ORDER APP - LOGIN     │
├─────────────────────────────┤
│                             │
│  📧 Email                   │
│  ├─────────────────────────┤
│  │ karyawan@example.com    │
│                             │
│  🔐 Password               │
│  ├─────────────────────────┤
│  │ ••••••••••              │
│                             │
│  [    LOGIN    ]            │
│                             │
│  Belum punya akun?          │
│  [ DAFTAR ]                 │
└─────────────────────────────┘
```

**Email Contoh Untuk Testing:**
| Role | Email | Password |
|------|-------|----------|
| Karyawan | karyawan@example.com | password123 |
| Division Lead | division@example.com | password123 |
| GA (General Affairs) | ga@example.com | password123 |
| Admin | admin@example.com | password123 |

#### Step 3: Tap "LOGIN"
- Sistem akan validasi credentials ke server
- Jika valid → Auto-detect role dan redirect ke dashboard
- Jika invalid → Tampil pesan error (cek email/password)

#### Step 4: Lanjut ke Dashboard
- Setelah login sukses, anda akan dibawa ke halaman utama sesuai role
- Token authentication disimpan secara aman di device

### Logout
```
Menu → Settings/Pengaturan → Logout
atau
Profile → Tap avatar → Logout
```

---

## 🏠 Dashboard Utama

### Dashboard Karyawan

```
┌──────────────────────────────┐
│        DASHBOARD ANDA        │
├──────────────────────────────┤
│                              │
│  Halo, Dimas Hendri! 👋      │
│  Division: IT Department     │
│                              │
├──────────────────────────────┤
│  QUICK MENU                  │
│                              │
│  ┌──────────┐  ┌──────────┐ │
│  │ 🏢       │  │ 🚗       │ │
│  │ BOOKING  │  │ BOOKING  │ │
│  │ RUANGAN  │  │ KENDARAAN│ │
│  └──────────┘  └──────────┘ │
│                              │
├──────────────────────────────┤
│  STATISTIK BOOKING ANDA      │
│                              │
│  Total Booking: 5            │
│  Approved: 4 ✅             │
│  Pending: 1 ⏳              │
│  Rejected: 0 ❌             │
│                              │
├──────────────────────────────┤
│  BOOKING TERBARU             │
│                              │
│  1. Meeting Room 1           │
│     2026-04-10 09:00-10:00   │
│     Status: ✅ Approved      │
│                              │
│  2. Mobil Operasional        │
│     2026-04-08 10:00-12:00   │
│     Status: ⏳ Pending GA    │
│                              │
├──────────────────────────────┤
│  BOTTOM NAVIGATION           │
│  [🏠Home][📋List][👤Profile]│
└──────────────────────────────┘
```

### Menu Utama Karyawan:
- 🏢 **Booking Ruangan** - Pesan ruangan meeting
- 🚗 **Booking Kendaraan** - Pesan kendaraan kantor
- 📋 **Riwayat Booking** - Lihat semua booking Anda
- ⚙️ **Pengaturan** - Settings & profile

---

## 📅 Membuat Booking

### Workflow Booking Ruangan

#### STEP 1️⃣: Pilih Jenis Fasilitas

```
┌──────────────────────────────┐
│    PILIH JENIS FASILITAS     │
├──────────────────────────────┤
│                              │
│  ◯ RUANGAN (Meeting Room)   │  ← Pilih ini
│  ◯ KENDARAAN (Vehicle)      │
│                              │
│  [  LANJUT  ]                │
└──────────────────────────────┘
```

**Penjelasan:**
- **Ruangan**: Untuk meeting, training, workshop
- **Kendaraan**: Untuk transportasi, antar barang, kunjungan

---

#### STEP 2️⃣: Pilih Fasilitas Spesifik

Jika memilih **RUANGAN**:

```
┌──────────────────────────────┐
│   PILIH RUANGAN              │
├──────────────────────────────┤
│                              │
│  Fasilitas Tersedia:         │
│                              │
│  ☑️ Meeting Room 1           │
│     Kapasitas: 10 orang      │
│     Lokasi: Lantai 2         │
│     Status: ✅ Tersedia      │
│                              │
│  ☐ Meeting Room 2           │
│     Kapasitas: 20 orang      │
│     Lokasi: Lantai 3         │
│     Status: ❌ Sedang Dipesan│
│                              │
│  ☐ Training Room            │
│     Kapasitas: 30 orang      │
│     Lokasi: Lantai 1         │
│     Status: ✅ Tersedia      │
│                              │
│  [  PILIH ROOM 1  ]          │
└──────────────────────────────┘
```

Jika memilih **KENDARAAN**:

```
┌──────────────────────────────┐
│   PILIH KENDARAAN            │
├──────────────────────────────┤
│                              │
│  Kendaraan Tersedia:         │
│                              │
│  ☑️ Mobil Operasional 1      │
│     Plat: B 1234 ABC         │
│     Tipe: Mobil MPV          │
│     Kapasitas: 7 orang       │
│     Status: ✅ Tersedia      │
│                              │
│  ☐ Mobil Operasional 2      │
│     Plat: B 5678 XYZ         │
│     Tipe: Mobil Sedan        │
│     Kapasitas: 5 orang       │
│     Status: ❌ Sedang Dipesan│
│                              │
│  [  PILIH MOBIL 1  ]         │
└──────────────────────────────┘
```

---

#### STEP 3️⃣: Pilih Tanggal Booking

```
┌──────────────────────────────┐
│   PILIH TANGGAL              │
├──────────────────────────────┤
│                              │
│  Fasilitas: Meeting Room 1   │
│                              │
│  📅 April 2026              │
│  ┌─────────────────────────┐ │
│  │ Min Sel Rab Kam Jum Sab│ │
│  │     1   2   3   4   5  │ │
│  │  6   7   8   9  10  11 │ │
│  │ 12  13  14  15  16  17 │ │
│  │ 18  19 [20] 21  22  23 │ │
│  │ 24  25  26  27  28  29 │ │
│  │ 30                      │ │
│  └─────────────────────────┘ │
│                              │
│  Tanggal dipilih: 20-04-2026 │
│                              │
│  [    LANJUT    ]            │
└──────────────────────────────┘
```

**Tips Memilih Tanggal:**
- ✅ Bisa pesan minimum 1 hari ke depan
- ✅ Maksimal pesan 30 hari ke depan
- ❌ Tidak bisa pesan tanggal yang sudah lewat
- ❌ Tidak bisa pesan hari libur nasional

---

#### STEP 4️⃣: Pilih Waktu (Smart Schedule Validator)

```
┌──────────────────────────────┐
│   PILIH WAKTU BOOKING        │
├──────────────────────────────┤
│                              │
│  Fasilitas: Meeting Room 1   │
│  Tanggal: 20-04-2026         │
│                              │
│  ⏰ JAM MULAI                 │
│  ┌─────────────────────────┐ │
│  │ 08:00 ✅ Tersedia      │ │
│  │ 08:30 ✅ Tersedia      │ │
│  │ 09:00 ✅ Tersedia      │ │
│  │ 09:30 ❌ Bentrok       │ │
│  │ 10:00 ❌ Bentrok       │ │
│  │ 10:30 ✅ Tersedia      │ │
│  │ 11:00 ✅ Tersedia      │ │
│  │ [SCROLL untuk lebih...]│ │
│  └─────────────────────────┘ │
│                              │
│  Jam Mulai dipilih: 08:00    │
│                              │
│  ⏰ JAM SELESAI              │
│  ┌─────────────────────────┐ │
│  │ 09:00 ✅ Tersedia      │ │
│  │ 09:30 ❌ Bentrok       │ │
│  │ 10:00 ❌ Bentrok       │ │
│  │ 10:30 ✅ Tersedia      │ │
│  │ 11:00 ✅ Tersedia      │ │
│  │ 11:30 ✅ Tersedia      │ │
│  │ 12:00 ✅ Tersedia      │ │
│  │ [SCROLL untuk lebih...]│ │
│  └─────────────────────────┘ │
│                              │
│  Jam Selesai dipilih: 09:00  │
│                              │
│  VALIDASI:                   │
│  ✅ Durasi: 1 jam           │
│  ✅ Tidak bentrok           │
│  ✅ Jeda 30 menit sebelum   │
│  ✅ Jeda 30 menit sesudah   │
│                              │
│  [    LANJUT    ]            │
└──────────────────────────────┘
```

**Penjelasan Smart Schedule:**
- 🟢 ✅ Jam **HIJAU** = Bisa dipesan (tersedia)
- 🔴 ❌ Jam **MERAH** = Tidak bisa dipesan (bentrok/sudah ada booking)
- ⏱️ **Jeda 30 Menit** = Otomatis ada gap untuk setup/cleanup

**Contoh Skenario:**
```
Booking existing: 09:30 - 10:00

Jam mulai yang BISA dipilih:
✅ 08:00 - 09:00 (selesai jam 9:00, jeda 30 menit OK)
✅ 10:30 - 11:30 (mulai jam 10:30, jeda 30 menit dari 10:00 OK)

Jam mulai yang TIDAK BISA dipilih:
❌ 09:00 - 10:00 (overlap dengan existing booking)
❌ 10:00 - 11:00 (hanya jeda 30 menit, tapi masih dihitung bentrok)
```

---

#### STEP 5️⃣: Isi Detail Booking

```
┌──────────────────────────────┐
│   DETAIL BOOKING             │
├──────────────────────────────┤
│                              │
│  📝 TUJUAN PENGGUNAAN *      │
│  ┌─────────────────────────┐ │
│  │ Meeting dengan klien    │ │
│  └─────────────────────────┘ │
│                              │
│  👥 JUMLAH PESERTA *         │
│  ┌─────────────────────────┐ │
│  │ 5 orang                 │ │
│  │ (Max: 10)               │ │
│  └─────────────────────────┘ │
│                              │
│  📍 TUJUAN (untuk kendaraan)  │
│  ┌─────────────────────────┐ │
│  │ Kantor Cilangkap        │ │
│  └─────────────────────────┘ │
│                              │
│  📌 CATATAN TAMBAHAN         │
│  ┌─────────────────────────┐ │
│  │ Mohon siapkan kopi      │ │
│  │ dan minuman             │ │
│  └─────────────────────────┘ │
│                              │
│  * = Wajib diisi             │
│                              │
│  [    LANJUT    ]            │
└──────────────────────────────┘
```

**Field Penjelasan:**

| Field | Wajib? | Contoh | Max Karakter |
|-------|--------|--------|--------------|
| Tujuan Penggunaan | ✅ Ya | "Meeting dengan klien" | 255 |
| Jumlah Peserta | ✅ Ya | 5 | Sesuai kapasitas |
| Tujuan (Vehicle) | ✅ Ya (kendaraan saja) | "Kantor Cilangkap" | 255 |
| Catatan | ❌ Tidak | "Siapkan proyektor" | 500 |

---

#### STEP 6️⃣: Review & Konfirmasi

```
┌──────────────────────────────┐
│   REVIEW BOOKING             │
├──────────────────────────────┤
│                              │
│  📋 RINGKASAN PEMESANAN      │
│                              │
│  Jenis Fasilitas:            │
│  🏢 RUANGAN                  │
│                              │
│  Fasilitas:                  │
│  Meeting Room 1              │
│  Kapasitas: 10 orang         │
│                              │
│  Tanggal & Waktu:            │
│  📅 20 April 2026            │
│  🕐 08:00 - 09:00            │
│  Durasi: 1 jam               │
│                              │
│  Tujuan:                     │
│  Meeting dengan klien        │
│                              │
│  Peserta:                    │
│  5 orang                     │
│                              │
│  Catatan:                    │
│  Siapkan kopi dan minuman    │
│                              │
├──────────────────────────────┤
│  STATUS: ✅ SIAP DIAJUKAN    │
│                              │
│  [❌ BATAL]  [✅ AJUKAN]     │
└──────────────────────────────┘
```

**Sebelum tap AJUKAN, pastikan:**
- ✅ Fasilitas yang dipilih benar
- ✅ Tanggal & waktu sudah benar
- ✅ Tidak ada bentrok
- ✅ Detail sudah lengkap

---

#### STEP 7️⃣: Konfirmasi Berhasil

```
┌──────────────────────────────┐
│   PEMESANAN BERHASIL! ✅     │
├──────────────────────────────┤
│                              │
│  🎉 Booking Anda Diterima   │
│                              │
│  Nomor Booking:              │
│  20260420F7A3                │
│  (Catat untuk referensi)     │
│                              │
│  Status:                     │
│  ⏳ PENDING DIVISION LEAD    │
│                              │
│  Waktu Diminta:              │
│  20 April 2026, 08:00-09:00  │
│                              │
│  Estimasi Persetujuan:       │
│  Max 1-2 hari kerja          │
│                              │
├──────────────────────────────┤
│                              │
│  Anda akan mendapat          │
│  notifikasi ketika ada       │
│  update status booking       │
│                              │
│  [  LIHAT DETAIL  ]          │
│  [  KEMBALI KE HOME  ]       │
└──────────────────────────────┘
```

---

## 📊 Manajemen Booking

### Lihat Daftar Booking Saya

#### Menu Riwayat Booking

```
┌──────────────────────────────┐
│   RIWAYAT BOOKING SAYA       │
├──────────────────────────────┤
│                              │
│  FILTER:                     │
│  [Semua] [Approved] [Pending]│
│  [Rejected] [Bulan: April]   │
│                              │
├──────────────────────────────┤
│  BOOKING TERBARU             │
│                              │
│  1. Meeting Room 1           │
│     Booking Code: 20260420F  │
│     Tanggal: 20-04-2026      │
│     Waktu: 08:00 - 09:00     │
│     Tujuan: Meeting Klien    │
│     Status: ⏳ Pending GA    │
│     [TAP UNTUK DETAIL]       │
│                              │
│  2. Mobil Operasional 1      │
│     Booking Code: 20260418AB │
│     Tanggal: 18-04-2026      │
│     Waktu: 10:00 - 12:00     │
│     Tujuan: Kantor Cilangkap │
│     Status: ✅ Approved      │
│     [TAP UNTUK DETAIL]       │
│                              │
│  3. Training Room            │
│     Booking Code: 20260415CD │
│     Tanggal: 15-04-2026      │
│     Waktu: 13:00 - 15:00     │
│     Tujuan: Training Internal│
│     Status: ❌ Rejected      │
│     [TAP UNTUK DETAIL]       │
│                              │
│  [SCROLL untuk melihat lebih]│
│                              │
└──────────────────────────────┘
```

### Detail Booking

```
┌──────────────────────────────┐
│   DETAIL BOOKING             │
├──────────────────────────────┤
│                              │
│  INFORMASI UMUM              │
│  ─────────────────────────── │
│  Booking Code: 20260420F7A3  │
│  Jenis: 🏢 Ruangan           │
│  Fasilitas: Meeting Room 1   │
│  Status: ⏳ Pending GA       │
│                              │
│  TANGGAL & WAKTU             │
│  ─────────────────────────── │
│  Tanggal: 20-04-2026         │
│  Waktu: 08:00 - 09:00        │
│  Durasi: 1 jam               │
│                              │
│  DETAIL PESANAN              │
│  ─────────────────────────── │
│  Tujuan: Meeting dengan Klien│
│  Peserta: 5 orang            │
│  Catatan: Siapkan kopi       │
│                              │
│  PROSES APPROVAL             │
│  ─────────────────────────── │
│  Division Lead:              │
│  Status: ✅ Approved         │
│  Nama: Budi Santoso          │
│  Tanggal: 20-04-2026 10:30   │
│  Catatan: OK, silahkan       │
│                              │
│  GA (General Affairs):       │
│  Status: ⏳ Pending          │
│  Nama: -                     │
│  Tanggal: -                  │
│  Catatan: -                  │
│                              │
│  AKSI:                       │
│  ┌─────────────────────────┐ │
│  │ [✏️ EDIT] [❌ BATALKAN] │ │
│  │ [📲 SHARE] [🖨️ PRINT]  │ │
│  └─────────────────────────┘ │
│                              │
└──────────────────────────────┘
```

### Edit Booking (Sebelum Approved)

```
┌──────────────────────────────┐
│   EDIT BOOKING               │
├──────────────────────────────┤
│                              │
│  ⚠️ PERHATIAN:               │
│  Booking hanya bisa diedit   │
│  sebelum diapprove           │
│                              │
│  YANG BISA DIEDIT:           │
│  ✅ Waktu mulai/selesai      │
│  ✅ Tujuan penggunaan        │
│  ✅ Jumlah peserta           │
│  ✅ Catatan                  │
│                              │
│  YANG TIDAK BISA DIEDIT:     │
│  ❌ Fasilitas (harus batal & │
│     buat baru)               │
│  ❌ Tanggal (harus batal &   │
│     buat baru)               │
│                              │
│  [  MULAI EDIT  ]            │
│  [  KEMBALI  ]               │
│                              │
└──────────────────────────────┘
```

### Batalkan Booking

```
┌──────────────────────────────┐
│   BATALKAN BOOKING           │
├──────────────────────────────┤
│                              │
│  ⚠️ KONFIRMASI               │
│  Anda yakin membatalkan      │
│  booking ini?                │
│                              │
│  Booking Code: 20260420F7A3  │
│  Meeting Room 1              │
│  20-04-2026, 08:00-09:00     │
│                              │
│  Booking yang sudah disetujui│
│  sebaiknya batalkan melalui  │
│  notifikasi ke Division Lead │
│  dan GA terlebih dahulu      │
│                              │
├──────────────────────────────┤
│                              │
│  [❌ BATALKAN]  [✅ KEMBALI] │
│                              │
└──────────────────────────────┘
```

---

## ✅ Approval Workflow

### Untuk Division Lead

#### Dashboard Division Lead

```
┌──────────────────────────────┐
│  DASHBOARD DIVISION LEAD     │
├──────────────────────────────┤
│                              │
│  Halo, Budi Santoso! 👋      │
│  Role: Division Lead         │
│  Division: IT Department     │
│                              │
├──────────────────────────────┤
│  STATISTIK APPROVAL          │
│                              │
│  Pending Approval: 3         │
│  Total Approved: 25          │
│  Total Rejected: 2           │
│                              │
├──────────────────────────────┤
│  BOOKING MENUNGGU APPROVAL   │
│                              │
│  1. Dimas - Meeting Room 1   │
│     20-04-2026, 08:00-09:00  │
│     Tujuan: Meeting Klien    │
│     [TAP UNTUK APPROVE]      │
│                              │
│  2. Rini - Training Room     │
│     21-04-2026, 13:00-15:00  │
│     Tujuan: Training         │
│     [TAP UNTUK APPROVE]      │
│                              │
│  3. Anto - Mobil Operasional │
│     22-04-2026, 10:00-12:00  │
│     Tujuan: Kunjungan Lokasi │
│     [TAP UNTUK APPROVE]      │
│                              │
└──────────────────────────────┘
```

#### Approve Booking

```
┌──────────────────────────────┐
│   REVIEW BOOKING             │
│   (APPROVAL - Division Lead) │
├──────────────────────────────┤
│                              │
│  Booking Code: 20260420F7A3  │
│  Pemohon: Dimas Hendri       │
│  Fasilitas: Meeting Room 1   │
│  Tanggal: 20-04-2026         │
│  Waktu: 08:00 - 09:00        │
│  Tujuan: Meeting Klien       │
│  Peserta: 5 orang            │
│                              │
├──────────────────────────────┤
│  KEPUTUSAN:                  │
│                              │
│  ◯ SETUJUI (APPROVED)        │
│  ◯ TOLAK (REJECT)            │
│                              │
├──────────────────────────────┤
│                              │
│  CATATAN (Optional):         │
│  ┌─────────────────────────┐ │
│  │ OK, silahkan lanjutkan  │ │
│  │ sesuai jadwal           │ │
│  └─────────────────────────┘ │
│                              │
│  [❌ BATAL]  [✅ KIRIM]      │
│                              │
└──────────────────────────────┘
```

**Setelah Tap KIRIM:**

```
┌──────────────────────────────┐
│   APPROVAL BERHASIL! ✅      │
├──────────────────────────────┤
│                              │
│  Booking Code: 20260420F7A3  │
│  Status: ✅ Approved by      │
│  Division Lead               │
│                              │
│  Selanjutnya akan diteruskan │
│  ke GA untuk final approval  │
│                              │
│  [  KEMBALI KE DASHBOARD  ]  │
│                              │
└──────────────────────────────┘
```

---

### Untuk GA (General Affairs)

#### Dashboard GA

```
┌──────────────────────────────┐
│      DASHBOARD GA            │
├──────────────────────────────┤
│                              │
│  Halo, Sri Suryani! 👋       │
│  Role: General Affairs       │
│                              │
├──────────────────────────────┤
│  STATISTIK APPROVAL          │
│                              │
│  Pending Final Approval: 5   │
│  Total Approved: 42          │
│  Total Rejected: 3           │
│                              │
├──────────────────────────────┤
│  BOOKING MENUNGGU FINAL APPR.│
│                              │
│  1. Dimas - Meeting Room 1   │
│     20-04-2026, 08:00-09:00  │
│     Div Lead: ✅ Approved    │
│     [TAP UNTUK APPROVE]      │
│                              │
│  2. Rini - Training Room     │
│     21-04-2026, 13:00-15:00  │
│     Div Lead: ✅ Approved    │
│     [TAP UNTUK APPROVE]      │
│                              │
│  3. Anto - Mobil Operasional │
│     22-04-2026, 10:00-12:00  │
│     Div Lead: ✅ Approved    │
│     [TAP UNTUK APPROVE]      │
│                              │
└──────────────────────────────┘
```

#### Final Approval oleh GA

```
┌──────────────────────────────┐
│   FINAL APPROVAL (GA)        │
├──────────────────────────────┤
│                              │
│  Booking Code: 20260420F7A3  │
│  Pemohon: Dimas Hendri       │
│  Fasilitas: Meeting Room 1   │
│  Tanggal: 20-04-2026         │
│  Waktu: 08:00 - 09:00        │
│  Tujuan: Meeting Klien       │
│  Peserta: 5 orang            │
│                              │
│  APPROVAL TIMELINE:          │
│  1. ✅ Karyawan → Diajukan   │
│  2. ✅ Division Lead → OK    │
│  3. ⏳ GA → Pending          │
│                              │
├──────────────────────────────┤
│                              │
│  KEPUTUSAN:                  │
│  ◯ SETUJUI (APPROVED)        │
│  ◯ TOLAK (REJECT)            │
│                              │
│  CATATAN:                    │
│  ┌─────────────────────────┐ │
│  │ Diterima. Pastikan room │ │
│  │ sudah dibersihkan seblm │ │
│  │ digunakan               │ │
│  └─────────────────────────┘ │
│                              │
│  [❌ BATAL]  [✅ SETUJU]     │
│                              │
└──────────────────────────────┘
```

---

## 🔧 Admin Features

### Dashboard Admin

```
┌──────────────────────────────┐
│      ADMIN DASHBOARD         │
├──────────────────────────────┤
│                              │
│  Halo, Admin! 👋             │
│  Role: Administrator         │
│                              │
├──────────────────────────────┤
│  STATISTIK SISTEM            │
│                              │
│  Total Booking: 87           │
│  Approved: 75 (86%)          │
│  Pending: 8 (9%)             │
│  Rejected: 4 (5%)            │
│                              │
│  Total User: 45              │
│  Total Ruangan: 8            │
│  Total Kendaraan: 5          │
│                              │
├──────────────────────────────┤
│  MENU ADMIN                  │
│                              │
│  [🏢] MANAJEMEN RUANGAN      │
│  [🚗] MANAJEMEN KENDARAAN    │
│  [📊] LAPORAN & ANALYTICS    │
│  [👥] MANAJEMEN USER         │
│  [⚙️] PENGATURAN SISTEM      │
│  [🔔] NOTIFIKASI             │
│                              │
└──────────────────────────────┘
```

### Manajemen Ruangan

#### Daftar Ruangan

```
┌──────────────────────────────┐
│   MANAJEMEN RUANGAN          │
├──────────────────────────────┤
│                              │
│  [+ TAMBAH RUANGAN BARU]     │
│                              │
├──────────────────────────────┤
│  DAFTAR RUANGAN:             │
│                              │
│  1. Meeting Room 1           │
│     Kapasitas: 10 orang      │
│     Lokasi: Lantai 2         │
│     Status: ✅ Aktif         │
│     [EDIT] [HAPUS]           │
│                              │
│  2. Meeting Room 2           │
│     Kapasitas: 20 orang      │
│     Lokasi: Lantai 3         │
│     Status: ✅ Aktif         │
│     [EDIT] [HAPUS]           │
│                              │
│  3. Training Room            │
│     Kapasitas: 30 orang      │
│     Lokasi: Lantai 1         │
│     Status: ✅ Aktif         │
│     [EDIT] [HAPUS]           │
│                              │
│  4. Ruang Diskusi            │
│     Kapasitas: 8 orang       │
│     Lokasi: Lantai 2         │
│     Status: ❌ Nonaktif      │
│     [EDIT] [HAPUS]           │
│                              │
└──────────────────────────────┘
```

#### Tambah Ruangan Baru

```
┌──────────────────────────────┐
│   TAMBAH RUANGAN BARU        │
├──────────────────────────────┤
│                              │
│  NAMA RUANGAN *              │
│  ┌─────────────────────────┐ │
│  │ Meeting Room 3          │ │
│  └─────────────────────────┘ │
│                              │
│  KAPASITAS (orang) *         │
│  ┌─────────────────────────┐ │
│  │ 15                      │ │
│  └─────────────────────────┘ │
│                              │
│  LOKASI *                    │
│  ┌─────────────────────────┐ │
│  │ Lantai 2                │ │
│  └─────────────────────────┘ │
│                              │
│  FASILITAS TERSEDIA          │
│  ┌─────────────────────────┐ │
│  │ ☑ Proyektor            │ │
│  │ ☑ AC                   │ │
│  │ ☑ WiFi                 │ │
│  │ ☐ Meja Konferensi      │ │
│  │ ☐ Whiteboard           │ │
│  └─────────────────────────┘ │
│                              │
│  STATUS                      │
│  ◉ Aktif                     │
│  ○ Nonaktif                  │
│                              │
│  [❌ BATAL]  [✅ SIMPAN]     │
│                              │
└──────────────────────────────┘
```

### Manajemen Kendaraan

#### Daftar Kendaraan

```
┌──────────────────────────────┐
│   MANAJEMEN KENDARAAN        │
├──────────────────────────────┤
│                              │
│  [+ TAMBAH KENDARAAN BARU]   │
│                              │
├──────────────────────────────┤
│  DAFTAR KENDARAAN:           │
│                              │
│  1. Mobil Operasional 1      │
│     Plat: B 1234 ABC         │
│     Tipe: MPV                │
│     Kapasitas: 7 orang       │
│     Status: ✅ Aktif         │
│     [EDIT] [HAPUS]           │
│                              │
│  2. Mobil Operasional 2      │
│     Plat: B 5678 XYZ         │
│     Tipe: Sedan              │
│     Kapasitas: 5 orang       │
│     Status: ✅ Aktif         │
│     [EDIT] [HAPUS]           │
│                              │
│  3. Mobil Operasional 3      │
│     Plat: B 9999 QWE         │
│     Tipe: Pick-up            │
│     Kapasitas: 2 orang       │
│     Status: ❌ Maintenance   │
│     [EDIT] [HAPUS]           │
│                              │
│  [SCROLL untuk lebih...]     │
│                              │
└──────────────────────────────┘
```

#### Tambah Kendaraan Baru

```
┌──────────────────────────────┐
│   TAMBAH KENDARAAN BARU      │
├──────────────────────────────┤
│                              │
│  NAMA KENDARAAN *            │
│  ┌─────────────────────────┐ │
│  │ Mobil Operasional 4     │ │
│  └─────────────────────────┘ │
│                              │
│  PLAT NOMOR *                │
│  ┌─────────────────────────┐ │
│  │ B 2026 ABC              │ │
│  └─────────────────────────┘ │
│                              │
│  TIPE KENDARAAN *            │
│  ┌─────────────────────────┐ │
│  │ [Pilih: Sedan ▼]        │ │
│  │ - Mobil                 │ │
│  │ - Minibus               │ │
│  │ - Pick-up               │ │
│  │ - Truck                 │ │
│  └─────────────────────────┘ │
│                              │
│  KAPASITAS (orang) *         │
│  ┌─────────────────────────┐ │
│  │ 5                       │ │
│  └─────────────────────────┘ │
│                              │
│  KONDISI KENDARAAN           │
│  ◉ Aktif                     │
│  ○ Maintenance               │
│  ○ Tidak Aktif               │
│                              │
│  [❌ BATAL]  [✅ SIMPAN]     │
│                              │
└──────────────────────────────┘
```

---

## ❓ FAQ & Troubleshooting

### ❓ Pertanyaan Umum

#### Q1: Bagaimana jika saya ingin membatalkan booking yang sudah diapprove?

**A:** Silakan hubungi Division Lead atau GA yang telah approval booking Anda. Mereka bisa membatalkan dari sisi mereka. Atau, edit booking Anda dan ubah waktu yang lebih fleksibel jika memungkinkan.

#### Q2: Bisakah saya booking untuk orang lain?

**A:** Tidak. Setiap booking harus dibuat oleh karyawan yang akan menggunakan fasilitas tersebut dengan akun mereka sendiri.

#### Q3: Berapa lama proses approval?

**A:** 
- Division Lead: Max 1 hari kerja
- GA: Max 2 hari kerja
- Total: Max 3 hari kerja (tergantung beban kerja)

#### Q4: Apakah bisa booking lebih dari 8 jam?

**A:** Tergantung fasilitas. Untuk ruangan biasanya max 4 jam per sesi untuk efisiensi. Untuk kendaraan bisa lebih fleksibel. Hubungi admin jika ada kebutuhan khusus.

#### Q5: Bisa booking bersamaan di 2 fasilitas?

**A:** Tidak. Sistem hanya memperbolehkan 1 booking active per karyawan pada waktu yang sama.

#### Q6: Apakah ada biaya untuk booking?

**A:** Tidak. Fasilitas kantor gratis untuk semua karyawan sesuai kebutuhan bisnis.

---

### 🐛 Troubleshooting

#### ❌ Error: "Tidak bisa login"

**Masalah:**
```
Error: Invalid credentials / Email tidak terdaftar
```

**Solusi:**
1. Pastikan email Anda sudah terdaftar di sistem
2. Cek password Anda (case-sensitive)
3. Hubungi admin jika lupa password
4. Pastikan internet connection stabil

---

#### ❌ Error: "Koneksi server gagal"

**Masalah:**
```
Error: Failed to connect to server / Connection refused
```

**Solusi:**
1. Pastikan Laravel backend server sudah running:
   ```bash
   php artisan serve
   ```
2. Cek koneksi internet / WiFi
3. Pastikan URL backend benar di `lib/services/api_service.dart`
4. Untuk Android Emulator, gunakan: `http://10.0.2.2:8000/api`
5. Untuk Physical Device, gunakan IP lokal: `http://192.168.x.x:8000/api`

---

#### ❌ Error: "Jam yang dipilih sudah bentrok"

**Masalah:**
```
Error: Time slot not available / Schedule conflict detected
```

**Solusi:**
1. Cek daftar booking yang sudah ada
2. Pilih jam lain yang tersedia (hijau ✅)
3. Ingat jeda 30 menit sebelum & sesudah booking
4. Kalau waktu sangat terbatas, hubungi admin untuk menambah ruangan/kendaraan

---

#### ❌ Error: "Booking tidak muncul di list"

**Masalah:**
```
Booking yang baru dibuat tidak muncul di riwayat
```

**Solusi:**
1. Refresh halaman (swipe down)
2. Logout & login kembali
3. Cek filter status booking (pastikan tidak difilter)
4. Cek tanggal filter (pastikan sesuai)
5. Clear cache aplikasi:
   - Android: Settings → Apps → SJ Order App → Storage → Clear Cache

---

#### ❌ Error: "Tidak bisa edit/hapus booking"

**Masalah:**
```
Tombol edit/hapus tidak tersedia
```

**Solusi:**
1. Booking hanya bisa diedit sebelum di-approve
2. Jika sudah di-approve, harus submit request perubahan ke admin
3. Atau batalkan booking dan buat baru

---

#### ❌ Error: "Notifikasi tidak masuk"

**Masalah:**
```
Tidak mendapat notifikasi approval/rejection
```

**Solusi:**
1. Pastikan notifikasi aplikasi sudah diizinkan:
   - Android: Settings → Apps → SJ Order App → Notifications → Enabled
2. Pastikan background process tidak di-kill:
   - Jangan tambahkan aplikasi ke "Battery Saver" exception
3. Manual refresh: Swipe down di halaman riwayat booking
4. Hub admin jika masalah berlanjut

---

#### ❌ Error: "Tidak bisa tambah ruangan/kendaraan (Admin)"

**Masalah:**
```
Form tambah tidak bisa di-submit
```

**Solusi:**
1. Pastikan semua field yang wajib sudah diisi (*)
2. Cek format input (nama tidak boleh special character)
3. Pastikan kapasitas adalah angka (bukan text)
4. Cek internet connection
5. Coba refresh halaman & ulangi

---

### 📞 Menghubungi Support

Jika masalah tidak teratasi:

1. **Email**: support@sj-order-app.com
2. **WhatsApp**: +62 xxx-xxxx-xxxx
3. **Internal Chat**: Chat dengan admin di aplikasi
4. **Report Bug**: GitHub Issues

Sertakan:
- Screenshot error
- Waktu error terjadi
- Device & OS info
- Steps untuk reproduce error

---

## 📋 Checklist Sebelum Booking

```
CHECKLIST BOOKING RUANGAN
☐ Sudah login dengan akun yang benar?
☐ Ruangan yang diinginkan sudah tersedia?
☐ Tanggal & waktu sudah benar?
☐ Ada jeda 30 menit sebelum/sesudah?
☐ Tujuan penggunaan sudah jelas?
☐ Jumlah peserta tidak melampaui kapasitas?
☐ Sudah review detail sebelum submit?
☐ Sudah siap untuk menunggu approval?

CHECKLIST BOOKING KENDARAAN
☐ Sudah login dengan akun yang benar?
☐ Kendaraan yang diinginkan tersedia?
☐ Tanggal & waktu sudah benar?
☐ Ada jeda 30 menit sebelum/sesudah?
☐ Tujuan perjalanan jelas?
☐ Jumlah penumpang sesuai kapasitas?
☐ Sudah atur driver (jika perlu)?
☐ Sudah komunikasi dengan GA?

CHECKLIST APPROVAL (DIVISION LEAD)
☐ Sudah review detail booking?
☐ Apakah request reasonable?
☐ Apakah peserta sesuai dengan tujuan?
☐ Apakah ada resource conflict?
☐ Berikan catatan yang jelas?
☐ Approval/reject dengan alasan?

CHECKLIST APPROVAL (GA)
☐ Sudah review approval division lead?
☐ Apakah fasilitas siap digunakan?
☐ Apakah ada jadwal maintenance?
☐ Apakah sudah ada supply (kopi, dll)?
☐ Berikan instruksi khusus jika ada?
☐ Final approval/rejection?
```

---

## 🎯 Best Practices

### Tips Booking yang Baik

1. **Booking Cukup Awal**
   - Minimal 1-2 hari sebelumnya
   - Hindari booking last-minute agar approval lancar

2. **Deskripsi Tujuan Jelas**
   - ✅ Baik: "Meeting dengan klien PT ABC untuk discuss proposal"
   - ❌ Kurang: "Meeting"

3. **Estimasi Waktu Akurat**
   - Jangan pesan terlalu lama untuk satu session
   - Max 2 jam untuk meeting normal
   - Lebih baik booking multiple session daripada terlalu lama

4. **Peserta Sesuai Kapasitas**
   - Pastikan peserta tidak melebihi kapasitas ruangan
   - Utamakan ruangan yang sesuai dengan jumlah peserta

5. **Koordinasi dengan Tim**
   - Komunikasikan booking ke peserta
   - Konfirmasi kehadiran peserta
   - Jalankan meeting ON TIME

---

## 🎉 Kesimpulan

Anda sudah siap menggunakan **SJ Order App**! 

**Ringkasan Poin Penting:**
- ✅ Login dengan akun Anda
- ✅ Pilih fasilitas & waktu yang available
- ✅ Isi detail booking dengan jelas
- ✅ Submit untuk approval
- ✅ Tunggu notifikasi persetujuan
- ✅ Gunakan fasilitas sesuai jadwal
- ✅ Pastikan fasilitas bersih setelah digunakan

**Jika ada pertanyaan**, jangan ragu untuk hubungi admin atau baca FAQ di atas.

Selamat menggunakan aplikasi! 🚀

---

<div align="center">

**Made with ❤️ for SJ Company**

**Version 1.0.0**

</div>

