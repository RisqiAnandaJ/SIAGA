import 'package:flutter/material.dart';

import '../../core/navigation/auth_router.dart';
import '../../core/services/auth_repository.dart';
import '../../core/state/session.dart';
import '../../core/theme/siaga_colors.dart';
import '../../core/theme/siaga_text.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/list_rows.dart';
import '../../core/widgets/page_scaffolds.dart';
import '../../core/widgets/siaga_buttons.dart';
import '../../core/widgets/siaga_fields.dart';

/// Atur ulang password setelah kode pemulihan terverifikasi.
class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({
    super.key,
    required this.email,
    this.signOutAfter = true,
  });

  final String email;

  /// `true` untuk pemulihan (kembali ke layar masuk); `false` saat pengguna
  /// yang sudah masuk mengubah password dari profil.
  final bool signOutAfter;

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  bool _busy = false;

  bool get _lengthOk => _password.text.length >= 8;

  /// Anjuran saja (aplikasi tidak menerapkan aturan kompleksitas).
  bool get _mixOk =>
      RegExp(r'[A-Za-z]').hasMatch(_password.text) &&
      RegExp(r'[0-9]').hasMatch(_password.text);

  Future<void> _save() async {
    if (_busy) return;
    if (!_lengthOk) {
      setState(() => _error = 'Password minimal 8 karakter');
      return;
    }
    if (_password.text != _confirm.text) {
      setState(() => _error = 'Konfirmasi password tidak sama');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final session = SessionScope.read(context);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await session.auth.updatePassword(_password.text);
      if (widget.signOutAfter) {
        await session.signOut();
        if (!mounted) return;
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Password baru tersimpan. Silakan masuk.'),
          ),
        );
        openLogin(context);
      } else {
        messenger.showSnackBar(
          const SnackBar(content: Text('Password berhasil diubah.')),
        );
        navigator.pop();
      }
    } on AuthFailure catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _rule(String text, bool ok) => Padding(
    padding: const EdgeInsets.only(top: 4),
    child: Row(
      children: [
        Icon(
          Icons.check,
          size: 14,
          color: ok ? SiagaColors.successText : SiagaColors.silverMist,
        ),
        const SizedBox(width: 6),
        Text(text, style: SiagaText.bodyMuted.copyWith(fontSize: 12)),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return AuthPage(
      title: 'Atur Ulang Password',
      children: [
        AuthHero(
          heading: 'Mulai dengan password baru',
          subtitle: 'Email ${widget.email} telah terverifikasi.',
        ),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlassField(
                label: 'Password baru',
                hint: 'Masukkan password baru',
                controller: _password,
                obscure: true,
                onChanged: (_) => setState(() => _error = null),
              ),
              const SizedBox(height: 8),
              _rule('Minimal 8 karakter', _lengthOk),
              _rule('Kombinasi huruf dan angka', _mixOk),
              const SizedBox(height: 14),
              GlassField(
                label: 'Konfirmasi password baru',
                hint: 'Ulangi password baru',
                controller: _confirm,
                obscure: true,
                errorText: _error,
              ),
              const SizedBox(height: 16),
              SiagaButton.gold(
                label: _busy ? 'Menyimpan...' : 'Simpan password baru',
                onPressed: _busy ? null : _save,
              ),
            ],
          ),
        ),
        const InfoBanner(
          title: 'Lindungi akun Anda',
          body:
              'Gunakan password yang berbeda dari sebelumnya dan jangan bagikan kepada siapa pun.',
        ),
      ],
    );
  }
}
