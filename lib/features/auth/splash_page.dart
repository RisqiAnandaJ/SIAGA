import 'package:flutter/material.dart';

import '../../core/navigation/auth_router.dart';
import '../../core/services/auth_repository.dart';
import '../../core/state/session.dart';
import '../../core/theme/siaga_colors.dart';
import '../../models/profile.dart';
import '../../core/theme/siaga_text.dart';
import '../../core/widgets/app_background.dart';
import '../../core/widgets/siaga_logo.dart';
import 'login_page.dart';

/// Layar pembuka: memeriksa sesi lalu menuju layar masuk.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progress = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );

  @override
  void initState() {
    super.initState();
    _start();
  }

  /// Memeriksa sesi tersimpan sambil menjalankan animasi, lalu menuju layar
  /// yang sesuai (beranda berperan, layar status akun, atau masuk).
  Future<void> _start() async {
    final session = SessionScope.read(context);
    final animation = _progress.forward();
    Profile? profile;
    try {
      profile = await session.auth.restoreSession();
    } on AuthFailure {
      profile = null; // Gagal memulihkan sesi: minta masuk ulang.
    }
    await animation;
    if (!mounted) return;
    final Widget next = profile == null
        ? const LoginPage()
        : screenForProfile(context, profile);
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, _, _) => next,
        transitionsBuilder: (_, a, _, child) =>
            FadeTransition(opacity: a, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const Spacer(flex: 3),
                const SiagaLogo(height: 168),
                const SizedBox(height: 32),
                Text(
                  'SIAGA',
                  style: SiagaText.displayLarge.copyWith(
                    fontSize: 44,
                    color: SiagaColors.pureWhite,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'BPSDM Kementerian Dalam Negeri',
                  textAlign: TextAlign.center,
                  style: SiagaText.heading2.copyWith(fontSize: 17),
                ),
                const SizedBox(height: 28),
                Text(
                  'Terhubung dalam tugas.\nSigap dalam penjagaan.',
                  textAlign: TextAlign.center,
                  style: SiagaText.body.copyWith(fontSize: 16, height: 1.5),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: 220,
                  child: AnimatedBuilder(
                    animation: _progress,
                    builder: (_, _) => ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: _progress.value,
                        minHeight: 5,
                        color: SiagaColors.padiGold,
                        backgroundColor: SiagaColors.pureWhite.withValues(
                          alpha: 0.12,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text('Memeriksa sesi Anda...', style: SiagaText.bodyMuted),
                const Spacer(flex: 3),
                Text(
                  'Lingkungan demonstrasi • versi 1.0',
                  style: SiagaText.bodyMuted.copyWith(fontSize: 12),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
