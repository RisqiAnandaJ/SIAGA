import 'package:flutter/material.dart';

import '../../core/services/auth_repository.dart';
import '../../core/state/session.dart';
import '../../core/theme/siaga_colors.dart';
import '../../core/theme/siaga_text.dart';
import '../../core/utils/phone.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/list_rows.dart';
import '../../core/widgets/page_scaffolds.dart';
import '../../core/widgets/siaga_buttons.dart';
import '../../core/widgets/siaga_fields.dart';
import '../../core/widgets/siaga_pills.dart';
import 'otp_page.dart';

/// Registrasi anggota baru. Peran hanya diajukan; aktif setelah disetujui PIC.
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _name = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  int _role = 0;
  bool _busy = false;
  String? _formError;
  final Map<String, String> _errors = {};

  @override
  void dispose() {
    for (final c in [_name, _username, _password, _confirm, _email, _phone]) {
      c.dispose();
    }
    super.dispose();
  }

  bool _validate() {
    _errors.clear();
    if (_name.text.trim().isEmpty) _errors['name'] = 'Nama lengkap wajib diisi';
    if (_username.text.trim().length < 4) {
      _errors['username'] = 'Username minimal 4 karakter';
    }
    if (_password.text.length < 8) {
      _errors['password'] = 'Password minimal 8 karakter';
    }
    if (_confirm.text != _password.text) {
      _errors['confirm'] = 'Konfirmasi password tidak sama';
    }
    final email = _email.text.trim();
    if (!email.contains('@') || !email.contains('.')) {
      _errors['email'] = 'Alamat email tidak valid';
    }
    if (normalizeIndonesianPhone(_phone.text) == null) {
      _errors['phone'] = 'Nomor handphone tidak valid (contoh: 812xxxxxxxx)';
    }
    setState(() {});
    return _errors.isEmpty;
  }

  Future<void> _submit() async {
    if (_busy || !_validate()) return;
    setState(() {
      _busy = true;
      _formError = null;
    });
    final navigator = Navigator.of(context);
    final session = SessionScope.read(context);
    try {
      await session.auth.register(
        RegistrationData(
          fullName: _name.text.trim(),
          username: _username.text.trim(),
          password: _password.text,
          email: _email.text.trim(),
          phone: normalizeIndonesianPhone(_phone.text)!,
          requestedRole: _role == 0 ? 'pamdal' : 'pimpinan',
        ),
      );
      if (!mounted) return;
      navigator.push(
        MaterialPageRoute<void>(
          builder: (_) => OtpPage(
            email: _email.text.trim(),
            purpose: OtpPurpose.registration,
            name: _name.text.trim().split(' ').first,
            requestedRole: _role == 0 ? 'PAMDAL' : 'Pimpinan',
          ),
        ),
      );
    } on AuthFailure catch (e) {
      if (!mounted) return;
      setState(() {
        if (e.field != null) {
          _errors[e.field!] = e.message;
        } else {
          _formError = e.message;
        }
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthPage(
      title: 'Buat akun SIAGA',
      children: [
        Text(
          '01 / Identitas • 02 / Verifikasi • 03 / Persetujuan',
          style: SiagaText.bodyMuted,
        ),
        GlassCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlassField(
                label: 'Nama Lengkap',
                hint: 'Nama sesuai data penugasan',
                controller: _name,
                errorText: _errors['name'],
              ),
              const SizedBox(height: 14),
              GlassField(
                label: 'Username',
                hint: 'contoh: nama.belakang',
                controller: _username,
                errorText: _errors['username'],
              ),
              const SizedBox(height: 14),
              GlassField(
                label: 'Password',
                hint: 'Masukkan password',
                controller: _password,
                obscure: true,
                errorText: _errors['password'],
                helper: 'Minimal 8 karakter, gunakan huruf dan angka.',
              ),
              const SizedBox(height: 14),
              GlassField(
                label: 'Konfirmasi Password',
                hint: 'Ulangi password',
                controller: _confirm,
                obscure: true,
                errorText: _errors['confirm'],
              ),
              const SizedBox(height: 14),
              GlassField(
                label: 'Email',
                hint: 'nama@example.com',
                controller: _email,
                icon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
                errorText: _errors['email'],
              ),
              const SizedBox(height: 14),
              GlassField(
                label: 'Nomor Handphone',
                hint: 'Masukkan nomor handphone',
                controller: _phone,
                prefix: '+62',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                errorText: _errors['phone'],
              ),
              const SizedBox(height: 14),
              Text('Peran yang diajukan', style: SiagaText.label),
              const SizedBox(height: 8),
              PillTabs(
                labels: const ['PAMDAL', 'Pimpinan'],
                index: _role,
                onChanged: (i) => setState(() => _role = i),
                height: 54,
              ),
            ],
          ),
        ),
        const InfoBanner(
          title: 'Persetujuan akun',
          body:
              'Verifikasi email Anda. PIC PAMDAL akan meninjau pengajuan sebelum akses diaktifkan.',
        ),
        if (_formError != null)
          Text(
            _formError!,
            textAlign: TextAlign.center,
            style: SiagaText.bodyMuted.copyWith(color: SiagaColors.dangerText),
          ),
        SiagaButton.gold(
          label: _busy ? 'Mengirim kode...' : 'Daftar & verifikasi email',
          onPressed: _busy ? null : _submit,
        ),
        Center(
          child: SiagaTextLink(
            label: 'Sudah punya akun? Masuk',
            color: SiagaColors.pureWhite,
            fontSize: 14,
            onTap: () => Navigator.of(context).maybePop(),
          ),
        ),
      ],
    );
  }
}
