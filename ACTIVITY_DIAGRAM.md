# 📊 ACTIVITY DIAGRAM - SJ Order App
## Diagram Alur Aktivitas Sistem Pemesanan Fasilitas Kantor

---

## 🔑 Legenda Diagram

```
[Activity]          = Aktivitas/Proses
(Decision)          = Titik Keputusan
---->               = Alur Aktivitas
Swimlane            = Kolom untuk setiap aktor/role
```

---

## 1️⃣ ACTIVITY DIAGRAM: BOOKING RUANGAN (Karyawan)

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         BOOKING RUANGAN (KARYAWAN)                      │
└─────────────────────────────────────────────────────────────────────────┘

KARYAWAN                          SISTEM                        DATABASE
    │                               │                              │
    │                               │                              │
    ├─────────────────────────────>│                              │
    │   Buka Aplikasi               │                              │
    │                               │                              │
    │                               ├─────────────────────────────>│
    │                               │  Fetch Data Ruangan          │
    │                               │  & Jadwal Existing           │
    │                               │<─────────────────────────────┤
    │                               │  Return Data                 │
    │<─────────────────────────────│                              │
    │   Tampilkan Dashboard         │                              │
    │                               │                              │
    │                               │                              │
    ├─────────────────────────────>│                              │
    │   Tap "Booking Ruangan"       │                              │
    │                               │                              │
    │<─────────────────────────────│                              │
    │   Tampilkan Form Booking      │                              │
    │                               │                              │
    │                               │                              │
    ├─────────────────────────────>│                              │
    │   Pilih Ruangan               │                              │
    │                               │                              │
    │<─────────────────────────────│                              │
    │   Tampilkan Ruangan Available │                              │
    │                               │                              │
    │                               │                              │
    ├─────────────────────────────>│                              │
    │   Pilih Tanggal               │                              │
    │                               │                              │
    │<─────────────────────────────│                              │
    │   Tampilkan Calendar          │                              │
    │                               │                              │
    │                               │                              │
    ├─────────────────────────────>│                              │
    │   Pilih Waktu Mulai/Selesai   │                              │
    │                               │                              │
    │                               ├─────────────────────────────>│
    │                               │  Validasi Schedule           │
    │                               │  (Check Conflict)            │
    │                               │<─────────────────────────────┤
    │                               │  Result: Available/Conflict  │
    │<─────────────────────────────│                              │
    │   Tampilkan Jam Available     │                              │
    │   (Highlight Conflict)        │                              │
    │                               │                              │
    │                               │                              │
    ├─────────────────────────────>│                              │
    │   Isi Detail Booking:         │                              │
    │   - Tujuan                    │                              │
    │   - Jumlah Peserta            │                              │
    │   - Catatan                   │                              │
    │                               │                              │
    │<─────────────────────────────│                              │
    │   Form Siap untuk Review      │                              │
    │                               │                              │
    │                               │                              │
    ├─────────────────────────────>│                              │
    │   Review Detail & Tap Submit  │                              │
    │                               │                              │
    │                       ╔═══════════════════╗                  │
    │                       ║ Confirm Submit?   ║                  │
    │                       ╚═══════════════════╝                  │
    │                         │              │                     │
    │                    YES  │              │  NO                 │
    │<────────────────────────┘              └───────────────────>│
    │ Cancel / Edit                          Kembali ke Form      │
    │                                                              │
    │                                                              │
    │                               ├─────────────────────────────>│
    │                               │  Simpan Booking ke Database  │
    │                               │  Generate Booking Code       │
    │                               │<─────────────────────────────┤
    │                               │  Return: Booking ID + Code   │
    │<─────────────────────────────│                              │
    │   Tampilkan Success Page      │                              │
    │   Booking Code: 20260420F7A3  │                              │
    │   Status: Pending Division    │                              │
    │                               │                              │
    │                               ├─────────────────────────────>│
    │                               │  Create Notification         │
    │                               │  untuk Division Lead         │
    │                               │<─────────────────────────────┤
    │                               │  Notification Created        │
    │<─────────────────────────────│                              │
    │   Selesai / Kembali ke Home   │                              │
    │                               │                              │

```

---

## 2️⃣ ACTIVITY DIAGRAM: BOOKING KENDARAAN (Karyawan)

```
┌──────────────────────────────────────────────────────────────────────┐
│                    BOOKING KENDARAAN (KARYAWAN)                      │
└──────────────────────────────────────────────────────────────────────┘

KARYAWAN                       SISTEM                         DATABASE
    │                            │                               │
    ├───────────────────────────>│                               │
    │  Tap "Booking Kendaraan"   │                               │
    │                            │                               │
    │                            ├──────────────────────────────>│
    │                            │  Fetch Data Kendaraan         │
    │                            │  & Jadwal Existing            │
    │                            │<──────────────────────────────┤
    │                            │  Return Data                  │
    │<───────────────────────────│                               │
    │  Tampilkan Form Booking    │                               │
    │  (Kendaraan List)          │                               │
    │                            │                               │
    │                            │                               │
    ├───────────────────────────>│                               │
    │  Pilih Kendaraan           │                               │
    │  (Filter by Type)          │                               │
    │                            │                               │
    │<───────────────────────────│                               │
    │  Tampilkan Kendaraan       │                               │
    │  Available                 │                               │
    │                            │                               │
    │                            │                               │
    ├───────────────────────────>│                               │
    │  Pilih Tanggal             │                               │
    │                            │                               │
    │                            ├──────────────────────────────>│
    │                            │  Check Tanggal di Schedule    │
    │                            │<──────────────────────────────┤
    │                            │  Valid / Invalid              │
    │<───────────────────────────│                               │
    │  Tampilkan Calendar        │                               │
    │                            │                               │
    │                            │                               │
    ├───────────────────────────>│                               │
    │  Pilih Jam Mulai/Selesai   │                               │
    │                            │                               │
    │                            ├──────────────────────────────>│
    │                            │  Validasi Time Slot           │
    │                            │  (Check Buffer 30 min)        │
    │                            │<──────────────────────────────┤
    │                            │  Available Slots              │
    │<───────────────────────────│                               │
    │  Tampilkan Waktu Available │                               │
    │                            │                               │
    │                            │                               │
    ├───────────────────────────>│                               │
    │  Isi Detail:               │                               │
    │  - Tujuan Perjalanan       │                               │
    │  - Jumlah Penumpang        │                               │
    │  - Catatan Khusus          │                               │
    │                            │                               │
    │<───────────────────────────│                               │
    │  Form Siap                 │                               │
    │                            │                               │
    │                            │                               │
    ├───────────────────────────>│                               │
    │  Review & Submit           │                               │
    │                            │                               │
    │                    ╔════════════════════╗                  │
    │                    ║ Confirm Submit?    ║                  │
    │                    ╚════════════════════╝                  │
    │                      │                │                    │
    │                 YES  │                │  NO                │
    │<───────────────────────┘              └──────────────────>│
    │ Proceed                                 Edit/Cancel        │
    │                                                            │
    │                            ├──────────────────────────────>│
    │                            │  Save Booking                 │
    │                            │  Generate Booking Code        │
    │                            │  Set Status: Pending Div      │
    │                            │<──────────────────────────────┤
    │                            │  Success                      │
    │<───────────────────────────│                               │
    │  Show Success Message      │                               │
    │  Booking Code + Status     │                               │
    │                            │                               │
    │                            ├──────────────────────────────>│
    │                            │  Send Notification            │
    │                            │  to Division Lead             │
    │                            │<──────────────────────────────┤
    │                            │  Notification Sent            │
    │<───────────────────────────│                               │
    │  Kembali ke Home           │                               │
    │                            │                               │

```

---

## 3️⃣ ACTIVITY DIAGRAM: APPROVAL BOOKING (Division Lead)

```
┌───────────────────────────────────────────────────────────────────────┐
│           APPROVAL BOOKING BY DIVISION LEAD                           │
└───────────────────────────────────────────────────────────────────────┘

DIV. LEAD                      SISTEM                         DATABASE
    │                            │                               │
    ├───────────────────────────>│                               │
    │  Buka Notifikasi/Dashboard │                               │
    │                            │                               │
    │                            ├──────────────────────────────>│
    │                            │  Fetch Booking Pending        │
    │                            │  for This Division            │
    │                            │<──────────────────────────────┤
    │                            │  Return List Booking          │
    │<───────────────────────────│                               │
    │  Tampilkan Approval Queue   │                               │
    │                            │                               │
    │                            │                               │
    ├───────────────────────────>│                               │
    │  Tap Booking untuk Review   │                               │
    │                            │                               │
    │                            ├──────────────────────────────>│
    │                            │  Fetch Booking Detail         │
    │                            │  + User Info                  │
    │                            │<──────────────────────────────┤
    │                            │  Return Detail                │
    │<───────────────────────────│                               │
    │  Tampilkan Detail Booking   │                               │
    │  (Karyawan, Fasilitas,      │                               │
    │   Waktu, Tujuan, dll)       │                               │
    │                            │                               │
    │                            │                               │
    ├───────────────────────────>│                               │
    │  Review Detail              │                               │
    │                            │                               │
    │                    ╔════════════════════════╗               │
    │                    ║ Keputusan?             ║               │
    │                    ║ - SETUJUI (APPROVE)    ║               │
    │                    ║ - TOLAK (REJECT)       ║               │
    │                    ╚════════════════════════╝               │
    │                      │                      │               │
    │            APPROVE   │                      │   REJECT      │
    │                      │                      │               │
    │                      ▼                      ▼               │
    │                 [A]                    [B]                 │
    │                                                            │
    │  [A] APPROVE PATH:                                        │
    │                                                            │
    ├───────────────────────────>│                               │
    │  Input Catatan (Optional)   │                               │
    │  Tap "SETUJUI"              │                               │
    │                            │                               │
    │                            ├──────────────────────────────>│
    │                            │  Update Booking Status        │
    │                            │  = pending_ga                 │
    │                            │  Set division_approval_by     │
    │                            │  Set division_approval_at     │
    │                            │  Set Notes                    │
    │                            │<──────────────────────────────┤
    │                            │  Update Success              │
    │<───────────────────────────│                               │
    │  Show Success Msg           │                               │
    │                            │                               │
    │                            ├──────────────────────────────>│
    │                            │  Create Notification          │
    │                            │  to GA                        │
    │                            │  & to Karyawan               │
    │                            │<──────────────────────────────┤
    │                            │  Notification Created         │
    │<───────────────────────────│                               │
    │  Kembali ke Queue           │                               │
    │                            │                               │
    │                                                            │
    │  [B] REJECT PATH:                                         │
    │                                                            │
    ├───────────────────────────>│                               │
    │  Input Alasan Penolakan     │                               │
    │  (Wajib diisi)              │                               │
    │                            │                               │
    │<───────────────────────────│                               │
    │  Form Siap                  │                               │
    │                            │                               │
    │                            │                               │
    ├───────────────────────────>│                               │
    │  Tap "TOLAK"                │                               │
    │                            │                               │
    │                            ├──────────────────────────────>│
    │                            │  Update Booking Status        │
    │                            │  = rejected_division          │
    │                            │  Set division_approval_by     │
    │                            │  Set Rejection Reason         │
    │                            │<──────────────────────────────┤
    │                            │  Update Success              │
    │<───────────────────────────│                               │
    │  Show Rejection Msg         │                               │
    │                            │                               │
    │                            ├──────────────────────────────>│
    │                            │  Create Notification          │
    │                            │  to Karyawan                 │
    │                            │  (Include Alasan)            │
    │                            │<──────────────────────────────┤
    │                            │  Notification Created         │
    │<───────────────────────────│                               │
    │  Kembali ke Queue           │                               │
    │                            │                               │

```

---

## 4️⃣ ACTIVITY DIAGRAM: FINAL APPROVAL (GA)

```
┌───────────────────────────────────────────────────────────────────────┐
│              FINAL APPROVAL BY GA (GENERAL AFFAIRS)                   │
└───────────────────────────────────────────────────────────────────────┘

GA (GEN.AFFAIRS)               SISTEM                         DATABASE
    │                            │                               │
    ├───────────────────────────>│                               │
    │  Buka Notifikasi/Dashboard │                               │
    │                            │                               │
    │                            ├──────────────────────────────>│
    │                            │  Fetch Booking Pending GA     │
    │                            │  (Status = pending_ga)        │
    │                            │<──────────────────────────────┤
    │                            │  Return List                  │
    │<───────────────────────────│                               │
    │  Tampilkan Final Approval   │                               │
    │  Queue                      │                               │
    │                            │                               │
    │                            │                               │
    ├───────────────────────────>│                               │
    │  Tap Booking untuk Review   │                               │
    │                            │                               │
    │                            ├──────────────────────────────>│
    │                            │  Fetch Complete Booking Info  │
    │                            │  + Approval Timeline          │
    │                            │<──────────────────────────────┤
    │                            │  Return Detail +              │
    │                            │  Approval History             │
    │<───────────────────────────│                               │
    │  Tampilkan:                 │                               │
    │  - Booking Detail           │                               │
    │  - Division Lead Approval   │                               │
    │  - Check Fasilitas Status   │                               │
    │                            │                               │
    │                            │                               │
    ├───────────────────────────>│                               │
    │  Review & Validasi:         │                               │
    │  - Is Fasilitas Available?  │                               │
    │  - Is There Maintenance?    │                               │
    │  - Any Conflict?            │                               │
    │                            │                               │
    │                    ╔════════════════════════╗               │
    │                    ║ GA Decision?           ║               │
    │                    ║ - APPROVE              ║               │
    │                    ║ - REJECT               ║               │
    │                    ╚════════════════════════╝               │
    │                      │                      │               │
    │            APPROVE   │                      │   REJECT      │
    │                      │                      │               │
    │                      ▼                      ▼               │
    │                 [X]                    [Y]                 │
    │                                                            │
    │  [X] FINAL APPROVE PATH:                                  │
    │                                                            │
    ├───────────────────────────>│                               │
    │  Input Catatan (Optional)   │                               │
    │  Tap "SETUJUI FINAL"        │                               │
    │                            │                               │
    │                            ├──────────────────────────────>│
    │                            │  Update Booking Status        │
    │                            │  = approved                   │
    │                            │  Set ga_approval_by           │
    │                            │  Set ga_approval_at           │
    │                            │  Set ga_notes                 │
    │                            │<──────────────────────────────┤
    │                            │  Update Success              │
    │<───────────────────────────│                               │
    │  Show APPROVED Message      │                               │
    │                            │                               │
    │                            ├──────────────────────────────>│
    │                            │  Create Final Notification    │
    │                            │  to Karyawan                 │
    │                            │  Message: Booking Approved!   │
    │                            │  + Show Booking Code          │
    │                            │<──────────────────────────────┤
    │                            │  Notification Created         │
    │<───────────────────────────│                               │
    │  Kembali ke Queue           │                               │
    │                            │                               │
    │                                                            │
    │  [Y] FINAL REJECT PATH:                                   │
    │                                                            │
    ├───────────────────────────>│                               │
    │  Input Alasan Penolakan     │                               │
    │  (Wajib)                    │                               │
    │                            │                               │
    │<───────────────────────────│                               │
    │  Form Complete              │                               │
    │                            │                               │
    │                            │                               │
    ├───────────────────────────>│                               │
    │  Tap "TOLAK FINAL"          │                               │
    │                            │                               │
    │                            ├──────────────────────────────>│
    │                            │  Update Booking Status        │
    │                            │  = rejected_ga                │
    │                            │  Set ga_approval_by           │
    │                            │  Set Rejection Reason         │
    │                            │<──────────────────────────────┤
    │                            │  Update Success              │
    │<───────────────────────────│                               │
    │  Show REJECTION Message     │                               │
    │                            │                               │
    │                            ├──────────────────────────────>│
    │                            │  Create Notification          │
    │                            │  to Karyawan                 │
    │                            │  Message: Booking Rejected    │
    │                            │  + Alasan Penolakan           │
    │                            │<──────────────────────────────┤
    │                            │  Notification Created         │
    │<───────────────────────────│                               │
    │  Kembali ke Queue           │                               │
    │                            │                               │

```

---

## 5️⃣ ACTIVITY DIAGRAM: SMART SCHEDULE VALIDATION

```
┌────────────────────────────────────────────────────────────────────────┐
│              SMART SCHEDULE VALIDATION (CONFLICT DETECTION)            │
└────────────────────────────────────────────────────────────────────────┘

KARYAWAN                      SISTEM                          DATABASE
    │                           │                               │
    ├──────────────────────────>│                               │
    │  Input: Pilih Jam Mulai   │                               │
    │  & Jam Selesai            │                               │
    │                           │                               │
    │                           ├──────────────────────────────>│
    │                           │  QUERY: Get All Booking      │
    │                           │  for Fasilitas + Tanggal      │
    │                           │  WHERE status = 'approved'    │
    │                           │<──────────────────────────────┤
    │                           │  Return: Array of Bookings    │
    │<──────────────────────────│                               │
    │  (Background Process)     │                               │
    │                           │                               │
    │                           ├─────────────────────────────>│
    │                           │  VALIDASI 1:                  │
    │                           │  Check Direct Overlap         │
    │                           │                               │
    │                           │  IF (new_start < existing_end)
    │                           │  AND (new_end > existing_start)
    │                           │  THEN: CONFLICT               │
    │                           │                               │
    │                    ╔════════════════════════╗             │
    │                    ║ Overlap Detected?      ║             │
    │                    ╚════════════════════════╝             │
    │                      │                      │             │
    │                   YES│                      │NO           │
    │                      │                      │             │
    │                      ▼                      ▼             │
    │              [CONFLICT]              [Continue]          │
    │                                                          │
    │<──────────────────────────────────────────────────────┤  │
    │ Show ERROR: "Jam bentrok dengan booking lain"        │  │
    │                                                       │  │
    │<─────────────────────────────────────────────────────────┤
    │                           │                               │
    │                           ├─────────────────────────────>│
    │                           │  VALIDASI 2:                  │
    │                           │  Check Buffer 30 min BEFORE   │
    │                           │                               │
    │                           │  buffer_start = existing_end  │
    │                           │  + 30 minutes                 │
    │                           │                               │
    │                           │  IF new_start < buffer_start  │
    │                           │  THEN: BUFFER CONFLICT        │
    │                           │                               │
    │                    ╔════════════════════════╗             │
    │                    ║ Buffer Before OK?      ║             │
    │                    ╚════════════════════════╝             │
    │                      │                      │             │
    │                   YES│                      │NO           │
    │                      │                      │             │
    │                      ▼                      ▼             │
    │              [Continue]             [CONFLICT]           │
    │                                                          │
    │<──────────────────────────────────────────────────────┤  │
    │ Show ERROR: "Perlu jeda 30 menit sebelum booking lain"│  │
    │                                                       │  │
    │<─────────────────────────────────────────────────────────┤
    │                           │                               │
    │                           ├─────────────────────────────>│
    │                           │  VALIDASI 3:                  │
    │                           │  Check Buffer 30 min AFTER    │
    │                           │                               │
    │                           │  buffer_end = existing_start  │
    │                           │  - 30 minutes                 │
    │                           │                               │
    │                           │  IF new_end > buffer_end      │
    │                           │  THEN: BUFFER CONFLICT        │
    │                           │                               │
    │                    ╔════════════════════════╗             │
    │                    ║ Buffer After OK?       ║             │
    │                    ╚════════════════════════╝             │
    │                      │                      │             │
    │                   YES│                      │NO           │
    │                      │                      │             │
    │                      ▼                      ▼             │
    │              [Continue]             [CONFLICT]           │
    │                                                          │
    │<──────────────────────────────────────────────────────┤  │
    │ Show ERROR: "Perlu jeda 30 menit sesudah booking lain" │  │
    │                                                       │  │
    │<─────────────────────────────────────────────────────────┤
    │                           │                               │
    │                           ├─────────────────────────────>│
    │                           │  ALL VALIDASI PASS ✅         │
    │                           │  Return: Available = true     │
    │<──────────────────────────│                               │
    │ Tampilkan Jam HIJAU       │                               │
    │ (Available - Bisa Pesan)  │                               │
    │                           │                               │

EXAMPLE VALIDATION:
─────────────────────────────────────────────────────────────────────

Existing Booking: 09:00 - 10:00

Validasi Jam Baru yang Dipilih:

✅ 08:00 - 08:30
   - Tidak overlap ✓
   - Buffer before (08:30 < 08:30) ✗ CONFLICT!
   Actually CONFLICT: Jeda kurang

✅ 08:00 - 08:29
   - Tidak overlap ✓
   - Buffer before (08:29 < 08:30) ✗ CONFLICT!
   Actually CONFLICT: Jeda kurang

✅ 08:00 - 08:00
   - Tidak overlap ✓
   - Buffer before (08:00 < 08:30) ✗ CONFLICT!
   Actually NOT AVAILABLE (durasi 0)

✅ 10:30 - 11:30
   - Tidak overlap ✓
   - Buffer before (10:30 >= 10:30) ✓
   - Buffer after (11:30 <= 09:00-30min = 08:30) ✗ CONFLICT!
   Actually OK karena: new_start (10:30) >= buffer_start (10:30)
   Result: ✅ AVAILABLE

❌ 10:15 - 11:15
   - Tidak overlap ✓
   - Buffer before (10:15 < 10:30) ✗ CONFLICT!
   Result: ❌ NOT AVAILABLE

❌ 09:30 - 10:30
   - Overlap: start (09:30 < 10:00) AND end (10:30 > 09:00) ✓
   Result: ❌ CONFLICT

```

---

## 6️⃣ ACTIVITY DIAGRAM: ADMIN MANAGE RUANGAN

```
┌────────────────────────────────────────────────────────────────────┐
│               ADMIN MANAJEMEN RUANGAN                              │
└────────────────────────────────────────────────────────────────────┘

ADMIN                          SISTEM                      DATABASE
    │                            │                           │
    ├───────────────────────────>│                           │
    │  Tap "Manajemen Ruangan"   │                           │
    │                            │                           │
    │                            ├──────────────────────────>│
    │                            │  Fetch All Ruangan        │
    │                            │  WHERE is_active = true   │
    │                            │<──────────────────────────┤
    │                            │  Return List              │
    │<───────────────────────────│                           │
    │  Tampilkan List Ruangan    │                           │
    │                            │                           │
    │                    ╔════════════════════╗              │
    │                    ║ Action?            ║              │
    │                    ║ - TAMBAH BARU      ║              │
    │                    ║ - EDIT             ║              │
    │                    ║ - HAPUS            ║              │
    │                    ╚════════════════════╝              │
    │                      │        │        │              │
    │             TAMBAH   │        │EDIT    │ HAPUS        │
    │                      │        │        │              │
    │                      ▼        ▼        ▼              │
    │                  [A]    [B]      [C]                 │
    │                                                       │
    │  [A] TAMBAH RUANGAN BARU:                            │
    │                                                       │
    ├───────────────────────────>│                           │
    │  Tap "+ Tambah Ruangan"    │                           │
    │                            │                           │
    │<───────────────────────────│                           │
    │  Tampilkan Form Input       │                           │
    │  - Nama Ruangan            │                           │
    │  - Kapasitas               │                           │
    │  - Lokasi                  │                           │
    │  - Fasilitas               │                           │
    │  - Status                  │                           │
    │                            │                           │
    │                            │                           │
    ├───────────────────────────>│                           │
    │  Isi Semua Field           │                           │
    │  Tap "Simpan"              │                           │
    │                            │                           │
    │                            ├──────────────────────────>│
    │                            │  INSERT INTO rooms        │
    │                            │  (name, capacity, ...)    │
    │                            │<──────────────────────────┤
    │                            │  Success / Error          │
    │<───────────────────────────│                           │
    │  Show Success Message      │                           │
    │  Ruangan Berhasil Ditambah │                           │
    │                            │                           │
    │                            ├──────────────────────────>│
    │                            │  Log Activity: Admin      │
    │                            │  added new room           │
    │                            │<──────────────────────────┤
    │<───────────────────────────│                           │
    │  Kembali ke List           │                           │
    │                            │                           │
    │                                                       │
    │  [B] EDIT RUANGAN:                                    │
    │                                                       │
    ├───────────────────────────>│                           │
    │  Tap Ruangan > [EDIT]      │                           │
    │                            │                           │
    │                            ├──────────────────────────>│
    │                            │  SELECT ruangan BY id     │
    │                            │<──────────────────────────┤
    │                            │  Return Detail            │
    │<───────────────────────────│                           │
    │  Tampilkan Form dengan     │                           │
    │  Data Lama (Pre-filled)    │                           │
    │                            │                           │
    │                            │                           │
    ├───────────────────────────>│                           │
    │  Edit Field yang Perlu     │                           │
    │  Tap "Update"              │                           │
    │                            │                           │
    │                            ├──────────────────────────>│
    │                            │  UPDATE rooms             │
    │                            │  SET name, capacity, ...  │
    │                            │  WHERE id = ...           │
    │                            │<──────────────────────────┤
    │                            │  Update Success           │
    │<───────────────────────────│                           │
    │  Show Success Message      │                           │
    │  Data Ruangan Diupdate     │                           │
    │                            │                           │
    │<───────────────────────────│                           │
    │  Kembali ke List           │                           │
    │                            │                           │
    │                                                       │
    │  [C] HAPUS RUANGAN:                                   │
    │                                                       │
    ├───────────────────────────>│                           │
    │  Tap Ruangan > [HAPUS]     │                           │
    │                            │                           │
    │                    ╔════════════════════╗              │
    │                    ║ Confirm Delete?    ║              │
    │                    ║ Ruangan: Meeting 1 ║              │
    │                    ║ Yakin dihapus?     ║              │
    │                    ╚════════════════════╝              │
    │                      │                  │              │
    │                 YES  │                  │  NO          │
    │                      │                  │              │
    │                      ▼                  ▼              │
    │              [Proceed]            [Cancel]            │
    │                                                       │
    ├───────────────────────────>│                           │
    │  Tap "Hapus Sekarang"      │                           │
    │                            │                           │
    │                            ├──────────────────────────>│
    │                            │  Check: Ada booking?      │
    │                            │  WHERE room_id = ...      │
    │                            │  AND status = 'approved'? │
    │                            │<──────────────────────────┤
    │                            │  Result: Jml booking      │
    │                            │                           │
    │                    ╔════════════════════╗              │
    │                    ║ Ada Booking?       ║              │
    │                    ╚════════════════════╝              │
    │                      │                  │              │
    │                    YES│                  │NO           │
    │                      │                  │              │
    │                      ▼                  ▼              │
    │              [ERROR]              [PROCEED]           │
    │                                                       │
    │<───────────────────────────────────────────────────>│
    │ Show ERROR:                                        │
    │ "Tidak bisa hapus, masih ada booking approved"    │
    │                                                   │
    │<──────────────────────────────────────────────────────┤
    │                                                       │
    │              OR                                       │
    │                                                       │
    ├───────────────────────────>│                           │
    │  (Jika tidak ada booking)  │                           │
    │                            │                           │
    │                            ├──────────────────────────>│
    │                            │  DELETE FROM rooms        │
    │                            │  WHERE id = ...           │
    │                            │<──────────────────────────┤
    │                            │  Delete Success           │
    │<───────────────────────────│                           │
    │  Show Success Message      │                           │
    │  Ruangan Berhasil Dihapus  │                           │
    │                            │                           │
    │<───────────────────────────│                           │
    │  Kembali ke List           │                           │
    │                            │                           │

```

---

## 7️⃣ ACTIVITY DIAGRAM: COMPLETE BOOKING LIFECYCLE

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    COMPLETE BOOKING LIFECYCLE                           │
└─────────────────────────────────────────────────────────────────────────┘

KARYAWAN              DIVISION LEAD              GA              SISTEM
    │                     │                      │                │
    ├────────────────────>│                      │                │
    │  1. BUAT BOOKING    │                      │                │
    │                     │                      │                ├──────>│
    │                     │                      │                │DB: Simpan
    │                     │                      │                │Status: pending_div
    │                     │                      │                │<──────┤
    │                     │<─────────────────────────────────────│
    │                     │  Notifikasi: Ada booking baru        │
    │                     │                                       │
    │                     ├──────────────────────>               │
    │                     │  2. REVIEW BOOKING   │                │
    │                     │                      │                │
    │                     ├─────────────────────>                │
    │                     │  3. APPROVE/REJECT   │                ├──────>│
    │                     │                      │                │DB: Update
    │                     │                      │                │Status: pending_ga
    │                     │                      │                │(jika approve)
    │                     │                      │                │<──────┤
    │                     │                      │                │
    │                     │                      │<──────────────┤
    │                     │                      │  Notifikasi   │
    │                     │                      │  ke GA        │
    │                     │                      │                │
    │                     │                      ├──────────────>│
    │                     │                      │  4. GA REVIEW │
    │                     │                      │                │
    │                     │                      ├────────────>  │
    │                     │                      │  5. APPROVE   ├──────>│
    │                     │                      │     /REJECT   │DB: Update
    │                     │                      │                │Status: approved
    │                     │                      │                │or rejected_ga
    │                     │                      │                │<──────┤
    │<─────────────────────────────────────────┤                │
    │  Notifikasi:                             │                │
    │  Booking APPROVED! ✅                    │                │
    │                                           │                │
    │  6. GUNAKAN FASILITAS                    │                │
    │                                           │                │
    │                                           │                │
    │  7. SELESAI (Fasilitas dikembalikan)     │                │
    │                                           │                │
    │                                           │      ├──────>│
    │                                           │      │ DB: Log
    │                                           │      │ Booking Used
    │                                           │      │<──────┤

```

---

## 📊 RINGKASAN ALUR BOOKING

```
START
  │
  ├─────────────────────────────────────────────────────┐
  │                                                      │
  ▼                                                      ▼
[KARYAWAN]                                        [ADMIN]
BOOKING RUANGAN/                                MANAGE FASILITAS
KENDARAAN                                       - Add Room/Vehicle
  │                                              - Edit
  ├──> Select Fasilitas                          - Delete
  │       │
  │       ├──> Validasi Smart Schedule ◄────────────────┐
  │       │    (Check Conflict)                          │
  │       │                                              │
  │       ├──> Available? ──NO──> Back to Select        │
  │       │    │                                         │
  │       │    YES                                       │
  │       │    │                                         │
  │       ├──> Select Tanggal                           │
  │       │                                              │
  │       ├──> Select Waktu                             │
  │       │                                              │
  │       ├──> Fill Detail                              │
  │       │                                              │
  │       ├──> Review & Confirm                         │
  │       │                                              │
  │       ├──> Submit Booking                           │
  │              │                                       │
  │              ├──────────────────> DB: Save Booking  │
  │              │                    Status: pending_div
  │              │
  │              └──────> Notification to Division Lead │
  │                                                      │
  ├─────────────────────────────────────────────────────┤
  │
  ▼
[DIVISION LEAD]
APPROVAL
  │
  ├──> Review Booking Detail
  │
  ├──> ┌─ APPROVE ─────> DB: Update
  │    │                Status: pending_ga
  │    │                ├──> Notify GA
  │    │
  │    └─ REJECT ──────> DB: Update
  │                     Status: rejected_division
  │                     ├──> Notify Karyawan
  │
  ├─────────────────────────────────────────────────────┤
  │
  ▼
[GENERAL AFFAIRS]
FINAL APPROVAL
  │
  ├──> Review Complete Booking
  │    - Check Fasilitas Status
  │    - Check Maintenance
  │
  ├──> ┌─ APPROVE ─────> DB: Update
  │    │                Status: approved ✅
  │    │                ├──> Notify Karyawan
  │    │                ├──> Booking Ready to Use
  │    │
  │    └─ REJECT ──────> DB: Update
  │                     Status: rejected_ga
  │                     ├──> Notify Karyawan
  │
  ├─────────────────────────────────────────────────────┤
  │
  ▼
[KARYAWAN]
USE FASILITAS
  │
  ├──> On Booking Date/Time
  │    ├──> Go to Fasilitas
  │    ├──> Use Fasilitas
  │    ├──> Clean & Return
  │
  ├─────────────────────────────────────────────────────┤
  │
  ▼
END ✅

```

---

## 🔄 STATE DIAGRAM - BOOKING STATUS

```
┌─────────────────────────────────────────────────────────────────┐
│                    BOOKING STATUS FLOW                          │
└─────────────────────────────────────────────────────────────────┘

                        ┌──────────────────┐
                        │ INITIAL: pending │
                        │   _division      │
                        └────────┬─────────┘
                                 │
                    ┌────────────┼────────────┐
                    │                         │
                    ▼                         ▼
          ┌──────────────────┐      ┌──────────────────┐
          │  APPROVED by     │      │ REJECTED by      │
          │  Division Lead   │      │ Division Lead    │
          │                  │      │                  │
          │ pending_ga       │      │ rejected_        │
          │                  │      │ division         │
          └────────┬─────────┘      └──────────────────┘
                   │                        │
                   │                        └──> User Can:
                   │                             - Edit & Resubmit
                   │                             - Delete
                   │                             - Create New
                   │
                   ▼
          ┌──────────────────┐
          │  PENDING FINAL   │
          │  APPROVAL by GA  │
          │                  │
          │  pending_ga      │
          └────────┬─────────┘
                   │
        ┌──────────┼──────────┐
        │                     │
        ▼                     ▼
┌──────────────────┐  ┌──────────────────┐
│    APPROVED ✅   │  │  REJECTED by GA  │
│                  │  │                  │
│    approved      │  │  rejected_ga     │
└────────┬─────────┘  └──────────────────┘
         │                     │
         │                     └──> User Can:
         │                          - Delete
         │                          - Create New
         │
         ▼
┌──────────────────┐
│ BOOKING READY    │
│ TO USE!          │
│                  │
│ On Schedule Date │
│ Use Fasilitas    │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ COMPLETED/USED   │
│                  │
│ (Auto-update     │
│  after date)     │
└──────────────────┘

```

---

## 💾 DATABASE FLOW

```
┌─────────────────────────────────────────────────────────────┐
│                   DATABASE SCHEMA FLOW                      │
└─────────────────────────────────────────────────────────────┘

KARYAWAN CREATE BOOKING
         │
         ▼
┌──────────────────────────────────────────┐
│         BOOKINGS TABLE                   │
├──────────────────────────────────────────┤
│ id                                       │
│ booking_code (unique)                    │
│ user_id (FK -> users)                    │ ◄─── Karyawan Info
│ division_id (FK -> divisions)            │
│ booking_type (room/vehicle)              │
│ room_id (FK -> rooms) [nullable]         │ ◄─── Fasilitas
│ vehicle_id (FK -> vehicles) [nullable]   │
│ booking_date (DATE)                      │
│ start_time (TIME)                        │
│ end_time (TIME)                          │
│ purpose (TEXT)                           │
│ participants_count (INT)                 │
│ destination (VARCHAR) [nullable]         │
│ status ─────┐                            │
│             │                            │
│ division_approval_by (FK -> users)       │ ◄─── Division Lead
│ division_approval_at (TIMESTAMP)         │      Approval Info
│ division_approval_notes (TEXT)           │
│             │                            │
│ ga_approval_by (FK -> users)             │ ◄─── GA
│ ga_approval_at (TIMESTAMP)               │      Approval Info
│ ga_approval_notes (TEXT)                 │
│             │                            │
│ rejection_reason (TEXT)                  │ ◄─── Rejection Info
│ created_at (TIMESTAMP)                   │
│ updated_at (TIMESTAMP)                   │
└──────────────────────────────────────────┘
         │
         │
         ├─────────────────────────┬────────────────────────┐
         ▼                         ▼                        ▼
    ┌────────────┐          ┌────────────┐          ┌────────────┐
    │   ROOMS    │          │ VEHICLES   │          │    USERS   │
    ├────────────┤          ├────────────┤          ├────────────┤
    │ id (PK)    │          │ id (PK)    │          │ id (PK)    │
    │ name       │          │ name       │          │ email      │
    │ capacity   │          │ plat       │          │ name       │
    │ location   │          │ type       │          │ role       │
    │ is_active  │          │ capacity   │          │ division   │
    │            │          │ is_active  │          │            │
    └────────────┘          └────────────┘          └────────────┘
         ▲                         ▲                        ▲
         │                         │                        │
         └─────────────────────────┴────────────────────────┘
                        (Foreign Keys)

```

---


