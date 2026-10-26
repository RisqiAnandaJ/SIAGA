import 'package:flutter/material.dart';

import '../../core/services/auth_repository.dart';
import '../../core/state/session.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/list_rows.dart';
import '../../core/widgets/page_scaffolds.dart';
import '../../core/widgets/siaga_buttons.dart';
import '../../core/widgets/siaga_fields.dart';
import 'otp_page.dart';

/// Lupa password: kirim kode pemulihan ke email terdaftar.
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _email = TextEditingController();
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_busy) return;
    final value = _email.text.trim();
    if (!value.contains('@') || !value.contains('.')) {
      setState(() => _error = 'Masukkan alamat email yang valid');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final navigator = Navigator.of(context);
    final session = SessionScope.read(context);
    try {
      await session.auth.sendRecoveryOtp(value);
      if (!mounted) return;
      // Respons sama untuk email terdaftar maupun tidak (tidak membocorkan akun).
      navigator.push(
        MaterialPageRoute<void>(
          builder: (_) => OtpPage(email: value, purpose: OtpPurpose.recovery),
        ),
      );
    } on AuthFailure catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthPage(
      title: 'Lupa Password',
      children: [
        const AuthHero(
          heading: 'Pulihkan akses Anda',
          subtitle:
              'Gunakan email yang terdaftar untuk menerima kode pemulihan.',
        ),
        GlassCard(
          child: Column(
            children: [
              GlassField(
                label: 'Email terdaftar',
                hint: 'nama@example.com',
                controller: _email,
                icon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
                errorText: _error,
              ),
              const SizedBox(height: 16),
              SiagaButton.gold(
                label: _busy ? 'Mengirim kode...' : 'Kirim kode pemulihan',
                onPressed: _busy ? null : _send,
              ),
            ],
          ),
        ),
        const InfoBanner(
          title: 'Aman dan pribadi',
          body:
              'Jika email terdaftar, kode verifikasi akan dikirim. Kode berlaku selama 5 menit.',
        ),
        SiagaButton.ghost(
          label: 'Kembali ke Masuk',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ],
    );
  }
}
