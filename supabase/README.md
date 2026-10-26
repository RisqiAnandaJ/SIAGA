# Setup Supabase untuk SIAGA

## 1. Basis data
Jalankan `migrations/20261024000000_auth_registration.sql` (SQL editor atau
`supabase db push`). Berkas ini membuat tabel `roles`, `role_permissions`,
`personnel`, `notifications`, `audit_logs`, data awal role/permission, trigger
pembuatan profil, RPC (`get_login_email`, `check_registration_available`,
`approve_registration`, `reject_registration`), dan kebijakan RLS.

## 2. Authentication
- **Providers → Email**: aktifkan, **Confirm email = ON**.
- **Email OTP Expiration = 300** detik (masa berlaku 5 menit).
- **Email Templates** (Confirm signup dan Reset password): tampilkan `{{ .Token }}`
  (kode 6 digit), bukan tautan.
- **SMTP Settings**: isi SMTP Brevo (host `smtp-relay.brevo.com`, port 587,
  login dan SMTP key dari dasbor Brevo). Simpan kunci hanya di dasbor Supabase,
  jangan di kode aplikasi.
- **Rate Limits**: ketatkan batas sign-in dan pengiriman email/OTP.
- Panjang password minimum: atur di **Password Settings** (aplikasi meminta ≥ 8).

## 3. Akun PIC PAMDAL pertama
Lihat komentar di bagian akhir berkas migrasi (dibuat manual, bukan lewat pendaftaran).

## 4. Menjalankan aplikasi
```
flutter run \
  --dart-define=SUPABASE_URL=https://<project>.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=<anon / publishable key>
```
Tanpa kedua nilai, aplikasi berjalan dalam mode demonstrasi (tanpa backend).
Jangan pernah memasukkan `service_role` key ke aplikasi.
