import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/navigation/auth_router.dart';
import '../../core/services/auth_repository.dart';
import '../../core/state/session.dart';
import '../../core/theme/siaga_colors.dart';
import '../../core/theme/siaga_text.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/page_scaffolds.dart';
import '../../core/widgets/siaga_buttons.dart';
import 'reset_password_page.dart';
import 'status_pages.dart';

enum OtpPurpose { registration, recovery }

/// Verifikasi kode 6 digit dari email. Berlaku 5 menit, kirim ulang setelah 60 detik.
class OtpPage extends StatefulWidget {
  const OtpPage({
    super.key,
    required this.email,
    required this.purpose,
    this.name = '',
    this.requestedRole = 'PAMDAL',
  });

  final String email;
  final OtpPurpose purpose;
  final String name;
  final String requestedRole;

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  static const int _validitySeconds = 300;
  static const int _resendSeconds = 60;
  static const int _length = 6;
  static const int _maxAttempts = 5;

  final _controller = TextEditingController();
  final _focus = FocusNode();
  Timer? _timer;
  int _remaining = _validitySeconds;
  int _resendIn = _resendSeconds;
  int _attempts = 0;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_remaining > 0) _remaining--;
        if (_resendIn > 0) _resendIn--;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  String _mmss(int s) =>
      '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  Future<void> _resend() async {
    final auth = SessionScope.read(context).auth;
    try {
      if (widget.purpose == OtpPurpose.registration) {
        await auth.resendSignupOtp(widget.email);
      } else {
        await auth.sendRecoveryOtp(widget.email);
      }
    } on AuthFailure catch (e) {
      if (mounted) setState(() => _error = e.message);
      return;
    }
    if (!mounted) return;
    setState(() {
      _remaining = _validitySeconds;
      _resendIn = _resendSeconds;
      _attempts = 0;
      _controller.clear();
      _error = null;
    });
  }

  Future<void> _verify() async {
    if (_busy) return;
    if (_attempts >= _maxAttempts) {
      setState(
        () => _error = 'Terlalu banyak kode salah. Kirim ulang kode baru.',
      );
      return;
    }
    if (_remaining == 0) {
      setState(() => _error = 'Kode kedaluwarsa. Kirim ulang kode.');
      return;
    }
    if (_controller.text.length < _length) {
      setState(() => _error = 'Masukkan 6 digit kode verifikasi');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });

    final session = SessionScope.read(context);
    final navigator = Navigator.of(context);
    try {
      final Widget next;
      if (widget.purpose == OtpPurpose.registration) {
        final profile = await session.auth.verifySignupOtp(
          widget.email,
          _controller.text,
        );
        if (!mounted) return;
        next = profile != null
            ? screenForProfile(context, profile)
            : PendingApprovalPage(
                name: widget.name,
                email: widget.email,
                requestedRole: widget.requestedRole,
              );
      } else {
        await session.auth.verifyRecoveryOtp(widget.email, _controller.text);
        next = ResetPasswordPage(email: widget.email);
      }
      navigator.pushReplacement(MaterialPageRoute<void>(builder: (_) => next));
    } on AuthFailure catch (e) {
      if (!mounted) return;
      setState(() {
        _attempts++;
        _error = e.message;
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final code = _controller.text;
    final registration = widget.purpose == OtpPurpose.registration;
    return AuthPage(
      title: 'Verifikasi email',
      children: [
        AuthHero(
          heading: 'Periksa kotak masuk',
          subtitle: 'Kode 6 digit telah dikirim ke ${widget.email}.',
        ),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StatusBadge(
                registration ? 'Pendaftaran akun' : 'Pemulihan password',
              ),
              const SizedBox(height: 16),
              Text(
                'Masukkan kode verifikasi',
                style: SiagaText.bodyLarge.copyWith(
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: _focus.requestFocus,
                child: Stack(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        for (var i = 0; i < _length; i++)
                          _OtpBox(
                            char: i < code.length ? code[i] : '',
                            active:
                                i == code.length && _focus.hasFocus ||
                                (i == code.length && code.length < _length),
                          ),
                      ],
                    ),
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0,
                        child: TextField(
                          controller: _controller,
                          focusNode: _focus,
                          keyboardType: TextInputType.number,
                          maxLength: _length,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: (_) => setState(() => _error = null),
                          decoration: const InputDecoration(counterText: ''),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(
                _remaining > 0
                    ? 'Kode berlaku selama ${_mmss(_remaining)}'
                    : 'Kode telah kedaluwarsa',
                style: SiagaText.caption.copyWith(fontWeight: FontWeight.w400),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: SiagaText.bodyMuted.copyWith(
                    color: SiagaColors.dangerText,
                  ),
                ),
              ],
              const SizedBox(height: 14),
              SiagaButton.gold(
                label: _busy ? 'Memverifikasi...' : 'Verifikasi email',
                onPressed: _busy ? null : _verify,
              ),
              const SizedBox(height: 14),
              Center(
                child: _resendIn > 0
                    ? Text(
                        'Kirim ulang tersedia dalam ${_mmss(_resendIn)}',
                        style: SiagaText.bodyMuted,
                      )
                    : SiagaTextLink(label: 'Kirim ulang kode', onTap: _resend),
              ),
            ],
          ),
        ),
        Text(
          'Untuk pemulihan password, kode membawa Anda ke halaman Atur Ulang Password setelah terverifikasi.',
          textAlign: TextAlign.center,
          style: SiagaText.body.copyWith(fontSize: 13),
        ),
        SiagaButton.ghost(
          label: 'Ubah alamat email',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ],
    );
  }
}

class _OtpBox extends StatelessWidget {
  const _OtpBox({required this.char, required this.active});

  final String char;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: SiagaColors.pureWhite.withValues(
          alpha: char.isEmpty ? 0.07 : 0.12,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: active
              ? SiagaColors.padiGold
              : SiagaColors.pureWhite.withValues(alpha: 0.12),
          width: active ? 1.8 : 1,
        ),
      ),
      child: Text(
        char,
        style: SiagaText.heading1.copyWith(
          fontFeatures: SiagaText.tabular,
          color: SiagaColors.pureWhite,
        ),
      ),
    );
  }
}
