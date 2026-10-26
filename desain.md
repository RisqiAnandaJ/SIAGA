# Sistem Desain Antarmuka & Pengalaman Pengguna (UI/UX Design System)

## SIAGA — Sistem Informasi Garda Pengamanan Dalam

* **Instansi:** BPSDM Kementerian Dalam Negeri
* **Platform Target:** Android (Flutter / Dart)
* **Tema Visual:** *Kemendagri Spatial Glass* (Modern Minimalist & iOS 27 Liquid Glassmorphism)
* **Versi Dokumen:** $1.0$

---

## 1. Filosofi & Visi Desain

Desain antarmuka **SIAGA** menggabungkan **wibawa institusional Kementerian Dalam Negeri** dengan estetika antarmuka masa depan **iOS 27 Spatial Liquid Glass**. 

Mengingat pengguna utama (PAMDAL, PIC PAMDAL, dan Pimpinan) membutuhkan aplikasi yang cepat dipahami di situasi lapangan maupun ruang rapat, desain menerapkan tiga prinsip utama:

1. **Modern & Ultra-Simple (*Zero Clutter*):** Menghilangkan dekorasi berlebih dan garis pembatas kaku. Setiap layar hanya menampilkan informasi paling relevan sesuai peran (*role*) dengan ruang kosong (*whitespace*) yang lega.
2. **iOS 27 Liquid Glass (*Tactile Translucency*):** Komponen kartu, bilah navigasi, dan lembar dialog (*bottom sheet*) dirender seperti kepingan kaca optik berlapis yang membiaskan warna latar di belakangnya (*real-time Gaussian blur*), dilengkapi pantulan cahaya tipis di tepi atas (*specular rim border*).
3. **Identitas Warna Logo Kemendagri:** Seluruh spektrum warna antarmuka diekstraksi secara presisi dari elemen visual lambang Kementerian Dalam Negeri (Biru Perisai, Emas Padi & Bintang, Hijau Kapas, Merah Garuda, dan Putih Pita).

---

## 2. Sistem Warna (Ekstraksi Logo Kementerian Dalam Negeri)

Berikut adalah pemetaan warna langsung dari elemen lambang Kementerian Dalam Negeri ke dalam fungsi semantik antarmuka SIAGA:

### 2.1 Palet Warna Inti (*Core Brand Palette*)

| Elemen Logo Kemendagri | Nama Token Warna | Kode HEX | Nilai RGB | Fungsi pada Antarmuka SIAGA |
| :--- | :--- | :--- | :--- | :--- |
| **Perisai Utama** | `Kemendagri Navy` | `#093B62` | $(9, 59, 98)$ | Warna identitas utama, latar kanvas *Spatial Dark*, dan tombol aksi utama. |
| **Bayangan Perisai** | `Abyssal Navy` | `#041E34` | $(4, 30, 52)$ | Dasar kanvas kedalaman (*deep background*) untuk menonjolkan efek kaca. |
| **Bintang, Padi & Rantai** | `Padi Gold` | `#EAA200` | $(234, 162, 0)$ | Aksen kehormatan, indikator aktif, sorotan *checkpoint*, & lencana Pimpinan/PIC. |
| **Kilau Emas Garuda** | `Warm Amber` | `#FFC738` | $(255, 199, 56)$ | Gradien pendaran (*glow*) pada tepi kaca aktif dan grafik statistik. |
| **Daun Kapas** | `Kapas Emerald` | `#247D3B` | $(36, 125, 59)$ | Status berhasil (*Success*), absensi hadir, patroli aktif, & *checkpoint* terlewati. |
| **Perisai Merah Garuda** | `Garuda Crimson` | `#E60000` | $(230, 0, 0)$ | **Panic Button**, peringatan bahaya, status insiden darurat, & aksi hapus. |
| **Kelopak Kapas & Teks** | `Pure Kapas White` | `#FFFFFF` | $(255, 255, 255)$ | Teks utama pada kanvas gelap, ikonografi, dan sumber pantulan cahaya kaca. |
| **Pita Bhinneka** | `Silver Mist` | `#E2E8F0` | $(226, 232, 240)$ | Teks sekunder, label atribut, dan latar belakang *Daylight Mode*. |

### 2.2 Token Permukaan Kaca (*iOS 27 Glass Surface Tokens*)

Aplikasi mendukung dua suasana pencahayaan adaptif: **Spatial Navy Mode** (tampilan khas utama yang merepresentasikan perisai biru Kemendagri) dan **Daylight Pearl Mode** (kontras tinggi untuk penggunaan patroli di bawah terik matahari siang).

| Token Material Kaca | Spatial Navy Mode (Default) | Daylight Pearl Mode (Outdoor) | Kegunaan Komponen |
| :--- | :--- | :--- | :--- |
| `glass.surface.low` | `rgba(255, 255, 255, 0.06)` | `rgba(255, 255, 255, 0.55)` | Kartu daftar riwayat, baris jadwal jaga, latar grafik. |
| `glass.surface.medium` | `rgba(255, 255, 255, 0.11)` | `rgba(255, 255, 255, 0.72)` | Kartu utama dashboard, kartu status patroli, form input. |
| `glass.surface.high` | `rgba(14, 74, 122, 0.45)` | `rgba(255, 255, 255, 0.88)` | *Floating Bottom Bar*, dialog modal, notifikasi *checkpoint*. |
| `glass.surface.gold` | `rgba(234, 162, 0, 0.14)` | `rgba(234, 162, 0, 0.18)` | Sorotan kartu penting, lencana peran, & tombol utama. |
| `glass.surface.danger` | `rgba(230, 0, 0, 0.22)` | `rgba(230, 0, 0, 0.15)` | Kartu *Panic Button* dan banner insiden kritis. |
| `glass.border.specular` | `rgba(255, 255, 255, 0.28)` | `rgba(255, 255, 255, 0.90)` | Garis tepi pantulan cahaya atas-kiri pada sudut $135^\circ$. |
| `glass.border.subtle` | `rgba(255, 255, 255, 0.07)` | `rgba(9, 59, 98, 0.10)` | Garis tepi bawah-kanan untuk efek ketebalan keping kaca. |

---

## 3. Spesifikasi Material "iOS 27 Liquid Glass"

Karakteristik utama gaya visual **iOS 27** terletak pada efek kaca cair (*Liquid Glass*) yang memiliki pembiasan latar belakang halus, ketebalan optik di bagian pinggir (*specular rim*), serta pendaran warna latar (*ambient mesh glow*).

```
       Cahaya Pantul Atas-Kiri (135 deg, Putih Opasitas 28%)
     ╭───────────────────────────────────────────────────────╮
     │  [ Ikon Emas ]   Status Patroli Aktif         [Live]  │
     │                                                       │
     │  Backdrop Blur: sigma_x = 28, sigma_y = 28            │
     │  Isian Kaca   : Putih / Biru Kemendagri (alpha 0.11)  │
     │  Sudut Lengkung: Continuous Squircle (r = 28 px)      │
     ╰───────────────────────────────────────────────────────╯
       Bayangan Tepi Bawah-Kanan (Putih Opasitas 5% + Drop Shadow)
```

### 3.1 Parameter Fisika & Matematika Kaca

1. **Gaussian Backdrop Blur:**
   * Kartu Standar: $\sigma_x = 24$, $\sigma_y = 24$
   * Navigasi Melayang & Modal: $\sigma_x = 36$, $\sigma_y = 36$
2. **Sudut Lengkung (*Continuous Squircle Corner*):**
   * Kartu Utama & Panel: $r = 28\text{ px}$ menggunakan `ContinuousRectangleBorder` atau `BorderRadius.circular(24)`
   * Tombol Aksi & Lencana (*Pills*): $r = 999\text{ px}$ (*Full Capsule*)
   * Input Field & Thumbnail Dokumentasi: $r = 16\text{ px}$
3. **Gradien Bingkai Spekular (*Specular Rim Border*):**
   * Ketebalan garis tepi: $1.2\text{ px}$
   * Sudut gradien: $\theta = 135^\circ$ (dari kiri-atas menuju kanan-bawah)
   * Titik henti opasitas (*color stops*):
     $$\alpha_{\text{stop}}(0.0) = 0.35, \quad \alpha_{\text{stop}}(0.4) = 0.10, \quad \alpha_{\text{stop}}(1.0) = 0.04$$
4. **Latar Belakang Ambient (*Mesh Orbs*):**
   * Di belakang lapisan kaca, kanvas `#041E34` memiliki tiga bola pendaran cahaya lembut (*radial gradient orbs* dengan radius $\ge 260\text{ px}$):
     * Orb 1 (Kiri Atas): `Kemendagri Navy` (`#0D5287`, $\alpha = 0.55$)
     * Orb 2 (Kanan Tengah): `Padi Gold` (`#EAA200`, $\alpha = 0.14$)
     * Orb 3 (Bawah): `Kapas Emerald` (`#247D3B`, $\alpha = 0.12$)

---

## 4. Tipografi & Hierarki Teks

Menggunakan rupa huruf tanpa kait (*sans-serif*) modern bergaya geometris-humanis: **Plus Jakarta Sans** atau **Inter** (dengan *fallback* sistem ke `SF Pro Display` / `Roboto`).

| Tingkat Tipografi | Ukuran ($px$) | Ketebalan (*Weight*) | Jarak Baris (*Line Height*) | Penggunaan pada Aplikasi |
| :--- | :--- | :--- | :--- | :--- |
| `Display Large` | $32\text{ px}$ | Bold ($700$) | $1.20$ | Jam digital absensi, penghitung durasi patroli aktif. |
| `Heading 1` | $24\text{ px}$ |Bold ($700$) | $1.25$ | Judul halaman utama, sapaan nama personel di Dashboard. |
| `Heading 2` | $18\text{ px}$ | SemiBold ($600$) | $1.30$ | Judul kartu kaca, nama titik *checkpoint*, kategori insiden. |
| `Body Large` | $16\text{ px}$ | Medium ($500$) | $1.45$ | Isi deskripsi laporan kejadian, nama personel pada jadwal. |
| `Body Regular` | $14\text{ px}$ | Regular ($400$) | $1.45$ | Teks sekunder, keterangan notifikasi, alamat darurat. |
| `Caption / Pill` | $12\text{ px}$ | SemiBold ($600$) | $1.20$ | Lencana status, koordinat GPS, label permission/role. |

> **Aturan Angka Monospace (`Tabular Figures`):** Seluruh tampilan koordinat GPS $(\phi, \lambda)$, durasi waktu patroli (`01:42:19`), dan input 6-digit kode OTP wajib mengaktifkan fitur `FontFeature.tabularFigures()` agar tata letak tidak bergeser saat angka berubah setiap detik.

---

## 5. Tata Letak & Navigasi (*Spatial Layout*)

### 5.1 Bilah Navigasi Kapsul Melayang (*Floating Glass Pill Dock*)

Alih-alih menggunakan `BottomNavigationBar` kaku yang menempel di tepi bawah layar, SIAGA menerapkan **Floating Glass Capsule** dengan margin bawah $20\text{ px}$ dan margin kiri-kanan $24\text{ px}$:

* Tinggi kapsul: $68\text{ px}$ dengan efek blur $\sigma = 36$.
* Item menu yang aktif memiliki indikator gelembung kaca emas (`glass.surface.gold`) yang bergeser secara mulus menggunakan animasi pegas (`Curves.easeOutBack`, durasi $280\text{ ms}$).
* **Susunan Tab Berdasarkan Role:**
  * **PAMDAL:** `Beranda` • `Absensi & Jadwal` • `Patroli GPS` • `Insiden`
  * **PIC PAMDAL:** `Dashboard` • `Operasional` (Jadwal/Absensi/Patroli) • `Insiden` • `Personel` • `Laporan`
  * **Pimpinan:** `Ringkasan` • `Monitoring` • `Insiden` • `Laporan PDF`

### 5.2 Tombol Aksi Darurat Terpadu (*Quick Panic Orb*)

Tombol **Panic Button** ditempatkan pada sudut kanan atas (*Top App Bar Glass Action*) dalam bentuk kapsul kaca merah berpendar (`#E60000`) bertuliskan **`SOS`** agar selalu dapat dijangkau dalam $1$ ketukan dari layar mana pun tanpa menghalangi navigasi bawah.

---

## 6. Spesifikasi Desain per Modul Fitur

### 6.1 Layar Login, Registrasi & Verifikasi OTP (`auth`)

* **Tampilan Visual:**
  * Di bagian tengah atas, tampil **Logo Kementerian Dalam Negeri** dengan efek pendaran emas lembut di belakang perisai.
  * Judul **"SIAGA"** menggunakan warna putih bersih dengan subjudul *"BPSDM Kementerian Dalam Negeri"* berwarna emas (`#EAA200`).
* **Layar Login:**
  * *Liquid Glass Card* tunggal berisi input **Username**, input **Password** (dengan ikon tampil/sembunyi), tautan **"Lupa password?"**, dan tombol kapsul **"Masuk"** bergradien `Padi Gold` (`#EAA200` $\rightarrow$ `#FFC738`) dengan teks biru tua tegas (`#041E34`).
  * Tautan **"Belum punya akun? Daftar"** di bawah kartu. Pesan galat login ditampilkan generik di bawah input.
* **Layar Registrasi:**
  * Formulir dalam kartu kaca: Nama Lengkap, Username, Password + Konfirmasi, Email, Nomor Handphone (awalan `+62`), dan pemilih **Role** (dua pilihan kapsul: `PAMDAL` / `Pimpinan`). Catatan kecil: *"Role akan aktif setelah disetujui PIC PAMDAL."*
  * Password tanpa indikator kekuatan atau aturan kompleksitas. Galat validasi tampil inline per kolom; tombol **"Daftar & Kirim OTP"** aktif setelah seluruh kolom valid.
* **Input OTP Brevo:**
  * Menampilkan $6$ kotak kaca individual (`48x56 px`). Kotak yang sedang aktif memancarkan bingkai emas menyala (`#EAA200`, ketebalan $1.8\text{ px}$).
  * Menampilkan hitung mundur masa berlaku dan tombol **"Kirim ulang"** yang aktif setelah jeda $60$ detik.
* **Layar Menunggu Persetujuan:** kartu kaca berisi status (*Menunggu* / *Ditolak* beserta alasan) dan tombol **"Keluar"**; tidak ada akses ke modul lain.
* **Antrean Pendaftaran (PIC PAMDAL):** daftar kartu kaca pendaftar (nama, username, email, HP, role diminta) dengan aksi **Setujui** (dapat mengubah role) dan **Tolak** (dialog alasan). Gunakan kartu semi-transparan statis tanpa `BackdropFilter` pada item daftar.

### 6.2 Dashboard, Grafik, & Laporan (`dashboard` & `report`)

* **Header Profil & Role Pill:** Menampilkan foto/avatar personel, nama lengkap, serta lencana kaca berwarna emas untuk `PIC PAMDAL` / `Pimpinan` atau hijau zamrud untuk `PAMDAL`.
* **Bento Stat Grid ($2 \times 2$):** Empat kartu kaca ringkas yang menampilkan metrik harian (Hadir Hari Ini, Patroli Aktif, Insiden Terbuka, Checkpoint Tercapai).
* **Gaya Grafik (`syncfusion_flutter_charts`):**
  * Latar belakang grafik dibuat transparan (`Colors.transparent`) karena sudah berada di dalam kartu kaca.
  * Garis kisi (*grid lines*) dibuat sangat tipis (`rgba(255, 255, 255, 0.06)`).
  * Seri data utama menggunakan gradien vertikal `Padi Gold` (`#FFC738` ke `rgba(234, 162, 0, 0.05)`) dan seri pembanding menggunakan `Kapas Emerald` (`#247D3B`) serta `Cyan Glass` (`#38BDF8`).
* **Filter & Ekspor PDF (`syncfusion_flutter_pdf`):**
  * Pemilih rentang tanggal (*date-time picker*) muncul sebagai *Frosted Glass Bottom Sheet* dengan roda gulir (*Cupertino-style glass wheel*) atau kalender minimalis.

### 6.3 Modul Patroli & Telemetri GPS (`patrol`)

Layar ini dirancang untuk visibilitas maksimal ketika PAMDAL berjalan di lapangan:

* **Pusat Kendali Patroli (*Interactive Liquid Orb*):**
  * Saat belum mulai: Tombol lingkaran kaca berdiameter $160\text{ px}$ di tengah layar dengan pendaran emas-biru bertuliskan **"START PATROLI"**.
  * Saat patroli aktif: Lingkaran berubah menjadi radar kaca berwarna **Hijau Kapas (`#247D3B`)** dengan animasi gelombang cincin konsentris (*pulsing ripple*) yang menandakan telemetri GPS & MQTT sedang aktif mengirim data.
* **Kartu Status Telemetri & Checkpoint:**
  * Menampilkan indikator koneksi MQTT HiveMQ (titik hijau menyala = *Online*, titik kuning = *Antrean Lokal/Offline*), akurasi GPS dalam meter ($\pm 4.2\text{ m}$), dan progres *checkpoint* (misal: $4 / 6$ *Checkpoint Selesai*).
* **Notifikasi Checkpoint Terlewati (*Dynamic Glass Banner*):**
  * Ketika rumus Haversine mendeteksi PAMDAL memasuki radius *checkpoint*, sebuah kapsul kaca melayang turun dari bagian atas layar (*iOS Dynamic Island style*) dengan ikon centang hijau, getaran haptik (*haptic feedback*), dan pesan: *"Checkpoint Pos Utama Terverifikasi • 01:15 WIB"*.

### 6.4 Modul Absensi & Jadwal Jaga (`attendance` & `schedule`)

* **Kartu Absensi Satu Ketukan:** Menampilkan jam waktu nyata berukuran `Display Large` ($32\text{ px}$), jadwal sif aktif personel hari itu, status validasi lokasi GPS, serta tombol geser kaca (*Slide to Check-In*) untuk mencegah ketukan tidak sengaja.
* **Garis Waktu Jadwal Jaga:** Daftar jadwal menggunakan tata letak lini masa vertikal (*timeline*) dengan kartu kaca berlapis. Sif yang sedang berlangsung diberi aksen bilah kiri berwarna `Padi Gold` (`#EAA200`).

### 6.5 Modul Pelaporan Kejadian & Dokumentasi (`incident` & `documentation`)

* **Formulir Minimalis:** Input kategori kejadian menggunakan *Selectable Glass Chips* (pilihan kapsul kaca yang langsung menyala saat disentuh tanpa perlu membuka *dropdown* panjang).
* **Unggah Bukti Foto (`documentation`):**
  * Kotak pratinjau foto memiliki bingkai kaca dengan tombol kamera mengambang di pojok.
  * Saat foto sedang diunggah ke Supabase Storage, permukaan foto menampilkan efek sapuan kaca buram (*frosted shimmer progress*) yang berangsur menjadi jernih ($100\%$ tajam) ketika unggahan selesai.

### 6.6 Modul Panic Button (`panicbutton`)

Ketika pengguna menekan tombol **`SOS`**, layar menampilkan lembar kaca penuh (*Full-Screen Frosted Emergency Overlay*) dengan rona latar merah tua transparan:

* Menampilkan **3 Kartu Kaca Darurat Berukuran Besar** (tinggi masing-masing $96\text{ px}$ untuk kemudahan ketukan dalam kondisi panik):
  1. **RS JMC (Jakarta Medical Center)** — Aksen Hijau Medis / Putih dengan ikon Ambulans.
  2. **Polsek Pancoran** — Aksen Kuning Emas / Biru dengan ikon Perisai Kepolisian.
  3. **Damkar Kalibata** — Aksen Merah Garuda (`#E60000`) dengan ikon Pemadam Kebakaran.
* Setiap kartu memiliki dua tombol kapsul kaca langsung: **[ Panggil Sekarang ]** dan **[ Buka Peta ]**.
* Di bagian bawah terdapat teks penafian (*disclaimer*) dengan kontras jelas bahwa fitur ini adalah akses cepat pendamping dan bukan pengganti layanan darurat resmi.

---

## 7. Panduan Implementasi Kode Komponen Flutter

Untuk memastikan keseragaman efek kaca **iOS 27** di seluruh halaman tanpa menggunakan pustaka eksternal yang berat, tim pengembang dapat menggunakan komponen dasar `SiagaLiquidGlass` berikut:

```dart
import 'dart:ui';
import 'package:flutter/material.dart';

/// Palet Warna Resmi SIAGA - Ekstraksi Logo Kementerian Dalam Negeri
class SiagaColors {
  static const Color abyssalNavy = Color(0xFF041E34);
  static const Color kemendagriNavy = Color(0xFF093B62);
  static const Color padiGold = Color(0xFFEAA200);
  static const Color warmAmber = Color(0xFFFFC738);
  static const Color kapasEmerald = Color(0xFF247D3B);
  static const Color garudaCrimson = Color(0xFFE60000);
  static const Color pureWhite = Color(0xFFFFFFFF);
}

/// Widget Kartu Kaca Bergaya iOS 27 (Liquid Glassmorphism)
class SiagaGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double blurSigma;
  final Color? tintColor;

  const SiagaGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 26.0,
    this.blurSigma = 24.0,
    this.tintColor,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              // Lapisan permukaan kaca dengan gradien translusen halus
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  (tintColor ?? SiagaColors.pureWhite).withValues(alpha: 0.14),
                  (tintColor ?? SiagaColors.pureWhite).withValues(alpha: 0.05),
                ],
              ),
              // Efek pantulan cahaya tepi (Specular Rim Border)
              border: Border.all(
                color: SiagaColors.pureWhite.withValues(alpha: 0.22),
                width: 1.1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
```

---

## 8. Standar Aksesibilitas & Optimasi Performa Android

1. **Rasio Kontras Keterbacaan:** Teks utama berwarna putih (`#FFFFFF`) di atas kartu kaca berlatar `Kemendagri Navy` (`#093B62` / `#041E34`) menjaga rasio kontras $\ge 7.5 : 1$ (melampaui standar WCAG AAA), sehingga tetap tajam saat dilihat personel di pos jaga maupun di luar ruangan.
2. **Ukuran Target Sentuh (*Touch Target*):** Seluruh tombol operasional (terutama **Start Patroli**, **Check-In Absensi**, dan **Panic Button**) wajib memiliki dimensi area sentuh minimum $48 \times 48\text{ dp}$ (dan minimal $64\text{ dp}$ untuk aksi darurat).
3. **Optimasi GPU Flutter untuk Efek Blur:**
   * Bungkus setiap komponen `BackdropFilter` dengan `RepaintBoundary` agar perhitungan *shader blur* tidak diulang saat elemen lain di layar bergerak.
   * Batasi jumlah `BackdropFilter` aktif yang bertumpuk pada satu layar maksimal $4$ hingga $5$ lapisan utama; untuk daftar panjang (`ListView` riwayat patroli/absensi), gunakan gradien kaca semi-transparan statis (`LinearGradient` dengan `alpha: 0.10` dan `border` spekular) agar laju bingkai tetap stabil di $60\text{–}120\text{ FPS}$ pada berbagai kelas perangkat Android personel.