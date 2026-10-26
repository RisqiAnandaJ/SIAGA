# Dokumen Arsitektur Sistem
## SIAGA — Sistem Informasi Garda Pengamanan Dalam
**Instansi:** BPSDM Kementerian Dalam Negeri  
**Platform Target:** Android (Flutter / Dart)  
**Status Dokumen:** Rancangan Arsitektur Awal (v1.0)

---

## 1. Pendahuluan

Dokumen ini menjabarkan rancangan arsitektur perangkat lunak untuk aplikasi **SIAGA (Sistem Informasi Garda Pengamanan Dalam)**. Arsitektur ini dirancang untuk memenuhi kebutuhan operasional pengamanan dalam di lingkungan BPSDM Kementerian Dalam Negeri, yang mencakup pengelolaan kehadiran, jadwal jaga, pemantauan patroli berbasis telemetri GPS dan MQTT, pelaporan kejadian, dokumentasi visual, notifikasi, layanan darurat (*panic button*), serta pelaporan eksekutif.

### 1.1 Tujuan Arsitektur
- **Keamanan Berlapis (*Defense in Depth*):** Memastikan pembatasan hak akses berbasis peran (*Role-Based Access Control* / RBAC) ditegakkan baik di sisi antarmuka pengguna maupun pada tingkat basis data melalui *Row Level Security* (RLS).
- **Keandalan Telemetri (*Resilient Telemetry*):** Menjamin pengiriman data lokasi GPS dan deteksi *checkpoint* tetap akurat meskipun perangkat berada di latar belakang (*background*) atau mengalami fluktuasi jaringan.
- **Kemudahan Pemeliharaan (*Maintainability*):** Memisahkan logika antarmuka, logika bisnis, dan layanan data pada aplikasi Flutter menggunakan pendekatan modular tanpa ketergantungan berlebih pada pustaka pihak ketiga.

---

## 2. Gambaran Umum Arsitektur (*High-Level Architecture*)

Secara garis besar, ekosistem SIAGA terbagi menjadi empat lapisan utama:
1. **Lapisan Klien (*Client Layer*):** Aplikasi Android berbasis Flutter yang digunakan oleh personel **PAMDAL**, **PIC PAMDAL**, dan **Pimpinan**.
2. **Lapisan Backend & Persistensi (*BaaS Layer*):** Layanan **Supabase** yang menyediakan autentikasi (Supabase Auth), basis data relasional (PostgreSQL), dan penyimpanan objek berkas (Supabase Storage).
3. **Lapisan Telemetri Waktu Nyata (*Real-Time Messaging Layer*):** Broker **HiveMQ** berbasis protokol **MQTT** untuk pertukaran data koordinat GPS patroli dan peristiwa *checkpoint*.
4. **Lapisan Integrasi Eksternal (*External Services Layer*):** Layanan **Brevo** (SMTP/API) untuk pengiriman kode OTP melalui email, serta integrasi langsung dengan sistem operasi Android untuk fitur lokasi perangkat dan *Panic Button* (panggilan telepon/peta).

```
+-----------------------------------------------------------------------------------+
|                           APLIKASI ANDROID SIAGA (FLUTTER)                        |
|                                                                                   |
|  +-----------------+   +--------------------+   +------------------------------+  |
|  | Modul Antarmuka |   | Pengelola State    |   | Layanan Latar Belakang       |  |
|  | (Role-Based UI) |<->| Bawaan Flutter     |<->| (GPS Sensor, PDF, Intent OS) |  |
|  | - PAMDAL        |   | - setState         |   +--------------+---------------+  |
|  | - PIC PAMDAL    |   | - ValueNotifier    |                  |                  |
|  | - Pimpinan      |   | - ChangeNotifier   |                  |                  |
|  +--------+--------+   +---------+----------+                  |                  |
|           |                      |                             |                  |
|           +----------------------+-----------------------------+                  |
|                                  |                                                |
|                     +------------+-------------+                                  |
|                     | Lapisan Layanan & Data   |                                  |
|                     | (Repositories & Clients) |                                  |
|                     +----+----------------+----+                                  |
+--------------------------|----------------|---------------------------------------+
                           |                |
        HTTPS / REST / WSS |                | MQTT over TLS (Port 8883)
                           v                v
+-------------------------------+      +--------------------------------------------+
|           SUPABASE            |      |               HIVEMQ BROKER                |
|                               |      |                                            |
| +---------------------------+ |      | +----------------------------------------+ |
| | Supabase Auth             | |      | | Topik Telemetri & Checkpoint:          | |
| | (Integrasi Brevo OTP)     |-------+ | | - siaga/v1/patrol/{id}/telemetry      | |
| +---------------------------+ |     |  | - siaga/v1/patrol/{id}/checkpoint     | |
| | PostgreSQL Database       | |     |  | - siaga/v1/notifications/{target}     | |
| | (Dilengkapi Kebijakan RLS)|<------+  +----------------------------------------+ |
| +---------------------------+ |Sinkronisasi                                       |
| | Supabase Storage          | |Data Patroli                                       |
| | (Foto Dokumentasi/Bukti)  | |                                                   |
| +---------------------------+ |                                                   |
+-------------------------------+      +--------------------------------------------+
```

---

## 3. Arsitektur Aplikasi Klien (Flutter Android)

Aplikasi dibangun menggunakan **Flutter** dan bahasa **Dart** dengan pendekatan **Modular Layered Architecture**. Sesuai spesifikasi, pengelolaan *state* mengandalkan mekanisme bawaan Flutter agar arsitektur tetap ringan dan mudah dipelihara.

### 3.1 Pembagian Lapisan Internal Aplikasi
1. **Presentation Layer (UI & State):**
   - Mengelola tampilan halaman (*Screens*), komponen antarmuka (*Widgets*), grafik (`syncfusion_flutter_charts`), dan pemilih tanggal/waktu.
   - Menggunakan `StatefulWidget` (`setState`) untuk *state* lokal yang bersifat sementara (seperti input form dan status pemuatan halaman).
   - Menggunakan `ChangeNotifier`, `ValueNotifier`, dan `InheritedWidget` (bawaan Flutter SDK) untuk *state* lintas halaman seperti sesi pengguna aktif, daftar permission RBAC, dan status patroli yang sedang berjalan.
2. **Domain / Business Logic Layer:**
   - **RBAC Guard:** Mengevaluasi daftar permission pengguna (contoh: `schedule.create`, `report.export`) sebelum merender elemen UI atau mengeksekusi aksi.
   - **Geofence & Checkpoint Evaluator:** Menghitung jarak antara koordinat GPS perangkat saat ini dengan titik koordinat *checkpoint* untuk mendeteksi apakah personel telah melewati titik pantau.
   - **PDF Generator Engine:** Menyusun dokumen laporan menggunakan paket `syncfusion_flutter_pdf`.
3. **Data & Infrastructure Layer:**
   - **Supabase Client Service:** Menangani operasi autentikasi, kueri basis data PostgreSQL, dan pengunggahan berkas ke Supabase Storage.
   - **MQTT Telemetry Service:** Mengelola koneksi *socket* TLS ke broker HiveMQ, mekanisme *auto-reconnect*, publikasi koordinat GPS, serta antrean pesan luring (*offline buffer*).
   - **Device Location Service:** Mengakses sensor GPS perangkat Android dan menjalankan *Foreground Service* selama sesi patroli aktif.

### 3.2 Struktur Direktori Proyek (`lib/`)
```text
lib/
├── main.dart
├── core/
│   ├── config/              # Konfigurasi environment (Supabase URL, HiveMQ host)
│   ├── constants/           # Daftar konstanta permission, kontak darurat, warna
│   ├── rbac/                # Helper & guard validasi role dan permission
│   ├── services/            # Layanan global (LocationService, MqttService, PdfService)
│   └── utils/               # Kalkulator jarak GPS (Haversine), pemformat tanggal
├── models/                  # Model data (User, Attendance, Schedule, Patrol, Incident)
└── features/
    ├── auth/                # Login username/password, registrasi, input OTP email (Brevo), lupa password, layar menunggu persetujuan, manajemen sesi
    ├── registration/        # Antrean pendaftaran & persetujuan (khusus PIC PAMDAL)
    ├── dashboard/           # Ringkasan operasional & grafik Syncfusion
    ├── attendance/          # Buat absensi (PAMDAL) & kelola absensi (PIC/Pimpinan)
    ├── schedule/            # CRUD jadwal jaga & komponen date-time picker
    ├── patrol/              # Start/Stop patroli, pemantauan GPS, deteksi checkpoint
    ├── incident/            # Form laporan kejadian & pembaruan status penanganan
    ├── documentation/       # Unggah foto bukti ke Supabase Storage & galeri bukti
    ├── notification/        # Daftar notifikasi & pengelolaan pengumuman operasional
    ├── personnel/           # CRUD data personel PAMDAL (khusus PIC & Pimpinan)
    ├── report/              # Filter laporan & ekspor PDF (syncfusion_flutter_pdf)
    └── panic_button/        # Akses cepat RS JMC, Polsek Pancoran, Damkar Kalibata
```

---

## 4. Arsitektur Backend dan Basis Data (Supabase)

### 4.1 Autentikasi, Registrasi, dan Pengiriman OTP (Supabase Auth + Brevo)

**Registrasi anggota baru**
1. Pendaftar mengisi nama lengkap, username, password, email, nomor HP, dan role yang diminta (`pamdal` / `pimpinan`).
2. Aplikasi memanggil `signUp` pada **Supabase Auth** dengan konfirmasi email aktif; metadata (`username`, `full_name`, `phone`, `requested_role`) disimpan di `raw_user_meta_data`.
3. Supabase Auth mengirim email OTP melalui **Custom SMTP / API Brevo**.
4. Pendaftar memasukkan OTP 6 digit; aplikasi memanggil `verifyOTP` (tipe `signup`). Masa berlaku 5 menit, maks. 5 percobaan salah, jeda kirim ulang 60 detik.
5. *Trigger* database membuat baris `personnel` dengan `status = 'pending'`, `role_id = NULL`, dan `requested_role_id` sesuai pilihan. Klien **tidak** dapat mengisi `role_id`/`status`.
6. PIC PAMDAL menyetujui/menolak melalui fungsi RPC (`approve_registration`, `reject_registration`) yang memeriksa permission `registration.approve`, mengisi `role_id`, `status`, `approved_by`, `approved_at`, mencatat `audit_logs`, dan membuat `notifications` bagi pendaftar.
7. PIC PAMDAL berperan sebagai admin sistem. Akun PIC PAMDAL pertama dibuat manual (seed) melalui dasbor/SQL Supabase.
8. Nomor HP hanya disimpan sebagai data kontak (tanpa verifikasi SMS). Password bebas; tidak ada validasi kompleksitas di aplikasi.

**Login**
1. Pengguna memasukkan username dan password.
2. Aplikasi memanggil fungsi RPC `get_login_email(username)` (`SECURITY DEFINER`, dapat dipanggil anon, hanya mengembalikan email untuk username berstatus `active`; respons dibuat tidak membedakan username tak dikenal dan password salah di sisi UI).
3. Aplikasi memanggil `signInWithPassword(email, password)`.
4. Aplikasi memuat `personnel`; jika `status != 'active'` sesi diakhiri dan layar "Menunggu Persetujuan" / "Akun Tidak Aktif" ditampilkan.
5. Supabase mengembalikan token **JWT (JSON Web Token)** yang berisi `sub` (`user_id`). Role dan permission dibaca dari basis data, bukan dari metadata yang dapat diubah klien.

**Lupa password:** `resetPasswordForEmail` (OTP email via Brevo) → `verifyOTP` (tipe `recovery`) → `updateUser(password)`.

**Catatan keamanan:** aktifkan *rate limit* Supabase Auth untuk percobaan masuk dan pengiriman OTP; RLS pada `personnel` melarang `UPDATE` kolom `role_id`, `status`, `approved_*` oleh pengguna biasa.

### 4.2 Rancangan Skema Basis Data (PostgreSQL)

Berikut adalah rancangan tabel inti pada PostgreSQL Supabase untuk mendukung seluruh modul aplikasi:

| Nama Tabel | Deskripsi | Kolom Utama |
| :--- | :--- | :--- |
| `roles` | Master peran pengguna (`pamdal`, `pic_pamdal`, `pimpinan`). | `id`, `name`, `description` |
| `role_permissions` | Pemetaan permission (contoh: `patrol.create`) ke masing-masing peran. | `id`, `role_id`, `permission_code` |
| `personnel` | Data profil personel yang berelasi $1:1$ dengan `auth.users`. | `id` (UUID, FK `auth.users`), `nip_id`, `username` (unik), `full_name`, `email`, `phone` (unik), `requested_role_id`, `role_id` (NULL sampai disetujui), `status` (`pending`, `active`, `rejected`, `inactive`), `rejection_reason`, `approved_by`, `approved_at`, `created_at` |
| `schedules` | Jadwal jaga personel yang dikelola oleh PIC PAMDAL. | `id`, `personnel_id`, `shift_name`, `start_time`, `end_time`, `location_area`, `created_by` |
| `attendances` | Catatan kehadiran personel PAMDAL. | `id`, `personnel_id`, `schedule_id`, `check_in_time`, `check_out_time`, `latitude`, `longitude`, `status`, `notes` |
| `checkpoints` | Titik lokasi pemeriksaan patroli yang ditentukan di lingkungan BPSDM. | `id`, `name`, `sequence_order`, `latitude`, `longitude`, `radius_meters`, `is_active` |
| `patrol_sessions` | Catatan sesi pelaksanaan patroli oleh personel PAMDAL. | `id`, `personnel_id`, `schedule_id`, `start_time`, `end_time`, `status` (`active`, `completed`, `interrupted`) |
| `patrol_checkpoint_logs` | Bukti waktu dan koordinat saat personel melewati *checkpoint*. | `id`, `patrol_session_id`, `checkpoint_id`, `reached_at`, `latitude`, `longitude`, `accuracy_meters` |
| `patrol_telemetry_logs` | Riwayat jejak koordinat GPS selama sesi patroli berlangsung. | `id`, `patrol_session_id`, `recorded_at`, `latitude`, `longitude`, `speed`, `battery_level` |
| `incidents` | Laporan kejadian keamanan di lapangan. | `id`, `reporter_id`, `incident_time`, `category`, `title`, `description`, `latitude`, `longitude`, `status` (`open`, `in_progress`, `resolved`), `updated_by` |
| `documentations` | Metadata foto bukti yang mengacu pada objek di Supabase Storage. | `id`, `incident_id`, `uploaded_by`, `storage_path`, `file_type`, `file_size_bytes`, `caption`, `created_at` |
| `notifications` | Pesan pemberitahuan sistem (*checkpoint* terlewati, insiden baru, jadwal). | `id`, `recipient_id`, `target_role`, `title`, `body`, `type`, `is_read`, `created_at` |
| `audit_logs` | Pencatatan jejak audit untuk perubahan data krusial. | `id`, `actor_id`, `action`, `entity_name`, `entity_id`, `payload_diff`, `created_at` |

### 4.3 Arsitektur Penyimpanan Berkas (Supabase Storage)
- **Bucket `incident-documentations`:** Menyimpan unggahan foto bukti kejadian atau dokumentasi patroli.
- **Aturan Validasi Berkas:**
  - Tipe MIME yang diizinkan: `image/jpeg`, `image/png`, `image/webp`.
  - Batas ukuran berkas: Maksimal $5\text{ MB}$ per berkas (dikompresi di sisi aplikasi Flutter sebelum diunggah untuk menghemat kuota data personel).
  - Penamaan jalur objek (*Path Convention*): `{tahun}/{bulan}/{incident_id}/{uuid_file}.jpg`.

---

## 5. Arsitektur Telemetri GPS dan Integrasi MQTT (HiveMQ)

Modul patroli membutuhkan pengumpulan titik koordinat secara berkelanjutan dan pengiriman pesan berlatensi rendah.

### 5.1 Akuisisi GPS dan Penanganan Latar Belakang Android
1. Ketika personel PAMDAL menekan tombol **Start Patroli**, aplikasi meminta izin `ACCESS_FINE_LOCATION` dan menjalankan **Android Foreground Service** (menampilkan notifikasi persisten bahwa patroli sedang berjalan).
2. *Foreground Service* mencegah sistem operasi Android menghentikan pembacaan sensor GPS ketika layar ponsel dimatikan atau aplikasi diminimalkan.
3. Sensor GPS mengambil sampel koordinat berdasarkan interval waktu (misal: setiap $\Delta t = 15\text{ detik}$) atau perpindahan jarak minimum ($\Delta d \ge 10\text{ meter}$).

### 5.2 Mekanisme Deteksi Checkpoint (*Geofencing*)
Deteksi *checkpoint* dilakukan langsung di perangkat (*edge evaluation*) dan divalidasi saat sinkronisasi ke backend:
1. Saat sesi patroli dimulai, aplikasi memuat daftar koordinat *checkpoint* aktif $(\phi_c, \lambda_c)$ beserta radius toleransinya $R_c$ (dalam meter) dari Supabase.
2. Setiap kali sensor GPS menghasilkan koordinat baru $(\phi_u, \lambda_u)$ dengan akurasi sensor $a_u$, aplikasi menghitung jarak permukaan bumi $d$ menggunakan rumus **Haversine**:
   $$a = \sin^2\left(\frac{\Delta \phi}{2}\right) + \cos(\phi_u) \cdot \cos(\phi_c) \cdot \sin^2\left(\frac{\Delta \lambda}{2}\right)$$
   $$c = 2 \cdot \text{atan2}\left(\sqrt{a}, \sqrt{1 - a}\right)$$
   $$d = R_{\text{bumi}} \cdot c$$
   dengan $R_{\text{bumi}} \approx 6.371.000\text{ meter}$, $\Delta \phi = \phi_c - \phi_u$, dan $\Delta \lambda = \lambda_c - \lambda_u$.
3. Suatu *checkpoint* dinyatakan **terlewati** apabila memenuhi kondisi:
   $$d \le R_c + \min(a_u, \tau_{\text{maks}})$$
   di mana $\tau_{\text{maks}}$ adalah batas toleransi ketidakpastian GPS maksimum yang diizinkan (misalnya $15\text{ meter}$).
4. Ketika kondisi terpenuhi, aplikasi memicu notifikasi lokal pada perangkat PAMDAL, mempublikasikan peristiwa ke topik MQTT, dan menyimpan catatan ke tabel `patrol_checkpoint_logs`.

### 5.3 Struktur Topik dan Payload MQTT (HiveMQ)
Koneksi ke broker **HiveMQ** wajib menggunakan jalur terenkripsi **MQTT over TLS (Port 8883)**.

| Topik MQTT | Pengirim (Publisher) | Penerima (Subscriber) | QoS | Kegunaan |
| :--- | :--- | :--- | :---: | :--- |
| `siaga/v1/patrol/{session_id}/telemetry` | Aplikasi (PAMDAL) | Dashboard Pemantauan / Worker | $0$ atau $1$ | Mengirim pembaruan koordinat GPS secara berkala selama patroli aktif. |
| `siaga/v1/patrol/{session_id}/checkpoint` | Aplikasi (PAMDAL) | Layanan Backend / PIC PAMDAL | $1$ | Mengirim peristiwa ketika sebuah titik *checkpoint* berhasil dilewati. |
| `siaga/v1/alerts/incident` | Aplikasi (PAMDAL) | Aplikasi (PIC PAMDAL & Pimpinan) | $1$ | Memberi tahu laporan kejadian baru secara waktu nyata. |

**Contoh Payload JSON (`siaga/v1/patrol/{session_id}/checkpoint`):**
```json
{
  "message_id": "msg-98234-ab12",
  "patrol_session_id": "550e8400-e29b-41d4-a716-446655440000",
  "personnel_id": "a1b2c3d4-e5f6-7890-1234-567890abcdef",
  "checkpoint_id": "chk-pos-utama-01",
  "timestamp_utc": "2026-10-21T01:15:30Z",
  "location": {
    "latitude": -6.254123,
    "longitude": 106.851234,
    "accuracy_meters": 6.4
  },
  "device_state": {
    "battery_percentage": 78,
    "is_mock_location": false
  }
}
```

### 5.4 Penanganan Kondisi Tanpa Jaringan (*Offline Resilience*)
- Apabila koneksi internet terputus saat personel berada di area *blank spot*, data titik GPS dan peristiwa *checkpoint* disimpan sementara pada penyimpanan lokal perangkat (*local queue*).
- Setiap pesan dilengkapi `message_id` unik dan `timestamp_utc` asli saat kejadian berlangsung.
- Ketika koneksi pulih, aplikasi mengirim ulang antrean data ke broker MQTT dan melakukan sinkronisasi *batch* (`upsert` berdasarkan `message_id`) ke Supabase untuk mencegah duplikasi data.

---

## 6. Arsitektur Keamanan dan Hak Akses (RBAC & RLS)

Keamanan sistem SIAGA menerapkan prinsip **Least Privilege**. Penegakan hak akses tidak hanya dilakukan dengan menyembunyikan tombol pada antarmuka Flutter, melainkan divalidasi secara ketat di sisi database PostgreSQL melalui **Row Level Security (RLS)**.

### 6.1 Matriks Penegakan Akses di Tingkat Database (RLS Supabase)

| Modul / Tabel | Kebijakan untuk Role `PAMDAL` | Kebijakan untuk Role `PIC PAMDAL` | Kebijakan untuk Role `Pimpinan` |
| :--- | :--- | :--- | :--- |
| **`attendances`** | `INSERT` untuk diri sendiri; `SELECT` hanya baris dengan `personnel_id = auth.uid()`. | `SELECT`, `INSERT`, `UPDATE`, `DELETE` seluruh data absensi. | `SELECT` seluruh data absensi. |
| **`schedules`** | `SELECT` seluruh jadwal jaga. | `SELECT`, `INSERT`, `UPDATE`, `DELETE` seluruh jadwal jaga. | `SELECT` seluruh jadwal jaga. |
| **`patrol_sessions` & `logs`** | `INSERT` sesi milik sendiri; `SELECT` catatan patroli milik sendiri (`personnel_id = auth.uid()`). | `SELECT`, `UPDATE`, `DELETE` seluruh catatan patroli. | `SELECT` seluruh catatan patroli. |
| **`incidents`** | `INSERT` laporan baru; `SELECT` laporan milik sendiri (`reporter_id = auth.uid()`). | `SELECT`, `UPDATE`, `DELETE` seluruh laporan kejadian. | `SELECT` seluruh laporan kejadian. |
| **`documentations`** | `INSERT` dokumentasi baru; `SELECT` terkait laporan milik sendiri. | `SELECT`, `UPDATE`, `DELETE` seluruh dokumentasi. | `SELECT` seluruh dokumentasi. |
| **`personnel`** | Hanya `SELECT` profil milik sendiri (`id = auth.uid()`). | `SELECT`, `INSERT`, `UPDATE`, `DELETE` data personel. | `SELECT` seluruh data personel. |
| **`notifications`** | `SELECT` dan `UPDATE` (status `is_read`) untuk notifikasi yang ditujukan kepadanya. | `SELECT`, `INSERT`, `UPDATE`, `DELETE` seluruh notifikasi. | `SELECT` dan `UPDATE` (status `is_read`) untuk notifikasi miliknya. |

### 6.2 Perlindungan Kredensial & Anti-Manipulasi
- **Kunci API:** Aplikasi Android hanya dibekali `SUPABASE_ANON_KEY` yang aman untuk publik karena seluruh tabel telah dilindungi oleh RLS. Kunci `SUPABASE_SERVICE_ROLE_KEY` dan kredensial API Brevo **dilarang keras** disimpan di dalam kode sumber aplikasi Android.
- **Injeksi Konfigurasi:** Parameter lingkungan dimasukkan saat kompilasi menggunakan `--dart-define` (bukan berkas teks terbuka di dalam aset APK).
- **Validasi Lokasi Palsu (*Mock Location Detection*):** Layanan lokasi pada aplikasi memeriksa atribut `isMocked` dari sampel GPS Android untuk mencegah manipulasi posisi kehadiran maupun *checkpoint* patroli menggunakan aplikasi *Fake GPS*.

---

## 7. Arsitektur Modul Fungsional Lainnya

### 7.1 Dashboard, Grafik, dan Pembuatan Laporan PDF
1. **Agregasi Data Dashboard:** Untuk menjaga performa aplikasi tetap cepat, perhitungan statistik (seperti persentase kehadiran bulanan, jumlah patroli selesai, dan tren kejadian per kategori) dilakukan melalui **PostgreSQL Views / RPC Functions** di Supabase.
2. **Visualisasi Grafik:** Hasil agregasi JSON dirender di aplikasi menggunakan komponen `syncfusion_flutter_charts` (grafik batang untuk kehadiran, grafik garis untuk aktivitas patroli, dan diagram lingkaran untuk kategori insiden).
3. **Pembuatan & Ekspor PDF:**
   - Pengguna dengan permission `report.generate` dan `report.export` (**PIC PAMDAL** dan **Pimpinan**) memilih rentang tanggal dan jenis laporan menggunakan *date-time picker*.
   - Aplikasi mengambil data terfilter dari Supabase dan menyusun dokumen tabel beserta kop surat BPSDM Kemendagri secara lokal menggunakan pustaka `syncfusion_flutter_pdf`.
   - Berkas PDF disimpan ke penyimpanan perangkat untuk dicetak atau dibagikan.

### 7.2 Arsitektur Fitur Panic Button
Fitur **Panic Button** (`panicbutton.use`) tersedia bagi seluruh peran dan dirancang agar tetap dapat diakses secara instan bahkan ketika koneksi ke server Supabase sedang lambat:
- Data kontak darurat untuk ketiga instansi disimpan sebagai **konstanta lokal yang disinkronkan** di dalam aplikasi:
  1. **RS JMC (Jakarta Medical Center)**
  2. **Polsek Pancoran**
  3. **Damkar Kalibata**
- Ketika pengguna memilih salah satu layanan darurat, aplikasi menampilkan dialog konfirmasi cepat yang menyediakan dua aksi berbasis **Android Explicit/Implicit Intent**:
  - **Panggilan Langsung:** Membuka *dialer* telepon dengan skema URI `tel:{nomor_darurat}`.
  - **Navigasi Peta:** Membuka aplikasi peta dengan skema URI `geo:{lat},{lng}?q={nama_instansi}`.
- Apabila perangkat terhubung ke internet, penekanan tombol darurat juga mengirim catatan log ke Supabase/MQTT agar **PIC PAMDAL** mengetahui adanya personel yang menekan tombol darurat.

---

## 8. Daftar Keputusan & Tindak Lanjut Pra-Implementasi (Checklist Teknis)

Sebelum memasuki tahap penulisan kode (*coding*), tim pengembang dan pemangku kepentingan di BPSDM Kemendagri perlu mengonfirmasi parameter operasional berikut:

1. **Daftar Koordinat & Radius Checkpoint:** Penetapan titik koordinat $(\phi_c, \lambda_c)$, radius $R_c$ (misal $15\text{ m}$ – $25\text{ m}$), serta aturan apakah *checkpoint* wajib dilewati secara berurutan atau bebas.
2. **Konfigurasi Broker HiveMQ:** Penentuan apakah menggunakan *HiveMQ Cloud* (Serverless/Cluster) atau *self-hosted*, serta mekanisme autentikasi klien MQTT (Username/Password per perangkat atau token).
3. **Verifikasi Nomor & Koordinat Panic Button:** Konfirmasi nomor telepon darurat resmi yang aktif $24\text{ jam}$ untuk RS JMC, Polsek Pancoran, dan Pos Damkar Kalibata.
4. **Standar Layout Laporan PDF:** Penetapan format kop surat resmi BPSDM Kemendagri, kolom tabel yang wajib dicantumkan, serta blok tanda tangan pejabat terkait.
5. **Pengujian Pembatasan Baterai Android (*OEM Battery Optimization*):** Pengujian perilaku *Foreground Service* pada berbagai merek perangkat Android personel untuk memastikan telemetri GPS tidak dihentikan secara paksa oleh penghemat baterai bawaan pabrikan.