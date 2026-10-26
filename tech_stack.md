# SIAGA --- Sistem Informasi Garda Pengamanan Dalam

## 1. Ringkasan Aplikasi

**SIAGA (Sistem Informasi Garda Pengamanan Dalam)** adalah aplikasi
Android untuk mendukung monitoring kegiatan Pengamanan Dalam (PAMDAL) di
lingkungan **BPSDM Kementerian Dalam Negeri**. Aplikasi ini digunakan
untuk mengelola kehadiran, jadwal jaga, patroli berbasis GPS, pelaporan
kejadian, dokumentasi, notifikasi, serta akses cepat ke layanan darurat.

Aplikasi direncanakan dibangun menggunakan **Flutter** dengan bahasa
pemrograman **Dart**. Hak akses dibagi menjadi tiga role: **PAMDAL**,
**PIC PAMDAL**, dan **Pimpinan**.

## 2. Tujuan

-   Mempermudah pemantauan aktivitas dan kehadiran personel PAMDAL.
-   Mendukung pengelolaan jadwal jaga secara terpusat.
-   Merekam aktivitas patroli dan checkpoint menggunakan telemetri GPS.
-   Memfasilitasi pelaporan kejadian beserta bukti dokumentasi.
-   Menyampaikan notifikasi yang relevan kepada pengguna.
-   Menyediakan laporan untuk kebutuhan monitoring dan pengambilan
    keputusan pimpinan.
-   Memberikan akses cepat ke pilihan layanan darurat melalui fitur
    panic button.

## 3. Role dan Hak Akses

Hak akses menggunakan pola **role-based access control (RBAC)**. Daftar
permission di bawah merupakan rancangan awal dan perlu ditegakkan di
sisi aplikasi serta backend/database.

### 3.1 PAMDAL

  Permission               Keterangan
  ------------------------ -----------------------------------------
  `attendance.create`      Membuat catatan absensi kehadiran.
  `attendance.read.own`    Melihat catatan absensi milik sendiri.
  `schedule.read`          Melihat jadwal jaga.
  `patrol.create`          Memulai atau membuat catatan patroli.
  `patrol.read.own`        Melihat catatan patroli milik sendiri.
  `incident.create`        Membuat laporan kejadian.
  `incident.read.own`      Melihat laporan kejadian milik sendiri.
  `documentation.create`   Mengunggah dokumentasi atau bukti foto.
  `notification.read`      Membaca notifikasi.
  `panicbutton.use`        Mengakses pilihan layanan darurat.

### 3.2 PIC PAMDAL

  Permission               Keterangan
  ------------------------ ------------------------------------
  `attendance.read`        Melihat data absensi.
  `attendance.manage`      Mengelola data absensi.
  `schedule.create`        Membuat jadwal jaga.
  `schedule.read`          Melihat jadwal jaga.
  `schedule.update`        Memperbarui jadwal jaga.
  `schedule.delete`        Menghapus jadwal jaga.
  `patrol.read`            Melihat data patroli.
  `patrol.manage`          Mengelola data patroli.
  `incident.read`          Melihat laporan kejadian.
  `incident.update`        Memperbarui laporan kejadian.
  `incident.manage`        Mengelola laporan kejadian.
  `documentation.read`     Melihat dokumentasi.
  `documentation.manage`   Mengelola dokumentasi.
  `personnel.create`       Menambahkan data personel.
  `personnel.read`         Melihat data personel.
  `personnel.update`       Memperbarui data personel.
  `personnel.delete`       Menghapus data personel.
  `registration.read`      Melihat antrean pendaftaran anggota baru.
  `registration.approve`   Menyetujui atau menolak pendaftaran.
  `report.generate`        Membuat laporan.
  `report.export`          Mengekspor laporan.
  `notification.manage`    Mengelola notifikasi.
  `panicbutton.use`        Mengakses pilihan layanan darurat.

### 3.3 Pimpinan

  Permission             Keterangan
  ---------------------- ------------------------------------
  `attendance.read`      Melihat data absensi.
  `schedule.read`        Melihat jadwal jaga.
  `patrol.read`          Melihat data patroli.
  `incident.read`        Melihat laporan kejadian.
  `documentation.read`   Melihat dokumentasi.
  `personnel.read`       Melihat data personel.
  `report.generate`      Membuat laporan.
  `report.export`        Mengekspor laporan.
  `notification.read`    Membaca notifikasi.
  `panicbutton.use`      Mengakses pilihan layanan darurat.

## 4. Modul dan Fitur Utama

### 4.1 Autentikasi dan Registrasi

**Login**

-   Pengguna masuk dengan **username dan password** melalui Supabase
    Auth. Username diterjemahkan ke email lewat fungsi backend (RPC /
    Edge Function) agar tabel profil tidak terbaca publik, lalu
    dilanjutkan dengan `signInWithPassword`.
-   Pesan gagal login bersifat generik ("Username atau password
    salah") dan percobaan gagal dibatasi.
-   Hanya akun berstatus `active` yang dapat masuk. Akun `pending`,
    `rejected`, atau `inactive` ditolak.
-   Lupa password: kode OTP dikirim ke email, lalu pengguna menetapkan
    password baru.

**Registrasi anggota baru**

1.  Pendaftar mengisi: nama lengkap, username, password, email, nomor
    handphone, dan **role yang diminta** (`PAMDAL` atau `Pimpinan`).
    Role `PIC PAMDAL` tidak tersedia pada pendaftaran.
2.  Sistem memvalidasi keunikan username, email, dan nomor HP (format
    Indonesia dinormalisasi ke `+62...`).
3.  Kode OTP 6 digit dikirim ke **email** pendaftar melalui Brevo
    (masa berlaku 5 menit, maksimal 5 percobaan salah, jeda kirim ulang
    60 detik).
4.  Setelah OTP benar, akun dibuat dengan status `pending`. Role yang
    dipilih hanya disimpan sebagai **permintaan** (`requested_role`).
5.  **PIC PAMDAL** meninjau antrean pendaftaran, lalu menyetujui (role
    dapat dikoreksi) atau menolak disertai alasan. Pendaftar menerima
    notifikasi hasilnya.
6.  Akun PIC PAMDAL dibuat manual (seed di Supabase), bukan lewat
    pendaftaran.

**Prinsip**

-   Role dan permission pengguna menentukan fitur yang dapat diakses.
-   Role/status tidak boleh dipercaya dari aplikasi; hanya dapat diubah
    PIC PAMDAL melalui fungsi backend yang dilindungi RLS.
-   Nomor HP hanya disimpan sebagai data kontak (tidak diverifikasi).
    OTP dikirim via email.
-   Password bebas: aplikasi tidak menerapkan aturan kompleksitas
    (hanya batas minimum teknis bawaan Supabase Auth, dapat diatur di
    dasbor).
-   PIC PAMDAL berperan sebagai **admin sistem**: mengelola pendaftaran,
    personel, jadwal, dan data operasional.
-   Sesi autentikasi harus dikelola dengan aman dan akses data tetap
    divalidasi di backend.

### 4.2 Absensi Kehadiran (`attendance`)

-   PAMDAL dapat membuat catatan kehadiran.
-   PAMDAL hanya dapat melihat catatan absensinya sendiri.
-   PIC PAMDAL dapat melihat dan mengelola data absensi.
-   Pimpinan dapat melihat data absensi untuk kebutuhan monitoring.

### 4.3 Jadwal Jaga (`schedule`)

-   PIC PAMDAL dapat membuat, melihat, memperbarui, dan menghapus jadwal
    jaga.
-   PAMDAL dan Pimpinan dapat melihat jadwal jaga.
-   Pemilihan tanggal dan waktu menggunakan komponen date-time picker.
-   Data jadwal disimpan dan disinkronkan dengan database.

### 4.4 Patroli dan Telemetri GPS (`patrol`)

Alur patroli yang direncanakan:

1.  PAMDAL membuka fitur patroli dan menekan tombol **Start Patroli**.
2.  Aplikasi meminta izin lokasi yang diperlukan dan memulai pengambilan
    data GPS sesuai izin pengguna.
3.  Sistem mencatat sesi patroli dan memantau lokasi selama patroli
    aktif.
4.  Ketika PAMDAL melewati checkpoint yang telah ditentukan, sistem
    mendeteksi checkpoint tersebut.
5.  Aplikasi menampilkan notifikasi bahwa checkpoint telah dilewati.
6.  Data patroli dan checkpoint dikirim atau disinkronkan ke sistem.
7.  Laporan patroli tersedia bagi semua role sesuai permission
    masing-masing.

**Catatan implementasi:** telemetry GPS memerlukan penanganan izin
lokasi, pembatasan background execution Android, konsumsi baterai,
kehilangan koneksi, serta validasi data lokasi. Perilaku saat aplikasi
berada di latar belakang perlu diuji pada perangkat Android yang
ditargetkan. MQTT digunakan untuk pertukaran pesan telemetri sesuai
rancangan integrasi HiveMQ; detail broker, topik, autentikasi, dan
format payload perlu ditetapkan saat implementasi.

### 4.5 Pelaporan Kejadian (`incident`)

-   PAMDAL dapat membuat laporan kejadian dan melihat laporan miliknya.
-   PIC PAMDAL dapat melihat, memperbarui, dan mengelola laporan
    kejadian.
-   Pimpinan dapat melihat laporan kejadian.
-   Laporan sebaiknya memiliki identitas pelapor, waktu kejadian, lokasi
    bila tersedia, kategori, deskripsi, status penanganan, dan referensi
    dokumentasi.

### 4.6 Dokumentasi (`documentation`)

-   PAMDAL dapat menambahkan dokumentasi, termasuk bukti foto yang
    berkaitan dengan laporan kejadian.
-   PIC PAMDAL dapat melihat dan mengelola dokumentasi.
-   Pimpinan dapat melihat dokumentasi.
-   File foto disimpan pada layanan penyimpanan yang ditentukan dan
    metadata atau referensinya dicatat di database.
-   Akses file harus mengikuti otorisasi pengguna dan kebijakan retensi
    data.

### 4.7 Notifikasi (`notification`)

-   PAMDAL dan Pimpinan dapat membaca notifikasi.
-   PIC PAMDAL dapat mengelola notifikasi.
-   Notifikasi digunakan, antara lain, untuk pemberitahuan checkpoint
    yang terlewati serta informasi operasional lainnya.
-   Aturan penerima, prioritas, status telah dibaca, dan kanal
    pengiriman perlu didefinisikan lebih lanjut.

### 4.8 Panic Button (`panicbutton`)

Fitur panic button menampilkan tiga pilihan layanan darurat:

1.  **RS JMC**
2.  **Polsek Pancoran**
3.  **Damkar Kalibata**

Fitur ini dapat mengarahkan pengguna ke informasi atau tindakan kontak
yang sesuai. Alamat, nomor telepon, tautan peta, dan mekanisme panggilan
perlu diverifikasi sebelum digunakan. Panic button bukan pengganti
layanan darurat resmi.

### 4.9 Dashboard, Grafik, dan Laporan

-   Dashboard menyajikan ringkasan data operasional sesuai role.
-   Grafik direncanakan menggunakan Syncfusion Flutter Charts.
-   Laporan dapat dibuat dan diekspor sesuai permission
    `report.generate` dan `report.export`.
-   Pembuatan dokumen PDF direncanakan menggunakan
    `syncfusion_flutter_pdf`.
-   Format laporan, filter tanggal, kolom yang ditampilkan, dan
    kebutuhan tanda tangan perlu ditentukan berdasarkan kebutuhan
    operasional BPSDM.

### 4.10 Data Personel

-   PIC PAMDAL dapat menambahkan, melihat, memperbarui, dan menghapus
    data personel.
-   Pimpinan dapat melihat data personel.
-   PAMDAL tidak memiliki permission pengelolaan data personel dalam
    daftar awal.

## 5. Teknologi yang Direncanakan

  --------------------------------------------------------------------------
  Area                    Teknologi / Paket          Rencana Penggunaan
  ----------------------- -------------------------- -----------------------
  Platform aplikasi       Android                    Platform target
                                                     aplikasi SIAGA.

  Framework               Flutter                    Membangun antarmuka dan
                                                     aplikasi lintas
                                                     perangkat.

  Bahasa                  Dart                       Bahasa pemrograman
                                                     aplikasi.

  Autentikasi             Supabase Auth              Pengelolaan autentikasi
                                                     dan sesi pengguna.

  OTP email               Brevo                      Pengiriman kode OTP
                                                     melalui email;
                                                     integrasi perlu
                                                     divalidasi.

  Database                Supabase (PostgreSQL)      Menyimpan data
                                                     operasional
                                                     terstruktur.

  Penyimpanan berkas      Supabase Storage           Menyimpan foto
                          (direncanakan)             dokumentasi dan berkas
                                                     terkait.

  State management        Bawaan Flutter (`setState` Mengelola state
                          dan mekanisme bawaan yang  antarmuka tanpa library
                          sesuai)                    state management
                                                     tambahan.

  Grafik                  Syncfusion Flutter Charts  Menampilkan grafik pada
                                                     dashboard atau laporan.

  Telemetri               HiveMQ + MQTT              Pertukaran pesan
                                                     telemetri; arsitektur
                                                     broker dan sumber data
                                                     GPS perlu ditetapkan.

  Pembuatan PDF           `syncfusion_flutter_pdf`   Membuat dokumen laporan
                                                     PDF.

  Pemilihan tanggal/waktu Paket date-time picker     Memilih tanggal dan
                                                     waktu untuk jadwal atau
                                                     filter laporan.

  Sinkronisasi            Supabase/database          Menyimpan dan
                                                     menyinkronkan data
                                                     aplikasi.
  --------------------------------------------------------------------------

> **Penting:** HiveMQ merupakan teknologi broker/layanan MQTT, bukan
> sensor GPS itu sendiri. Aplikasi Android tetap memerlukan akses lokasi
> perangkat untuk mendapatkan koordinat GPS. MQTT dapat digunakan untuk
> mengirim data lokasi atau peristiwa telemetri melalui broker yang
> telah dikonfigurasi.

## 6. Gambaran Alur Data

1.  Pengguna login dengan username dan password (anggota baru
    mendaftar, verifikasi OTP email, lalu menunggu persetujuan PIC
    PAMDAL).
2.  Sistem memuat role pengguna dan menerapkan pembatasan akses.
3.  Pengguna mengakses modul sesuai permission.
4.  Data operasional disimpan atau dibaca melalui Supabase.
5.  Saat patroli aktif, aplikasi memperoleh lokasi perangkat berdasarkan
    izin dan mengirim data telemetri sesuai rancangan integrasi.
6.  Sistem mendeteksi checkpoint yang terlewati dan membuat
    peristiwa/notifikasi.
7.  Data patroli dapat dilihat oleh PAMDAL, PIC PAMDAL, dan Pimpinan
    sesuai permission yang berlaku.
8.  PIC PAMDAL atau Pimpinan membuat dan mengekspor laporan sesuai
    permission masing-masing.

## 7. Prinsip Keamanan dan Keandalan

-   Terapkan prinsip **least privilege**: setiap role hanya memperoleh
    akses yang diperlukan.
-   Jangan hanya menyembunyikan tombol di antarmuka; validasi permission
    harus diterapkan pada lapisan backend/database, termasuk kebijakan
    Row Level Security (RLS) Supabase.
-   Lindungi kredensial, kunci API, dan rahasia layanan. Jangan
    menanamkan secret berhak istimewa ke dalam aplikasi Android.
-   Pastikan pengiriman OTP melalui integrasi yang aman dan memiliki
    batas percobaan serta masa berlaku.
-   Password di-hash oleh Supabase Auth; jangan menyimpan atau mencatat
    password di aplikasi. Karena password bebas, batasi percobaan login
    gagal sebagai kompensasi.
-   Minta izin lokasi secara jelas, jelaskan tujuan pengumpulan lokasi,
    dan batasi pengumpulan hanya saat diperlukan untuk patroli.
-   Tangani koneksi terputus, pesan MQTT duplikat, data terlambat, dan
    sinkronisasi ulang.
-   Catat waktu, identitas pengguna, dan perubahan penting untuk
    kebutuhan audit.
-   Validasi tipe, ukuran, dan akses file dokumentasi.
-   Uji skenario izin ditolak, GPS tidak tersedia, baterai rendah,
    aplikasi masuk latar belakang, serta jaringan terputus.

## 8. Hal yang Perlu Ditetapkan Sebelum Implementasi

1.  **Sumber koordinat GPS:** apakah aplikasi membaca GPS perangkat
    secara langsung atau menerima data dari perangkat pelacak lain.
2.  **Arsitektur MQTT:** broker, topik, format payload, autentikasi,
    TLS, aturan publikasi/langganan, dan pemetaan perangkat ke personel.
3.  **Deteksi checkpoint:** koordinat setiap checkpoint, radius
    geofence, toleransi GPS, urutan checkpoint, dan aturan jika
    checkpoint terlewati di luar urutan.
4.  **Penerima laporan patroli:** konfirmasi bahwa laporan tersedia
    untuk ketiga role, termasuk apakah PAMDAL lain boleh melihat patroli
    milik rekan.
5.  **Notifikasi:** apakah notifikasi hanya di dalam aplikasi atau juga
    menggunakan push notification.
6.  **Penyimpanan dokumentasi:** batas ukuran file, format gambar,
    retensi, dan kebijakan akses.
7.  **Detail panic button:** alamat resmi, nomor telepon, tautan peta,
    serta tindakan untuk setiap pilihan.
8.  **Format laporan:** jenis laporan, periode, filter, struktur PDF,
    dan kebutuhan ekspor selain PDF.
9.  **Aturan absensi:** metode pencatatan, validasi waktu/lokasi, serta
    penanganan koreksi absensi.
10. **Registrasi dan login:** batas percobaan login gagal dan siapa
    pengganti PIC PAMDAL bila akun PIC tidak tersedia. (Sudah
    diputuskan: OTP via email, nomor HP hanya data kontak, password
    bebas tanpa aturan kompleksitas.)
11. **State management:** tentukan apakah `setState` cukup untuk cakupan
    aplikasi atau apakah kompleksitas aplikasi memerlukan pola
    pengelolaan state yang lebih terstruktur.

## 9. Ringkasan

SIAGA dirancang sebagai aplikasi Android untuk mendukung pengelolaan
operasional PAMDAL di BPSDM Kemendagri. Fitur utamanya meliputi absensi,
jadwal jaga, patroli dengan telemetri GPS dan checkpoint, pelaporan
kejadian, dokumentasi foto, notifikasi, panic button, dashboard,
pengelolaan personel, serta pembuatan laporan. Flutter dan Dart menjadi
fondasi aplikasi, Supabase menjadi layanan autentikasi dan data,
sementara integrasi MQTT/HiveMQ mendukung rancangan pertukaran data
telemetri.

Dokumen ini merupakan **spesifikasi awal** berdasarkan kebutuhan yang
telah dijelaskan dan dapat diperbarui setelah aturan operasional,
arsitektur telemetri, struktur database, serta kebijakan keamanan
dikonfirmasi.
