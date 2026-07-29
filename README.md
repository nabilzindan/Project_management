# Aplikasi Manajemen Toko Sederhana (POS Toko)

Aplikasi Flutter untuk mengelola produk, pesanan, laporan penjualan harian,
dan cetak kwitansi PDF. Dibangun dengan **Clean Architecture** + **Repository
Pattern** + **Provider** (state management) + **SQLite** (`sqflite`).

## 1. Struktur Proyek

```
lib/
├── core/
│   ├── constants/app_constants.dart      # Info toko, nama tabel, dsb.
│   ├── database/database_helper.dart     # Setup & migrasi SQLite
│   ├── services/
│   │   ├── injector.dart                 # Dependency Injection manual
│   │   └── pdf_service.dart              # Generator PDF kwitansi
│   ├── utils/formatters.dart             # Format Rupiah & tanggal
│   └── widgets/app_widgets.dart          # Widget reusable (loading, dialog, snackbar)
│
├── features/
│   ├── products/  (data / domain / presentation)
│   ├── orders/    (data / domain / presentation)
│   └── reports/   (data / domain / presentation)
│
└── main.dart
```

Setiap fitur mengikuti alur:
`UI -> Provider -> UseCase -> Repository (interface) -> RepositoryImpl -> LocalDataSource -> SQLite`

## 2. Instalasi

```bash
flutter pub get
```

Pastikan sudah menjalankan `flutter create .` sekali jika folder platform
(`android/`, `ios/`, dll.) belum ada, lalu jalankan:

```bash
flutter run
```

## 3. Database

Dibuat otomatis saat aplikasi pertama kali berjalan (lihat
`lib/core/database/database_helper.dart`), berisi tabel:
`products`, `orders`, `order_items` (relasi one-to-many via `order_id` & `product_id`).

## 4. Fitur Utama

| Fitur | Halaman |
|---|---|
| Dashboard | `features/dashboard/presentation/pages/dashboard_page.dart` |
| CRUD Produk + pencarian | `features/products/presentation/pages/` |
| Buat Pesanan (multi produk, hitung total otomatis, kurangi stok) | `features/orders/presentation/pages/order_form_page.dart` |
| Detail Pesanan | `features/orders/presentation/pages/order_detail_page.dart` |
| Laporan Penjualan Harian | `features/reports/presentation/pages/report_page.dart` |
| Preview / Print / Save PDF Kwitansi | `features/orders/presentation/pages/pdf_preview_page.dart` |

## 5. Validasi Bisnis

- **Produk**: nama tidak boleh kosong, harga > 0, stok >= 0.
- **Pesanan**: minimal 1 produk, jumlah tidak boleh melebihi stok tersedia.

Validasi ditegakkan di layer **UseCase** (`product_usecases.dart`,
`order_usecases.dart`) sehingga konsisten dipakai baik dari UI maupun test.

## 6. Pengujian

Unit test tersedia di folder `test/` menggunakan *fake in-memory repository*
(tanpa perlu database nyata):

```bash
flutter test
```

Mencakup:
- `product_usecases_test.dart` — validasi nama/harga/stok produk.
- `order_usecases_test.dart` — validasi minimal 1 produk & jumlah vs stok.

Untuk pengujian manual end-to-end:
1. Tambah beberapa produk lewat menu **Daftar Produk**.
2. Buat pesanan baru, pilih produk & jumlah, submit.
3. Cek stok produk berkurang otomatis.
4. Buka **Laporan Penjualan Harian** untuk melihat rekap.
5. Buka detail pesanan → **Cetak Kwitansi PDF** → coba Preview, Print, dan Save.

## 7. Kustomisasi

Ubah nama toko, alamat, dan pesan terima kasih di
`lib/core/constants/app_constants.dart`.
# Project_management
