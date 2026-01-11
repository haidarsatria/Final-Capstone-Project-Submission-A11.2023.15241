# WarungKu - Aplikasi Point of Sales (POS) UMKM

WarungKu adalah aplikasi manajemen kasir dan stok barang berbasis mobile yang dirancang untuk membantu operasional UMKM secara efisien. Aplikasi ini menerapkan prinsip **Offline-First**, sehingga dapat berjalan penuh tanpa koneksi internet.

## 🚀 Fitur Utama

### 1. Manajemen Inventaris (Inventory)
- **CRUD Produk:** Tambah, Edit, dan Hapus data barang dengan mudah.
- **Barcode Scanner:** Input barang otomatis menggunakan kamera HP (terintegrasi dengan `mobile_scanner`).
- **Real-time Stock Update:** Stok berkurang otomatis saat transaksi terjadi.

### 2. Transaksi Kasir (Point of Sales)
- **Smart Cart System:** Logika keranjang belanja pintar (mencegah duplikasi item, *quantity increment* otomatis).
- **Kalkulasi Otomatis:** Menghitung subtotal dan total harga secara *real-time* menggunakan State Management.
- **Pembayaran:** Mendukung pencatatan pembayaran tunai dan kalkulasi kembalian.

### 3. Laporan & Analitik
- **Dashboard Grafik:** Visualisasi tren penjualan harian/bulanan menggunakan `fl_chart`.
- **Riwayat Transaksi:** Log lengkap setiap transaksi yang terjadi (disimpan lokal).
- **Cetak Struk:** Generate bukti transaksi ke format PDF (siap cetak atau share).

---

## 🛠️ Tech Stack & Arsitektur

Project ini dibangun dengan **Flutter** menggunakan pendekatan **Feature-First Architecture** untuk memastikan kode yang modular, rapi, dan mudah dikembangkan (*scalable*).

### Teknologi yang Digunakan:
- **Framework:** Flutter SDK (Dart)
- **State Management:** Provider
  - Menggunakan `ChangeNotifier` untuk memisahkan *Business Logic* dari UI.
  - Implementasi `Consumer` widget untuk performa render yang efisien (hanya rebuild widget yang perlu).
- **Local Database:** SQFlite (SQLite)
  - Menggunakan *Singleton Pattern* pada `DatabaseHelper`.
  - Tabel relasional antara `products` dan `transactions`.
- **UI & Tools:**
  - `fl_chart`: Untuk visualisasi data grafik penjualan.
  - `mobile_scanner`: Untuk pemindaian barcode/QR via kamera.
  - `intl`: Untuk format mata uang Rupiah (`CurrencyFormatter`).

### Struktur Folder (Feature-First)
``` text
lib/
├── core/                    # Logic dasar & konfigurasi global
│   ├── constants/           # Warna (AppColors) & String statis
│   ├── database/            # Setup SQLite (DatabaseHelper Singleton)
│   ├── services/            # Service eksternal (PDF, Notification)
│   └── utils/               # Helper (Format Rupiah, Tanggal)
│
├── features/                # Modul fitur utama (Modular)
│   ├── inventory_analytics/ # Dashboard grafik & laporan stok
│   ├── products/            # CRUD Barang & Scanner
│   └── sales/               # Kasir (POS), Cart, & Transaksi
│
└── main.dart                # Entry point aplikasi

---

## ⚙️ Cara Instalasi & Menjalankan (PENTING!)

Karena project ini menggunakan beberapa library khusus yang membutuhkan konfigurasi native Android, harap ikuti langkah berikut untuk menghindari error build.

### Prasyarat
- Flutter SDK (Versi Terbaru)
- Java JDK 17 (Wajib untuk kompatibilitas Gradle terbaru)
- Android SDK & NDK

### Langkah Instalasi
1. **Clone Repository / Extract Folder**
   Simpan folder project di lokasi yang aman.

2. **Bersihkan Cache (Wajib)**
   Jalankan perintah ini di terminal untuk membersihkan sisa build lama dan menghindari konflik:
   ```bash
   flutter clean
   flutter pub get
