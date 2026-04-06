# 📱 UI/UX Mockup - Menu Manajemen Pengguna

## Layout Overview

```
┌─────────────────────────────────────────┐
│ Manajemen Pengguna          ⚙️ Admin    │  <- AppBar (Hijau #00B477)
├─────────────────────────────────────────┤
│                                         │
│  ┌──────────────────────────────────┐  │
│  │ 👤                               │  │  <- User Card 1
│  │ John Doe                    ⋮    │  │  
│  │ john@example.com                 │  │
│  └──────────────────────────────────┘  │
│                                         │
│  ┌──────────────────────────────────┐  │
│  │ 👤                               │  │  <- User Card 2
│  │ Jane Smith                  ⋮    │  │
│  │ jane@example.com                 │  │
│  └──────────────────────────────────┘  │
│                                         │
│  ┌──────────────────────────────────┐  │
│  │ 👤                               │  │  <- User Card 3
│  │ Admin DIVUM                 ⋮    │  │
│  │ admin@example.com                │  │
│  └──────────────────────────────────┘  │
│                                         │
│  (Swipe down untuk refresh)            │
│                                         │
│                            ┌─────────┐ │
│                            │ + Tambah│ │  <- Floating Action Button
│                            │Pengguna │ │
│                            └─────────┘ │
└─────────────────────────────────────────┘
```

---

## Dialog: Tambah Pengguna

```
┌───────────────────────────────────────┐
│ Tambah Pengguna Baru              ✕  │  <- Dialog Header
├───────────────────────────────────────┤
│                                       │
│  Nama Lengkap *                       │
│  [Contoh: John Doe            ] 👤   │
│                                       │
│  Email *                              │
│  [Contoh: john@example.com  ] 📧    │
│                                       │
│  Password *                           │
│  [Minimal 6 karakter        ] 🔒    │
│                                       │
│  Nomor Telepon                        │
│  [Contoh: 08123456789      ] ☎️     │
│                                       │
│  Role *                               │
│  [Karyawan          ▼       ] ⚙️     │
│                                       │
│  Status *                             │
│  [Aktif             ▼       ] ✓     │
│                                       │
│  ┌────────────────────────────────┐  │
│  │  + Tambah Pengguna (Hijau)     │  │  <- Button
│  └────────────────────────────────┘  │
│                                       │
└───────────────────────────────────────┘
```

---

## Dialog: Edit Pengguna

```
┌───────────────────────────────────────┐
│ Edit Pengguna                     ✕  │
├───────────────────────────────────────┤
│                                       │
│  Nama Lengkap                         │
│  [John Doe                     ] 👤   │
│                                       │
│  Email                                │
│  [john@example.com             ] 📧  │
│                                       │
│  Nomor Telepon                        │
│  [081234567890                 ] ☎️  │
│                                       │
│  Role                                 │
│  [Karyawan          ▼          ] ⚙️  │
│                                       │
│  Status                               │
│  [Aktif             ▼          ] ✓   │
│                                       │
│  ┌────────────────────────────────┐  │
│  │  Simpan Perubahan (Hijau)      │  │
│  └────────────────────────────────┘  │
│                                       │
└───────────────────────────────────────┘
```

---

## Menu Card dengan Actions

```
┌──────────────────────────────────────┐
│ 👤                              ⋮    │  <- Icon, Name, Menu
│ John Doe                             │
│ john@example.com                     │
└──────────────────────────────────────┘

Menu Options (Klik ⋮):
┌──────────────┐
│ ✎ Edit       │  <- Edit user
├──────────────┤
│ 🗑️ Hapus     │  <- Delete user (Red)
└──────────────┘
```

---

## Hamburger Menu Structure

```
┌─────────────────────────────────────┐
│   ≡                                 │
├─────────────────────────────────────┤
│                                     │
│  [Header User]                      │
│  ┌─────────────────────────────────┐
│  │ 👤                          ⚙️  │
│  │                 Admin DIVUM     │
│  │ mirza@example.com               │
│  └─────────────────────────────────┘
│                                     │
│  📊 Dashboard                       │
│  📋 Daftar Pemesanan                │
│  📅 Kalender                        │
│                                     │
│  ─────────────────────────────────  │
│  ✓ Persetujuan Pending              │
│                                     │
│  ─────────────────────────────────  │
│  Manajemen Fasilitas                │
│  🏢 Kelola Ruangan                  │
│  🚗 Kelola Kendaraan                │
│                                     │
│  ─────────────────────────────────  │
│  Administrasi                       │
│  👥 Manajemen Pengguna     <-- NEW │
│  📊 Laporan & Statistik             │
│                                     │
│  ─────────────────────────────────  │
│  ❓ Bantuan                         │
│                                     │
│  ─────────────────────────────────  │
│  🚪 Logout (Red)                    │
│                                     │
└─────────────────────────────────────┘
```

---

## Loading State

```
┌──────────────────────────────────────┐
│ Manajemen Pengguna                   │
├──────────────────────────────────────┤
│                                      │
│                                      │
│            ⟳ Loading...              │  <- Loading Spinner
│                                      │
│                                      │
│         Mengambil data pengguna...   │
│                                      │
└──────────────────────────────────────┘
```

---

## Empty State

```
┌──────────────────────────────────────┐
│ Manajemen Pengguna                   │
├──────────────────────────────────────┤
│                                      │
│              👥                      │  <- Icon
│                                      │
│        Tidak Ada Pengguna            │  <- Title
│                                      │
│    Tambahkan pengguna baru untuk     │  <- Subtitle
│          memulai                     │
│                                      │
│    ┌──────────────────────────────┐  │
│    │ + Tambah Pengguna (Hijau)    │  │
│    └──────────────────────────────┘  │
│                                      │
└──────────────────────────────────────┘
```

---

## Error State

```
┌──────────────────────────────────────┐
│ Manajemen Pengguna                   │
├──────────────────────────────────────┤
│                                      │
│              ⚠️                      │  <- Error Icon
│                                      │
│             Error                   │  <- Title
│                                      │
│      Failed to fetch users           │  <- Error Message
│                                      │
│    ┌──────────────────────────────┐  │
│    │    Coba Lagi (Hijau)         │  │
│    └──────────────────────────────┘  │
│                                      │
└──────────────────────────────────────┘
```

---

## Toast Notifications

### Success Toast
```
┌──────────────────────────────────────┐
│ ✓ User created successfully          │  (Green background)
└──────────────────────────────────────┘
```

### Error Toast
```
┌──────────────────────────────────────┐
│ ✗ Failed to delete user              │  (Red background)
└──────────────────────────────────────┘
```

---

## Delete Confirmation Dialog

```
┌──────────────────────────────────────┐
│ Hapus Pengguna                       │
├──────────────────────────────────────┤
│                                      │
│  Apakah Anda yakin ingin menghapus  │
│  John Doe?                           │
│                                      │
│  ┌──────────────────────────────────┐
│  │ Batal (Gray)                     │
│  └──────────────────────────────────┘
│                                      │
│  ┌──────────────────────────────────┐
│  │ Hapus (Red)                      │
│  └──────────────────────────────────┘
│                                      │
└──────────────────────────────────────┘
```

---

## Color Scheme

### Primary Colors
- **Hijau (Primary)**: `#00B477` - Buttons, AppBar, FAB
- **Putih (Background)**: `#FFFFFF` - Cards, Dialogs
- **Abu-abu (Text)**: `#666666` - Secondary text
- **Abu-abu Light**: `#CCCCCC` - Borders, Dividers

### Status Colors
- **Hijau**: Aktif, Success, Positive actions
- **Merah**: Delete, Logout, Error, Danger
- **Kuning**: Warning, Loading
- **Biru**: Info, Secondary actions

### Text Colors
- **Gelap**: `#333333` - Primary text
- **Abu-abu**: `#999999` - Secondary text
- **Gelap terang**: `#666666` - Tertiary text

---

## Typography

### Sizes
- **AppBar Title**: 20px, Bold
- **Dialog Title**: 18px, Bold
- **Card Title (Name)**: 16px, Bold
- **Card Subtitle (Email)**: 13px, Regular
- **Label**: 12px, Regular
- **Body Text**: 14px, Regular

### Font
- **Font Family**: Flutter default (Roboto)
- **Weight**: Regular (400), Medium (500), Bold (700)

---

## Spacing & Layout

### Padding
- **Card**: 12px (all sides)
- **Dialog**: 20px (all sides)
- **List Item**: 8px vertical, 12px horizontal
- **AppBar**: 8px horizontal

### Margins
- **Card to Card**: 8px vertical
- **Section to Section**: 16px vertical
- **Dialog Edge**: 20px

### Border Radius
- **Cards**: 12px
- **Dialogs**: 12px
- **Buttons**: 8px
- **Chips**: 20px

---

## Animations

### Transitions
- **Dialog Open**: 300ms ease-in
- **Dialog Close**: 200ms ease-out
- **Loading Spin**: Continuous
- **Toast Fade**: 300ms fade-in, 200ms fade-out

### Effects
- **Card Tap**: Light gray overlay (0.1 opacity)
- **Button Tap**: Slightly darker shade
- **Swipe Refresh**: Pull to refresh with Spring animation

---

## Accessibility

### Touch Targets
- **Buttons**: Minimum 48dp height
- **Icons**: Minimum 48dp touch area
- **Cards**: Full width, easy to tap

### Visual
- **Contrast**: WCAG AA compliant
- **Icons**: Clear and recognizable
- **Text**: Readable size (14px+)

### Feedback
- **Loading**: Clear indicator
- **Errors**: Clear messages
- **Success**: Visual confirmation
- **Touch**: Visual feedback on interaction

---

## Landscape Mode

```
┌──────────────────────────────────────────────────────────┐
│ Manajemen Pengguna                      ⚙️ Admin        │
├──────────────────────────────────────────────────────────┤
│                                                           │
│  ┌──────────────────────┐  ┌──────────────────────────┐ │
│  │ 👤                   │  │ 👤                       │ │
│  │ John Doe        ⋮    │  │ Jane Smith          ⋮    │ │
│  │ john@example.com     │  │ jane@example.com         │ │
│  └──────────────────────┘  └──────────────────────────┘ │
│                                                           │
│  ┌──────────────────────┐  ┌──────────────────────────┐ │
│  │ 👤                   │  │ 👤                       │ │
│  │ Admin DIVUM     ⋮    │  │ Dimas P staff      ⋮    │ │
│  │ admin@example.com    │  │ dimas@example.com        │ │
│  └──────────────────────┘  └──────────────────────────┘ │
│                                                           │
│                              ┌────────────────────────┐  │
│                              │ + Tambah Pengguna      │  │
│                              └────────────────────────┘  │
│                                                           │
└──────────────────────────────────────────────────────────┘
```

---

## Notes

- **Spacing**: Konsisten menggunakan Material Design 3 guidelines
- **Icons**: Menggunakan Flutter Material icons
- **Colors**: Sesuai dengan brand color aplikasi (hijau #00B477)
- **Typography**: Menggunakan Roboto font (default Flutter)
- **Animations**: Smooth dan responsive
- **Responsive**: Tested di berbagai ukuran layar
- **Dark Mode**: Optional untuk future enhancement

---

**Design Guidelines**: Material Design 3
**Target Platforms**: Android, iOS, Web
**Accessibility**: WCAG AA
**Last Updated**: 2026-04-07

