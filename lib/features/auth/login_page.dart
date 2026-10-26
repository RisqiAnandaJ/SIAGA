import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/navigation/auth_router.dart';
import '../../core/state/session.dart';
import '../../core/services/auth_repository.dart';
import '../../core/theme/siaga_colors.dart';
import '../../core/theme/siaga_text.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/page_scaffolds.dart';
import '../../core/widgets/siaga_buttons.dart';
import '../../core/widgets/siaga_fields.dart';
import 'forgot_password_page.dart';
import 'register_page.dart';

/// Layar masuk (username + password). Pesan gagal bersifat generik dan
/// percobaan gagal beruntun dibatasi sementara di sisi aplikasi.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const int _maxAttempts = 5;
  static const int _lockSeconds = 60;

  final _username = TextEditingController();
  final _password = TextEditingController();
  String? _error;
  bool _busy = false;
  int _failures = 0;
  int _lockLeft = 0;
  Timer? _lockTimer;

  @override
  void dispose() {
    _lockTimer?.cancel();
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  void _lock() {
    _lockLeft = _lockSeconds;
    _lockTimer?.cancel();
    _lockTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        _lockLeft--;
        if (_lockLeft <= 0) {
          t.cancel();
          _failures = 0;
          _error = null;
        } else {
          _error =
              'Terlalu banyak percobaan. Coba lagi dalam $_lockLeft detik.';
        }
      });
    });
    _error = 'Terlalu banyak percobaan. Coba lagi dalam $_lockLeft detik.';
  }

  Future<void> _submit() async {
    if (_busy || _lockLeft > 0) return;
    if (_username.text.trim().isEmpty || _password.text.isEmpty) {
      setState(() => _error = 'Username atau password salah');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });

    final session = SessionScope.read(context);
    try {
      final profile = await session.auth.signIn(_username.text, _password.text);
      if (!mounted) return;
      _failures = 0;
      openForProfile(context, profile);
    } on AuthFailure catch (e) {
      if (!mounted) return;
      setState(() {
        _failures++;
        _error = e.message;
        if (_failures >= _maxAttempts) _lock();
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthPage(
      showBack: false,
      children: [
        const AuthHero(
          heading: 'Selamat datang kembali',
          subtitle: 'Masuk untuk melanjutkan tugas Anda di SIAGA.',
        ),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Masuk ke akun',
                style: SiagaText.heading2.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 18),
              GlassField(
                label: 'Username',
                hint: 'Masukkan username',
                controller: _username,
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
              GlassField(
                label: 'Password',
                hint: 'Masukkan password',
                controller: _password,
                obscure: true,
                errorText: _error,
              ),
              SiagaTextLink(
                label: 'Lupa password?',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ForgotPasswordPage(),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              SiagaButton.gold(
                label: _busy ? 'Memeriksa...' : 'Masuk',
                icon: _busy ? null : Icons.arrow_forward,
                onPressed: (_busy || _lockLeft > 0) ? null : _submit,
              ),
            ],
          ),
        ),
        Center(
          child: InkWell(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const RegisterPage()),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Belum punya akun? Daftar',
                style: SiagaText.body.copyWith(
                  fontSize: 15,
                  color: SiagaColors.pureWhite,
                ),
              ),
            ),
          ),
        ),
        Text(
          'Akses operasional mengikuti peran dan persetujuan PIC PAMDAL.',
          textAlign: TextAlign.center,
          style: SiagaText.bodyMuted.copyWith(fontSize: 12),
        ),
      ],
    );
  }
}
