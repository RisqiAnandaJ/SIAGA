# AI Coding Agent Rules & Guardrails (`rules.md`)

## Proyek: SIAGA — Sistem Informasi Garda Pengamanan Dalam
**Instansi:** BPSDM Kementerian Dalam Negeri  
**Platform Target:** Android (Flutter / Dart)

Dokumen ini adalah **instruksi sistem wajib (*mandatory system prompt / guardrails*)** bagi seluruh *AI Coding Agent* (seperti Cursor, Windsurf, GitHub Copilot, Claude Code, atau asisten AI lainnya) yang menulis, memodifikasi, atau meninjau kode pada repositori **SIAGA**.

Setiap baris kode yang dihasilkan **WAJIB** mematuhi aturan di bawah ini serta mengacu pada tiga dokumen utama proyek:
1. `PRD.md` — Kebutuhan fungsional, matriks RBAC, dan kriteria penerimaan.
2. `arsitektur.md` — Struktur direktori, skema PostgreSQL Supabase, dan arsitektur telemetri MQTT/GPS.
3. `design.md` — Sistem desain *Kemendagri Spatial Glass* (iOS 27 Liquid Glassmorphism) dan palet warna resmi.

---

## 1. Aturan Mutlak Teknologi & Pustaka (*Tech Stack Lock*)

### ✅ YANG BOLEH & WAJIB DILAKUKAN (DOs)
* **Framework & Bahasa:** Gunakan **Flutter** versi stabil terbaru dan bahasa **Dart** dengan *strict null-safety* (`sdk: '>=3.4.0 <4.0.0'`).
* **State Management Bawaan:** Kelola *state* antarmuka **hanya** menggunakan mekanisme bawaan Flutter SDK:
  * `StatefulWidget` dan `setState` untuk *state* lokal komponen/halaman.
  * `ValueNotifier`, `ChangeNotifier`, `ListenableBuilder`, `ValueListenableBuilder`, dan `InheritedWidget` untuk *state* lintas halaman (seperti sesi autentikasi, permission RBAC, dan sesi patroli aktif).
* **Layanan Backend & Penyimpanan:** Gunakan paket resmi `supabase_flutter` untuk autentikasi (Supabase Auth), basis data (PostgreSQL), dan penyimpanan foto bukti (Supabase Storage).
* **Login & Registrasi:** Login menggunakan **username + password** (`signInWithPassword`, username diterjemahkan ke email lewat RPC backend). Registrasi memakai `signUp` + `verifyOTP`, dan akun baru berstatus `pending` sampai disetujui PIC PAMDAL. Hanya akun `active` yang boleh masuk.
* **Layanan OTP Email:** Integrasikan pengiriman OTP email melalui **Brevo** yang terhubung dengan alur `verifyOTP` pada Supabase Auth, dipakai untuk verifikasi registrasi dan reset password. OTP wajib memiliki masa berlaku $5$ menit, maksimal $5$ percobaan, dan jeda kirim ulang $60$ detik.
* **Telemetri & Protokol Pesan:** Gunakan protokol **MQTT** (melalui broker **HiveMQ** dengan koneksi TLS port $8883$) untuk pengiriman telemetri koordinat GPS dan peristiwa *checkpoint* patroli.
* **Grafik & Dokumen PDF:**
  * Wajib menggunakan `syncfusion_flutter_charts` untuk seluruh visualisasi grafik di Dashboard dan Laporan.
  * Wajib menggunakan `syncfusion_flutter_pdf` untuk pembuatan dan ekspor dokumen laporan PDF.

### ❌ YANG DILARANG KERAS (DON'Ts)
* **DILARANG** menambahkan pustaka *state management* pihak ketiga seperti `flutter_bloc`, `bloc`, `riverpod`, `flutter_riverpod`, `get` (GetX), `mobx`, atau `redux` ke dalam `pubspec.yaml` tanpa instruksi tertulis dari pengembang manusia.
* **DILARANG** mengganti `syncfusion_flutter_charts` atau `syncfusion_flutter_pdf` dengan pustaka lain (seperti `fl_chart` atau `pdf`) kecuali diperintahkan secara eksplisit.
* **DILARANG** menganggap **HiveMQ** sebagai sumber sensor GPS. HiveMQ adalah broker pesan MQTT; koordinat GPS wajib dibaca dari sensor lokasi perangkat Android melalui izin sistem operasi.
* **DILARANG** menggunakan metode Flutter yang sudah usang (*deprecated*), seperti `.withOpacity(...)` (gunakan `.withValues(alpha: ...)`), atau `WillPopScope` (gunakan `PopScope`).

---

## 2. Aturan Keamanan, RBAC, & Kredensial (*Security Guardrails*)

### ✅ YANG BOLEH & WAJIB DILAKUKAN (DOs)
* **Prinsip *Least Privilege*:** Selalu periksa hak akses pengguna berdasarkan tiga peran resmi (**`PAMDAL`**, **`PIC PAMDAL`**, **`Pimpinan`**) dan daftar kode permission resmi di bawah ini sebelum menampilkan elemen UI atau menjalankan fungsi:
  * **Absensi:** `attendance.create`, `attendance.read.own`, `attendance.read`, `attendance.manage`
  * **Jadwal Jaga:** `schedule.create`, `schedule.read`, `schedule.update`, `schedule.delete`
  * **Patroli:** `patrol.create`, `patrol.read.own`, `patrol.read`, `patrol.manage`
  * **Kejadian:** `incident.create`, `incident.read.own`, `incident.read`, `incident.update`, `incident.manage`
  * **Dokumentasi:** `documentation.create`, `documentation.read`, `documentation.manage`
  * **Personel:** `personnel.create`, `personnel.read`, `personnel.update`, `personnel.delete`
  * **Pendaftaran:** `registration.read`, `registration.approve`
  * **Laporan:** `report.generate`, `report.export`
  * **Notifikasi:** `notification.read`, `notification.manage`
  * **Darurat:** `panicbutton.use`
* **Injeksi Konfigurasi Aman:** Ambil seluruh konfigurasi lingkungan (`SUPABASE_URL`, `SUPABASE_ANON_KEY`, `HIVEMQ_HOST`, `HIVEMQ_PORT`) menggunakan `String.fromEnvironment(...)` yang dikirim melalui `--dart-define`.
* **Penegakan RLS (*Row Level Security*):** Setiap kali membuat skrip migrasi SQL Supabase, wajib menyertakan `ALTER TABLE ... ENABLE ROW LEVEL SECURITY;` beserta `CREATE POLICY` yang memvalidasi `auth.uid()` dan peran pengguna.
* **Pencatatan Jejak Audit:** Setiap aksi perubahan data penting (seperti koreksi absensi, perubahan status kejadian, perubahan jadwal, atau penghapusan personel) wajib menyertakan identitas pengguna (`actor_id`) dan waktu kejadian (`timestamp`).

### ❌ YANG DILARANG KERAS (DON'Ts)
* **DILARANG** menanamkan (*hardcode*) kredensial rahasia ke dalam kode sumber Dart atau aset APK, termasuk:
  * `SUPABASE_SERVICE_ROLE_KEY`
  * Kunci API / SMTP Master **Brevo**
  * Kredensial administrator **HiveMQ**
* **DILARANG** mengandalkan penyembunyian tombol di antarmuka Flutter saja sebagai satu-satunya pengaman. Setiap operasi baca/tulis/hapus wajib diasumsikan harus lolos validasi RLS di sisi backend Supabase.
* **DILARANG** mempercayai `role`/`status` yang dikirim dari aplikasi. Pendaftar hanya boleh mengisi `requested_role`; `role_id` dan `status` hanya diubah lewat RPC yang memeriksa `registration.approve`.
* **DILARANG** menyimpan, mencatat (*log*), atau menampilkan password dalam bentuk apa pun di aplikasi, serta membuat akun PIC PAMDAL lewat alur pendaftaran publik.
* **DILARANG** membuat kode permission baru di luar daftar spesifikasi tanpa memperbarui matriks RBAC di dokumen spesifikasi dan skema database.
* **DILARANG** mengizinkan akses publik tanpa autentikasi (*public bucket tanpa otorisasi*) untuk berkas foto bukti kejadian di Supabase Storage.

---

## 3. Aturan Arsitektur & Kualitas Kode (*Code Architecture Rules*)

### ✅ YANG BOLEH & WAJIB DILAKUKAN (DOs)
* **Struktur Direktori Modular:** Tempatkan setiap berkas baru sesuai struktur yang ditetapkan di `arsitektur.md`:
  ```text
  lib/
  ├── main.dart
  ├── core/        # config, constants, rbac, services, utils, widgets (glass components)
  ├── models/      # Data models dengan fromJson, toJson, dan copyWith
  └── features/    # auth, dashboard, attendance, schedule, patrol, incident,
                   # documentation, notification, personnel, report, panic_button
  ```
* **Pemisahan Tanggung Jawab (*Separation of Concerns*):**
  * **UI/Screen:** Hanya menangani tata letak, animasi kaca, dan pengikatan *state*.
  * **Controller/Notifier:** Mengelola *state* halaman (`ChangeNotifier` / `ValueNotifier`) dan memanggil *Service/Repository*.
  * **Service/Repository:** Menangani komunikasi ke Supabase, HiveMQ MQTT, GPS perangkat, dan pembuatan PDF.
* **Penanganan Galat (*Error Handling*):** Bungkus seluruh panggilan jaringan (Supabase, MQTT, Storage) dan akses sensor perangkat di dalam blok `try-catch` yang terstruktur, serta tampilkan pesan kesalahan dalam Bahasa Indonesia yang santun dan jelas kepada pengguna.

### ❌ YANG DILARANG KERAS (DON'Ts)
* **DILARANG** menuliskan kueri Supabase (`Supabase.instance.client.from(...)`) atau logika koneksi MQTT secara langsung di dalam metode `build()` pada Widget.
* **DILARANG** menggunakan tipe data `dynamic` tanpa validasi tipe yang jelas, atau menggunakan operator pemaksa null (`!`) pada variabel yang berpotensi bernilai `null`.
* **DILARANG** membuat satu berkas Dart raksasa (*God File*) yang melebihi $400\text{ baris}$ kode; pecah menjadi sub-widget atau kelas layanan yang terpisah.

---

## 4. Aturan Telemetri GPS, Patroli, & Ketahanan Jaringan (*Patrol & Telemetry Rules*)

### ✅ YANG BOLEH & WAJIB DILAKUKAN (DOs)
* **Izin Lokasi Bertahap & Transparan:** Sebelum memulai patroli (`Start Patroli`), periksa apakah layanan GPS aktif dan minta izin lokasi dengan menampilkan dialog penjelasan yang jelas mengapa lokasi dibutuhkan.
* **Eksekusi Latar Belakang Android:** Gunakan mekanisme *Android Foreground Service* saat sesi patroli aktif agar pembacaan sensor GPS tidak dihentikan oleh sistem operasi ketika layar ponsel terkunci atau aplikasi berada di latar belakang.
* **Deteksi Lokasi Palsu (*Anti-Fake GPS*):** Selalu periksa properti `isMocked` pada setiap objek lokasi GPS yang diterima. Jika `isMocked == true`, tolak pencatatan absensi maupun *checkpoint* patroli dan tampilkan peringatan keamanan.
* **Perhitungan Jarak Checkpoint (Haversine):** Gunakan rumus Haversine untuk menghitung jarak $d$ antara posisi PAMDAL $(\phi_u, \lambda_u)$ dan koordinat *checkpoint* $(\phi_c, \lambda_c)$. Nyatakan *checkpoint* terlewati jika:
  $$d \le R_c + \min(a_u, \tau_{\text{maks}})$$
  di mana $R_c$ adalah radius *checkpoint*, $a_u$ adalah akurasi GPS saat itu, dan $\tau_{\text{maks}}$ adalah batas toleransi maksimum ($15\text{ meter}$).
* **Antrean Luring (*Offline Queue & Idempotency*):**
  * Sertakan `message_id` (UUID v4) dan `timestamp_utc` asli pada setiap payload telemetri dan *checkpoint*.
  * Jika koneksi MQTT atau internet terputus, simpan payload ke antrean lokal perangkat dan kirim ulang secara otomatis (`upsert` berdasarkan `message_id`) ketika jaringan kembali pulih.

### ❌ YANG DILARANG KERAS (DON'Ts)
* **DILARANG** membiarkan sensor GPS terus memantau lokasi pengguna setelah PAMDAL menekan tombol akhiri patroli (*Stop Patroli*) atau keluar dari sesi akun.
* **DILARANG** menghilangkan data *checkpoint* ketika perangkat kehilangan sinyal internet di area *blank spot*.
* **DILARANG** menggunakan waktu diterimanya pesan di server (`server_received_at`) sebagai waktu utama pencapaian *checkpoint*; gunakan `timestamp_utc` saat perangkat benar-benar berada di titik *checkpoint* (disertai pencatatan waktu sinkronisasi untuk audit).

---

## 5. Aturan Sistem Desain UI/UX (*Kemendagri Spatial Glass / iOS 27*)

Seluruh antarmuka yang dibuat oleh *AI Coding Agent* **WAJIB** mengikuti spesifikasi visual pada `design.md`:

### ✅ YANG BOLEH & WAJIB DILAKUKAN (DOs)
* **Palet Warna Resmi Logo Kementerian Dalam Negeri:**
  * `Abyssal Navy` (`#041E34`) & `Kemendagri Navy` (`#093B62`) — Latar belakang utama & identitas inti.
  * `Padi Gold` (`#EAA200`) & `Warm Amber` (`#FFC738`) — Aksen utama, tombol aksi primer, indikator aktif, dan lencana kehormatan.
  * `Kapas Emerald` (`#247D3B`) — Indikator sukses, status hadir, patroli aktif, dan *checkpoint* terverifikasi.
  * `Garuda Crimson` (`#E60000`) — **Panic Button (`SOS`)**, status darurat/bahaya, dan aksi destruktif.
  * `Pure Kapas White` (`#FFFFFF`) & `Silver Mist` (`#E2E8F0`) — Teks utama, ikon, dan pantulan tepi kaca.
* **Efek Material iOS 27 Liquid Glass:**
  * Gunakan komponen terpusat `SiagaGlassCard` dengan `BackdropFilter` ($\sigma_x = 24, \sigma_y = 24$ untuk kartu; $\sigma_x = 36, \sigma_y = 36$ untuk navigasi melayang/modal).
  * Gunakan sudut lengkung halus (*squircle* $r = 24\text{ px} \text{ s.d. } 28\text{ px}$ untuk kartu, dan kapsul penuh $r = 999\text{ px}$ untuk tombol/lencana).
  * Tambahkan garis tepi pantulan cahaya tipis (*Specular Rim Border* ketebalan $1.1\text{–}1.2\text{ px}$, warna putih opasitas $0.22\text{–}0.28$).
* **Optimasi Performa GPU Android:**
  * Wajib membungkus setiap widget yang menggunakan `BackdropFilter` dengan `RepaintBoundary`.
  * Batasi penggunaan `BackdropFilter` aktif maksimal $4\text{–}5$ komponen per layar. Untuk item di dalam daftar gulir panjang (`ListView.builder`), gunakan dekorasi kaca gradien semi-transparan statis tanpa `BackdropFilter` berat agar *frame rate* terjaga di $60\text{–}120\text{ FPS}$.
* **Tipografi & Angka:**
  * Aktifkan `FontFeature.tabularFigures()` pada setiap teks yang menampilkan jam digital, penghitung durasi patroli, koordinat GPS, dan kotak input OTP.
  * Pastikan rasio kontras teks utama terhadap latar belakang memenuhi minimal $\ge 7.5 : 1$ dan target sentuh tombol minimal $48 \times 48\text{ dp}$.

### ❌ YANG DILARANG KERAS (DON'Ts)
* **DILARANG** menggunakan warna standar Material Design bawaan Flutter (seperti `Colors.purple`, `Colors.deepPurple`, `Colors.blue`, atau `Colors.teal` acak) yang merusak identitas warna lambang Kementerian Dalam Negeri.
* **DILARANG** membuat tampilan padat yang penuh garis pembatas kaku (`Divider` tebal berlapis-lapis) atau bayangan hitam pekat yang kasar.
* **DILARANG** memasang `BackdropFilter` di dalam puluhan item `ListView` sekaligus karena akan menyebabkan *frame drop* (*jank*) pada perangkat Android kelas menengah/bawah.

---

## 6. Aturan Khusus Fitur Kritis (Panic Button, Dokumentasi, & Laporan)

1. **Panic Button (`panicbutton`):**
   * Wajib menampilkan tiga instansi darurat yang telah ditentukan:
     1. **RS JMC (Jakarta Medical Center)**
     2. **Polsek Pancoran**
     3. **Damkar Kalibata**
   * Data kontak ketiga layanan darurat tersebut **wajib tersedia secara lokal** di dalam aplikasi sehingga pengguna tetap dapat memicu panggilan telepon (`tel:`) atau membuka peta (`geo:`) meskipun perangkat sedang tidak terhubung ke internet.
   * Wajib menampilkan teks penafian (*disclaimer*) bahwa fitur Panic Button bukan pengganti layanan darurat nasional resmi.
2. **Dokumentasi Foto (`documentation`):**
   * Validasi tipe berkas hanya untuk citra (`jpg`, `jpeg`, `png`, `webp`).
   * Lakukan kompresi/pembatasan ukuran berkas di sisi klien agar ukuran unggahan maksimal $\le 5\text{ MB}$ per berkas.
3. **Laporan PDF (`report`):**
   * Hanya boleh diakses dan dieksekusi oleh peran yang memiliki permission `report.generate` dan `report.export` (**PIC PAMDAL** dan **Pimpinan**).
   * Gunakan komponen *date-time picker* untuk pemfilteran rentang tanggal laporan.

---

## 7. Protokol Kerja AI Coding Agent (*Agent Workflow*)

Setiap kali *AI Coding Agent* menerima perintah tugas (*prompt*) dari pengembang:

1. **Periksa Konteks Terlebih Dahulu:** Baca bagian terkait pada `PRD.md`, `arsitektur.md`, dan `design.md` sebelum menghasilkan kode.
2. **Validasi Hak Akses (RBAC):** Tanyakan pada diri sendiri: *"Role mana yang akan menggunakan layar/fungsi ini? Permission apa yang harus diperiksa?"*
3. **Jaga Konsistensi Bahasa:**
   * Gunakan **Bahasa Inggris** yang bersih dan deskriptif untuk penamaan kelas, variabel, fungsi, dan tabel database (contoh: `PatrolSession`, `CheckpointEvaluator`, `patrol_checkpoint_logs`).
   * Gunakan **Bahasa Indonesia** yang baku, jelas, dan sopan untuk seluruh teks antarmuka pengguna (UI *copywriting*), pesan validasi form, notifikasi, dan komentar dokumentasi bisnis.
4. **Tangani Ketidakpastian dengan Aman:** Apabila sebuah detail operasional belum ditetapkan (misalnya daftar titik koordinat *checkpoint* pasti di lingkungan BPSDM atau nomor telepon terbaru pos darurat), buatlah dalam bentuk konstanta/konfigurasi terpusat di `lib/core/constants/` yang diberi penanda `TODO(Konfirmasi-BPSDM): ...` agar mudah diperbarui tanpa mengubah logika kode.
5. **Verifikasi Mandiri Sebelum Selesai:** Pastikan tidak ada *unused imports*, tidak ada pelanggaran analisis statis (`flutter analyze`), tidak ada *secret* yang tertulis langsung di kode, dan seluruh komponen UI telah menerapkan gaya *Kemendagri Spatial Glass*.