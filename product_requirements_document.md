# Product Requirements Document (PRD)

## SIAGA — Sistem Informasi Garda Pengamanan Dalam

* **Instansi:** BPSDM Kementerian Dalam Negeri
* **Platform Target:** Android (Flutter / Dart)
* **Versi Dokumen:** $1.0$
* **Status:** Draft Spesifikasi Produk

---

## 1. Ringkasan Eksekutif & Latar Belakang

### 1.1 Latar Belakang Masalah
Kegiatan operasional Pengamanan Dalam (PAMDAL) di lingkungan **BPSDM Kementerian Dalam Negeri** mencakup pengawasan area fisik, pengelolaan jadwal sif, pencatatan kehadiran personel, pelaksanaan patroli rutin di berbagai titik pantau (*checkpoint*), serta penanganan insiden keamanan. Pengelolaan yang masih mengandalkan pencatatan manual atau komunikasi tidak terstruktur berisiko menimbulkan keterlambatan informasi, kesulitan verifikasi kehadiran maupun kepatuhan rute patroli, serta lambatnya kompilasi laporan untuk pimpinan.

### 1.2 Solusi & Visi Produk
**SIAGA (Sistem Informasi Garda Pengamanan Dalam)** adalah aplikasi *mobile* berbasis Android yang mendigitalisasi seluruh alur kerja operasional PAMDAL secara terpusat dan waktu nyata (*real-time*). Melalui integrasi sensor GPS perangkat, protokol telemetri MQTT, dan penyimpanan awan terstruktur, SIAGA memastikan setiap aktivitas pengamanan tercatat secara akurat, transparan, dan mudah dievaluasi oleh **PIC PAMDAL** maupun **Pimpinan**.

### 1.3 Tujuan Produk (*Product Goals*)
1. **Digitalisasi Kehadiran & Penjadwalan:** Menghadirkan satu sumber data terpusat (*single source of truth*) untuk jadwal jaga dan absensi personel PAMDAL.
2. **Akuntabilitas Patroli Lapangan:** Memvalidasi aktivitas patroli personel melalui pelacakan telemetri GPS dan deteksi *checkpoint* otomatis.
3. **Kecepatan Pelaporan & Tanggap Insiden:** Memungkinkan pelaporan kejadian di lapangan lengkap dengan bukti dokumentasi foto serta akses instan ke layanan darurat (*Panic Button*).
4. **Visibilitas Eksekutif:** Menyediakan dashboard grafik interaktif dan fitur ekspor laporan berformat PDF bagi PIC PAMDAL dan Pimpinan untuk mendukung pengambilan keputusan.

---

## 2. Metrik Keberhasilan Produk (*Success Metrics / KPI*)

| Kategori Metrik | Indikator Keberhasilan (KPI) | Target Pengukuran |
| :--- | :--- | :--- |
| **Adopsi Operasional** | Persentase pencatatan kehadiran dan jadwal jaga yang dilakukan melalui aplikasi SIAGA. | $100\%$ personel PAMDAL aktif |
| **Kepatuhan Patroli** | Persentase titik *checkpoint* yang tervalidasi secara otomatis oleh GPS selama sesi patroli. | $\ge 95\%$ sesi patroli terekam utuh |
| **Kecepatan Pelaporan** | Waktu rata-rata yang dibutuhkan personel untuk mengirim laporan kejadian beserta foto bukti. | $\le 3\text{ menit}$ per laporan |
| **Keandalan Sistem** | Tingkat keberhasilan pengiriman pesan telemetri MQTT & sinkronisasi data ke Supabase. | $\ge 99\%$ data tersinkronisasi |
| **Efisiensi Pelaporan** | Waktu pembuatan dan pengunduhan laporan berkala berformat PDF oleh PIC/Pimpinan. | $\le 10\text{ detik}$ per dokumen PDF |

---

## 3. Persona Pengguna & Hak Akses (*Role-Based Access Control*)

Aplikasi SIAGA melayani tiga peran (*role*) pengguna dengan batasan hak akses (*permission*) yang ditegakkan baik pada antarmuka aplikasi maupun basis data backend:

### 3.1 Profil Persona

1. **PAMDAL (Petugas Lapangan)**
   * **Profil:** Personel keamanan yang bertugas menjaga pos, melakukan patroli keliling area BPSDM Kemendagri, dan menangani kejadian langsung di lapangan.
   * **Kebutuhan Utama:** Antarmuka yang praktis untuk melakukan absensi, melihat jadwal jaga, memulai patroli satu tombol (*Start Patroli*), mengunggah laporan kejadian beserta foto bukti, dan mengakses *Panic Button* saat darurat.

2. **PIC PAMDAL (Koordinator / Pengelola Operasional)**
   * **Profil:** Penanggung jawab operasional harian yang mengatur jadwal sif personel, memantau pelaksanaan patroli, menindaklanjuti laporan kejadian, dan mengelola basis data personel.
   * **Kebutuhan Utama:** Kontrol penuh (*CRUD* dan *Manage*) atas jadwal jaga, data personel, absensi, patroli, laporan kejadian, dokumentasi, pengelolaan notifikasi, serta pembuatan laporan PDF.

3. **Pimpinan (Manajemen / Eksekutif BPSDM)**
   * **Profil:** Pejabat atau pimpinan yang mengawasi kinerja pengamanan secara menyeluruh dan membutuhkan laporan periodik untuk evaluasi kebijakan.
   * **Kebutuhan Utama:** Akses baca (*read-only*) ke seluruh data operasional melalui dashboard ringkasan, grafik analitik, serta kemampuan menghasilkan dan mengekspor laporan PDF.

### 3.2 Matriks Permission Berdasarkan Role

| Kode Permission | Deskripsi Hak Akses | PAMDAL | PIC PAMDAL | Pimpinan |
| :--- | :--- | :---: | :---: | :---: |
| `attendance.create` | Membuat catatan absensi kehadiran. | Ya | Tidak | Tidak |
| `attendance.read.own` | Melihat catatan absensi milik sendiri. | Ya | Tidak | Tidak |
| `attendance.read` | Melihat seluruh data absensi personel. | Tidak | Ya | Ya |
| `attendance.manage` | Mengelola/mengoreksi data absensi. | Tidak | Ya | Tidak |
| `schedule.create` | Membuat jadwal jaga baru. | Tidak | Ya | Tidak |
| `schedule.read` | Melihat jadwal jaga. | Ya | Ya | Ya |
| `schedule.update` | Memperbarui jadwal jaga. | Tidak | Ya | Tidak |
| `schedule.delete` | Menghapus jadwal jaga. | Tidak | Ya | Tidak |
| `patrol.create` | Memulai atau membuat catatan patroli. | Ya | Tidak | Tidak |
| `patrol.read.own` | Melihat catatan patroli milik sendiri. | Ya | Tidak | Tidak |
| `patrol.read` | Melihat seluruh data patroli. | Tidak | Ya | Ya |
| `patrol.manage` | Mengelola data patroli & *checkpoint*. | Tidak | Ya | Tidak |
| `incident.create` | Membuat laporan kejadian baru. | Ya | Tidak | Tidak |
| `incident.read.own` | Melihat laporan kejadian milik sendiri. | Ya | Tidak | Tidak |
| `incident.read` | Melihat seluruh laporan kejadian. | Tidak | Ya | Ya |
| `incident.update` | Memperbarui status/detail laporan kejadian. | Tidak | Ya | Tidak |
| `incident.manage` | Mengelola laporan kejadian. | Tidak | Ya | Tidak |
| `documentation.create` | Mengunggah dokumentasi atau bukti foto. | Ya | Tidak | Tidak |
| `documentation.read` | Melihat seluruh dokumentasi. | Tidak | Ya | Ya |
| `documentation.manage` | Mengelola dokumentasi. | Tidak | Ya | Tidak |
| `personnel.create` | Menambahkan data personel baru. | Tidak | Ya | Tidak |
| `personnel.read` | Melihat daftar dan profil personel. | Tidak | Ya | Ya |
| `personnel.update` | Memperbarui data personel. | Tidak | Ya | Tidak |
| `personnel.delete` | Menghapus data personel. | Tidak | Ya | Tidak |
| `registration.read` | Melihat antrean pendaftaran anggota baru. | Tidak | Ya | Tidak |
| `registration.approve` | Menyetujui atau menolak pendaftaran anggota baru. | Tidak | Ya | Tidak |
| `report.generate` | Membuat laporan operasional. | Tidak | Ya | Ya |
| `report.export` | Mengekspor laporan ke dokumen PDF. | Tidak | Ya | Ya |
| `notification.read` | Membaca notifikasi masuk. | Ya | Ya | Ya |
| `notification.manage` | Membuat dan mengelola notifikasi. | Tidak | Ya | Tidak |
| `panicbutton.use` | Mengakses pilihan layanan darurat. | Ya | Ya | Ya |

---

## 4. Ruang Lingkup Fitur & Kebutuhan Fungsional (*Functional Requirements*)

### 4.1 Modul Autentikasi & Manajemen Sesi (`auth`)
* **Prioritas:** P0 (Kritis)
* **Deskripsi:** Mengatur login menggunakan username dan password, registrasi anggota baru dengan verifikasi OTP email dan persetujuan PIC PAMDAL, serta memuat hak akses sesuai peran.
* **Kebutuhan Fungsional:**
  1. **FR-AUTH-01:** Pengguna dapat masuk menggunakan **username dan password** melalui **Supabase Auth**; username diterjemahkan ke email oleh fungsi backend.
  2. **FR-AUTH-02:** Calon anggota dapat mendaftar dengan mengisi nama lengkap, username, password, email, nomor handphone, dan role yang diminta (`PAMDAL` atau `Pimpinan`). Role `PIC PAMDAL` tidak tersedia pada pendaftaran.
  3. **FR-AUTH-03:** Sistem memvalidasi keunikan username, email, dan nomor handphone serta format nomor handphone Indonesia. Nomor handphone hanya disimpan sebagai data kontak (tanpa verifikasi). Password bebas tanpa aturan kompleksitas.
  4. **FR-AUTH-04:** Sistem mengirimkan kode OTP 6 digit ke email pendaftar menggunakan integrasi **Brevo** untuk memverifikasi kepemilikan email.
  5. **FR-AUTH-05:** Sistem membatasi percobaan input OTP yang salah (maks. 5), menerapkan masa berlaku 5 menit, dan jeda kirim ulang 60 detik.
  6. **FR-AUTH-06:** Setelah OTP terverifikasi, akun dibuat berstatus `pending` dengan role tersimpan sebagai `requested_role`.
  7. **FR-AUTH-07:** PIC PAMDAL (`registration.read`, `registration.approve`) dapat melihat antrean pendaftaran, menyetujui (dengan opsi mengoreksi role) atau menolak disertai alasan. Pendaftar menerima notifikasi hasilnya.
  8. **FR-AUTH-08:** Hanya akun berstatus `active` yang dapat masuk. Setelah login, aplikasi memuat profil personel, peran (*role*), serta daftar *permission* dari basis data.
  9. **FR-AUTH-09:** Pengguna dapat mengatur ulang password melalui OTP email.
  10. **FR-AUTH-10:** Sistem membatasi percobaan login gagal dan menampilkan pesan kesalahan generik.
  11. **FR-AUTH-11:** PIC PAMDAL berperan sebagai administrator sistem. Akun PIC PAMDAL pertama dibuat secara manual (seed di Supabase), tidak melalui pendaftaran.
* **Kriteria Penerimaan (*Acceptance Criteria*):**
  * Akun `pending`, `rejected`, atau `inactive` ditolak saat login dengan pesan yang sesuai ("menunggu persetujuan" / "tidak aktif").
  * Pendaftar tidak dapat menetapkan role aktif sendiri; kolom `role` dan `status` hanya dapat diubah oleh PIC PAMDAL.
  * Username, email, atau nomor HP yang sudah terpakai ditolak saat pendaftaran.
  * Token sesi disimpan secara aman di perangkat dan setiap permintaan data ke backend divalidasi terhadap token tersebut.

### 4.2 Modul Absensi Kehadiran (`attendance`)
* **Prioritas:** P0 (Kritis)
* **Deskripsi:** Pencatatan kehadiran masuk/pulang personel PAMDAL dan pemantauan kehadiran oleh PIC serta Pimpinan.
* **Kebutuhan Fungsional:**
  1. **FR-ATT-01:** PAMDAL (`attendance.create`) dapat mencatat kehadiran beserta stempel waktu (*timestamp*) dan koordinat lokasi saat absensi dilakukan.
  2. **FR-ATT-02:** PAMDAL (`attendance.read.own`) hanya dapat melihat riwayat absensi miliknya sendiri.
  3. **FR-ATT-03:** PIC PAMDAL (`attendance.read`, `attendance.manage`) dapat memantau seluruh daftar kehadiran personel dan melakukan koreksi/pengelolaan status absensi bila diperlukan.
  4. **FR-ATT-04:** Pimpinan (`attendance.read`) dapat melihat rekapitulasi dan detail absensi seluruh personel.
* **Kriteria Penerimaan (*Acceptance Criteria*):**
  * PAMDAL tidak dapat mengakses atau memodifikasi data absensi milik personel lain.
  * Setiap koreksi absensi oleh PIC PAMDAL tercatat dalam log audit beserta waktu dan identitas pengubah.

### 4.3 Modul Jadwal Jaga (`schedule`)
* **Prioritas:** P0 (Kritis)
* **Deskripsi:** Pengelolaan jadwal sif jaga personel secara terpusat.
* **Kebutuhan Fungsional:**
  1. **FR-SCH-01:** PIC PAMDAL (`schedule.create`, `schedule.update`, `schedule.delete`) dapat menambahkan, mengubah, dan menghapus jadwal jaga personel.
  2. **FR-SCH-02:** Pemilihan tanggal dan jam sif jaga menggunakan komponen *date-time picker*.
  3. **FR-SCH-03:** Seluruh peran (`schedule.read`) dapat melihat jadwal jaga yang telah diterbitkan dan disinkronkan dengan database Supabase.
* **Kriteria Penerimaan (*Acceptance Criteria*):**
  * Perubahan jadwal yang disimpan oleh PIC PAMDAL langsung diperbarui pada tampilan jadwal PAMDAL dan Pimpinan saat perangkat terhubung ke jaringan.

### 4.4 Modul Patroli & Telemetri GPS (`patrol`)
* **Prioritas:** P0 (Kritis)
* **Deskripsi:** Pemantauan aktivitas patroli keliling berbasis GPS perangkat, deteksi titik *checkpoint*, dan pengiriman telemetri melalui protokol MQTT (HiveMQ).
* **Kebutuhan Fungsional:**
  1. **FR-PAT-01:** PAMDAL (`patrol.create`) dapat memulai sesi patroli dengan menekan tombol **Start Patroli** dan mengakhirinya saat selesai.
  2. **FR-PAT-02:** Aplikasi memeriksa dan meminta izin akses lokasi perangkat Android sebelum memulai pengambilan koordinat GPS.
  3. **FR-PAT-03:** Selama sesi patroli aktif, aplikasi memantau lokasi GPS perangkat (termasuk saat aplikasi berada di latar belakang) dan mengirim pesan telemetri melalui broker **HiveMQ (MQTT)**.
  4. **FR-PAT-04:** Ketika koordinat GPS PAMDAL memasuki radius *geofence* dari suatu *checkpoint* yang ditentukan, sistem mendeteksi bahwa *checkpoint* telah dilewati.
  5. **FR-PAT-05:** Aplikasi menampilkan notifikasi bahwa *checkpoint* berhasil dilewati serta menyinkronkan catatan waktu dan lokasi *checkpoint* ke sistem.
  6. **FR-PAT-06:** Riwayat patroli dapat dilihat oleh PAMDAL (`patrol.read.own` untuk miliknya sendiri) serta oleh PIC PAMDAL dan Pimpinan (`patrol.read` untuk seluruh personel).
  7. **FR-PAT-07:** PIC PAMDAL (`patrol.manage`) dapat mengelola data patroli dan konfigurasi *checkpoint*.
* **Kriteria Penerimaan (*Acceptance Criteria*):**
  * Apabila koneksi internet terputus di tengah patroli, peristiwa *checkpoint* dan titik GPS disimpan secara lokal dan otomatis dikirim ulang saat koneksi kembali tersedia tanpa menimbulkan duplikasi catatan.
  * Aplikasi mendeteksi dan menolak koordinat yang berasal dari aplikasi pemalsu lokasi (*mock location*).

### 4.5 Modul Pelaporan Kejadian (`incident`)
* **Prioritas:** P0 (Kritis)
* **Deskripsi:** Pencatatan dan tindak lanjut insiden atau kejadian menonjol di lingkungan BPSDM Kemendagri.
* **Kebutuhan Fungsional:**
  1. **FR-INC-01:** PAMDAL (`incident.create`) dapat mengisi formulir laporan kejadian yang memuat identitas pelapor, waktu kejadian, titik lokasi (bila tersedia), kategori kejadian, deskripsi kronologi, dan tautan dokumentasi foto.
  2. **FR-INC-02:** PAMDAL (`incident.read.own`) dapat melihat daftar dan status penanganan laporan kejadian yang dibuatnya sendiri.
  3. **FR-INC-03:** PIC PAMDAL (`incident.read`, `incident.update`, `incident.manage`) dapat melihat seluruh laporan kejadian, memperbarui status penanganan (misal: *Dilaporkan*, *Dalam Penanganan*, *Selesai*), serta menambahkan catatan tindak lanjut.
  4. **FR-INC-04:** Pimpinan (`incident.read`) dapat memantau seluruh daftar dan detail laporan kejadian.
* **Kriteria Penerimaan (*Acceptance Criteria*):**
  * Setiap laporan kejadian yang baru dikirim oleh PAMDAL otomatis memiliki status awal dan dapat langsung dilihat oleh PIC PAMDAL serta Pimpinan.

### 4.6 Modul Dokumentasi (`documentation`)
* **Prioritas:** P0 (Kritis)
* **Deskripsi:** Pengelolaan bukti visual (foto) yang berkaitan dengan laporan kejadian atau kegiatan operasional.
* **Kebutuhan Fungsional:**
  1. **FR-DOC-01:** PAMDAL (`documentation.create`) dapat mengambil foto dari kamera atau memilih gambar dari galeri untuk diunggah sebagai bukti laporan kejadian.
  2. **FR-DOC-02:** Berkas foto disimpan pada **Supabase Storage** dan metadata/referensi jalurnya dicatat pada database PostgreSQL.
  3. **FR-DOC-03:** PIC PAMDAL (`documentation.read`, `documentation.manage`) dapat melihat dan mengelola berkas dokumentasi.
  4. **FR-DOC-04:** Pimpinan (`documentation.read`) dapat melihat dokumentasi foto yang terlampir pada laporan.
* **Kriteria Penerimaan (*Acceptance Criteria*):**
  * Sistem memvalidasi format berkas (hanya gambar seperti JPEG/PNG/WebP) dan membatasi ukuran maksimal berkas sebelum diunggah.
  * URL akses berkas foto dilindungi oleh otorisasi pengguna sehingga tidak dapat diakses secara publik tanpa sesi yang sah.

### 4.7 Modul Notifikasi (`notification`)
* **Prioritas:** P1 (Tinggi)
* **Deskripsi:** Penyampaian informasi operasional dan peringatan otomatis kepada pengguna aplikasi.
* **Kebutuhan Fungsional:**
  1. **FR-NOT-01:** Sistem membuat notifikasi otomatis ketika *checkpoint* patroli terlewati atau ketika terdapat informasi operasional penting.
  2. **FR-NOT-02:** PAMDAL, PIC PAMDAL, dan Pimpinan (`notification.read`) dapat membaca daftar notifikasi dan menandai status telah dibaca (*read status*).
  3. **FR-NOT-03:** PIC PAMDAL (`notification.manage`) dapat membuat, mengirim, dan mengelola notifikasi operasional untuk personel.
* **Kriteria Penerimaan (*Acceptance Criteria*):**
  * Pengguna dapat membedakan antara notifikasi yang belum dibaca dan yang sudah dibaca pada daftar notifikasi.

### 4.8 Modul Panic Button (`panicbutton`)
* **Prioritas:** P0 (Kritis)
* **Deskripsi:** Akses cepat ke tiga layanan tanggap darurat eksternal di sekitar lingkungan BPSDM Kemendagri.
* **Kebutuhan Fungsional:**
  1. **FR-PAN-01:** Seluruh pengguna (`panicbutton.use`) dapat membuka fitur **Panic Button** dari layar utama aplikasi.
  2. **FR-PAN-02:** Aplikasi menampilkan tiga pilihan layanan darurat:
     * **RS JMC (Jakarta Medical Center)**
     * **Polsek Pancoran**
     * **Damkar Kalibata**
  3. **FR-PAN-03:** Memilih salah satu layanan akan menampilkan informasi kontak terverifikasi dan tombol tindakan cepat untuk melakukan panggilan telepon (*dialer intent*) atau membuka petunjuk arah peta.
* **Kriteria Penerimaan (*Acceptance Criteria*):**
  * Daftar ketiga kontak darurat tetap dapat dibuka dan dihubungi melalui jaringan seluler meskipun perangkat sedang tidak memiliki koneksi data internet.
  * Antarmuka menampilkan keterangan jelas bahwa fitur ini adalah alat bantu akses cepat dan bukan pengganti saluran darurat nasional resmi.

### 4.9 Modul Dashboard, Grafik, & Laporan PDF (`dashboard` & `report`)
* **Prioritas:** P1 (Tinggi)
* **Deskripsi:** Penyajian ringkasan statistik operasional dalam bentuk grafik serta pembuatan dokumen laporan PDF resmi.
* **Kebutuhan Fungsional:**
  1. **FR-REP-01:** Menampilkan dashboard yang disesuaikan dengan peran pengguna (ringkasan sif & patroli pribadi untuk PAMDAL; statistik keseluruhan kehadiran, kepatuhan patroli, dan insiden untuk PIC PAMDAL & Pimpinan).
  2. **FR-REP-02:** Merender visualisasi grafik menggunakan pustaka **Syncfusion Flutter Charts**.
  3. **FR-REP-03:** PIC PAMDAL dan Pimpinan (`report.generate`, `report.export`) dapat memilih filter periode tanggal (menggunakan *date-time picker*) dan jenis laporan untuk menghasilkan dokumen laporan.
  4. **FR-REP-04:** Mengekspor laporan ke dalam format dokumen PDF menggunakan pustaka **`syncfusion_flutter_pdf`**.
* **Kriteria Penerimaan (*Acceptance Criteria*):**
  * Dokumen PDF yang dihasilkan memuat tabel data yang sesuai dengan filter periode tanggal yang dipilih dan dapat dibuka/dibagikan dari perangkat Android.

### 4.10 Modul Data Personel (`personnel`)
* **Prioritas:** P1 (Tinggi)
* **Deskripsi:** Pengelolaan data induk personel PAMDAL di lingkungan BPSDM Kemendagri.
* **Kebutuhan Fungsional:**
  1. **FR-PER-01:** PIC PAMDAL (`personnel.create`, `personnel.read`, `personnel.update`, `personnel.delete`) dapat menambahkan personel baru, melihat detail, memperbarui informasi profil/peran, serta menonaktifkan/menghapus data personel.
  2. **FR-PER-02:** Pimpinan (`personnel.read`) dapat melihat daftar dan detail profil seluruh personel PAMDAL.
  3. **FR-PER-03:** PAMDAL tidak memiliki akses ke menu pengelolaan daftar personel.
* **Kriteria Penerimaan (*Acceptance Criteria*):**
  * Menu pengelolaan personel disembunyikan dari antarmuka PAMDAL dan setiap percobaan akses langsung ke tabel `personnel` oleh role PAMDAL (selain membaca profil dirinya sendiri) ditolak oleh kebijakan RLS Supabase.

---

## 5. Alur Pengguna Utama (*Core User Flows*)

### 5.1 Alur Pelaksanaan Patroli & Checkpoint
1. **Mulai:** PAMDAL membuka menu Patroli dan menekan tombol **Start Patroli**.
2. **Validasi Izin:** Aplikasi memeriksa izin GPS. Jika belum diberikan, aplikasi menampilkan penjelasan tujuan penggunaan lokasi dan meminta izin pengguna.
3. **Pelacakan Aktif:** Aplikasi mengaktifkan layanan latar belakang (*Foreground Service*), membaca koordinat GPS perangkat, dan mengirim telemetri melalui broker MQTT (HiveMQ).
4. **Evaluasi Checkpoint:** Saat PAMDAL berjalan melewati titik *checkpoint* yang telah ditentukan, aplikasi mendeteksi bahwa jarak berada di dalam radius *checkpoint*.
5. **Notifikasi & Sinkronisasi:** Aplikasi memunculkan notifikasi *"Checkpoint Terlewati"* pada perangkat PAMDAL dan mengirim data pencapaian *checkpoint* ke sistem (MQTT & Supabase).
6. **Selesai & Pemantauan:** PAMDAL mengakhiri sesi patroli. Laporan sesi patroli dan daftar *checkpoint* yang telah dilewati langsung dapat ditinjau oleh PAMDAL, PIC PAMDAL, dan Pimpinan.

### 5.2 Alur Pelaporan Kejadian & Bukti Dokumentasi
1. **Mulai:** PAMDAL menemukan kejadian keamanan di lapangan dan membuka menu **Lapor Kejadian**.
2. **Pengisian Data:** PAMDAL memilih kategori kejadian, mengisi deskripsi, dan sistem menyematkan waktu serta koordinat GPS saat itu secara otomatis.
3. **Unggah Dokumentasi:** PAMDAL memotret kondisi di lapangan melalui fitur **Dokumentasi**. Foto diunggah ke Supabase Storage dan terhubung ke draf laporan.
4. **Kirim Laporan:** PAMDAL menekan tombol kirim. Data tersimpan di Supabase dan memicu notifikasi ke PIC PAMDAL.
5. **Tindak Lanjut:** PIC PAMDAL memeriksa laporan beserta foto bukti, lalu memperbarui status penanganan kejadian hingga selesai.

---

## 6. Kebutuhan Non-Fungsional (*Non-Functional Requirements*)

### 6.1 Keamanan (*Security*)
* **Prinsip *Least Privilege* & Validasi Backend:** Pembatasan hak akses tidak boleh hanya mengandalkan penyembunyian tombol di antarmuka Flutter, melainkan wajib divalidasi di sisi database melalui **Row Level Security (RLS)** Supabase.
* **Perlindungan Rahasia Layanan:** Kredensial berhak istimewa (seperti *Service Role Key* Supabase dan kunci API utama Brevo) dilarang ditanamkan di dalam kode aplikasi Android.
* **Jejak Audit (*Audit Trail*):** Setiap pembuatan dan perubahan data penting wajib mencatat waktu kejadian (*timestamp*) dan identitas pengguna pelaksana.

### 6.2 Keandalan & Toleransi Jaringan (*Reliability*)
* **Penanganan Koneksi Terputus:** Saat jaringan seluler/Wi-Fi terputus di tengah patroli, aplikasi harus menahan data telemetri dan *checkpoint* di antrean lokal serta melakukan sinkronisasi ulang secara idempoten (mencegah pesan MQTT duplikat atau data ganda) ketika koneksi pulih.
* **Eksekusi Latar Belakang Android:** Pengambilan sampel GPS selama sesi patroli aktif harus tetap berjalan meskipun layar ponsel terkunci atau pengguna berpindah ke aplikasi lain, dengan konsumsi baterai yang dioptimalkan.

### 6.3 Spesifikasi Teknis Wajib (*Tech Stack Constraints*)
* **Platform & Framework:** Android menggunakan **Flutter** dan bahasa **Dart**.
* **State Management:** Menggunakan mekanisme bawaan Flutter (`setState`, `ValueNotifier`, `ChangeNotifier`, `InheritedWidget`) tanpa ketergantungan pada pustaka *state management* eksternal tambahan.
* **Backend & Penyimpanan:** **Supabase Auth**, **Supabase PostgreSQL**, dan **Supabase Storage**.
* **Layanan OTP & Telemetri:** **Brevo** untuk pengiriman OTP email; **HiveMQ + MQTT** untuk pertukaran pesan telemetri GPS.
* **Visualisasi & Pelaporan:** **Syncfusion Flutter Charts** untuk grafik dan **`syncfusion_flutter_pdf`** untuk pembuatan dokumen PDF.

---

## 7. Daftar Ketergantungan & Konfirmasi Pra-Implementasi

Sebelum pengembangan fitur terkait difinalisasi, tim produk dan pemangku kepentingan di BPSDM Kemendagri perlu mengonfirmasi poin-poin berikut:

| No | Area | Hal yang Perlu Dikonfirmasi | Dampak pada Produk |
| :---: | :--- | :--- | :--- |
| 1 | **Sumber GPS & Checkpoint** | Daftar koordinat resmi setiap titik *checkpoint* di BPSDM, radius toleransi (meter), dan apakah *checkpoint* wajib dilewati secara berurutan. | Menentukan logika validasi *geofencing* pada modul `patrol`. |
| 2 | **Broker MQTT** | Detail kredensial klaster HiveMQ, struktur topik final, dan kebijakan TLS/autentikasi klien. | Menentukan konfigurasi koneksi telemetri *real-time*. |
| 3 | **Kontak Panic Button** | Verifikasi nomor telepon darurat resmi, alamat lengkap, dan titik koordinat peta untuk **RS JMC**, **Polsek Pancoran**, dan **Damkar Kalibata**. | Memastikan keakuratan panggilan darurat pada modul `panicbutton`. |
| 4 | **Aturan Absensi** | Apakah pencatatan kehadiran (`attendance.create`) mewajibkan pengguna berada di dalam radius lokasi kantor BPSDM Kemendagri dan jam toleransi keterlambatan. | Menentukan aturan validasi lokasi dan waktu saat *check-in/out*. |
| 5 | **Kanal Notifikasi** | Apakah notifikasi hanya ditampilkan di dalam aplikasi (*in-app notification*) atau juga memerlukan *push notification* saat aplikasi tertutup. | Menentukan kebutuhan layanan notifikasi latar belakang. |
| 6 | **Template Laporan PDF** | Format kop surat resmi BPSDM Kemendagri, susunan kolom tabel untuk masing-masing laporan, serta kolom tanda tangan pejabat. | Menentukan tata letak cetak pada `syncfusion_flutter_pdf`. |

---

## 8. Tahapan Rilis Pengembangan (*Release Roadmap*)

### Fase 1: Fondasi, Autentikasi & Manajemen Dasar (MVP Inti)
* Konfigurasi proyek Flutter, skema database PostgreSQL, dan kebijakan RLS Supabase.
* Modul Autentikasi (`auth`) dengan login username/password, registrasi + OTP Email Brevo, persetujuan PIC PAMDAL, dan pemuatan RBAC.
* Modul Data Personel (`personnel`), Modul Jadwal Jaga (`schedule`), dan Modul Absensi (`attendance`).

### Fase 2: Operasional Lapangan & Keadaan Darurat
* Modul Patroli (`patrol`) dengan akuisisi GPS latar belakang, deteksi *checkpoint*, dan integrasi broker MQTT HiveMQ.
* Modul Pelaporan Kejadian (`incident`) terintegrasi dengan Modul Dokumentasi Foto (`documentation`) di Supabase Storage.
* Modul Panic Button (`panicbutton`) untuk akses cepat ke RS JMC, Polsek Pancoran, dan Damkar Kalibata.

### Fase 3: Pemantauan Eksekutif, Notifikasi & Pelaporan PDF
* Modul Notifikasi (`notification`) untuk peringatan *checkpoint* dan pengumuman PIC PAMDAL.
* Modul Dashboard & Grafik menggunakan `syncfusion_flutter_charts`.
* Modul Pembuatan & Ekspor Laporan PDF (`report`) menggunakan `syncfusion_flutter_pdf` beserta pengujian menyeluruh (*User Acceptance Testing* / UAT) pada perangkat Android target.