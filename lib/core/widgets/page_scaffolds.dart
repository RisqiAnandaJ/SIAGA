import 'package:flutter/material.dart';

import '../../features/shared/notification_page.dart';
import '../../features/shared/profile_page.dart';
import '../../features/shared/sos_page.dart';
import '../state/session.dart';
import '../theme/siaga_colors.dart';
import '../theme/siaga_text.dart';
import 'app_background.dart';
import 'siaga_dock.dart';
import 'siaga_logo.dart';
import 'siaga_pills.dart';

/// Halaman utama berperan: header (lencana peran, lonceng, profil, SOS),
/// judul, lalu isi yang dapat digulir. [showDock] untuk halaman yang dibuka
/// di atas shell (notifikasi, profil, detail).
class MainPage extends StatelessWidget {
  const MainPage({
    super.key,
    required this.title,
    this.subtitle,
    required this.children,
    this.showDock = false,
    this.dockIndex,
    this.showBack = false,
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;
  final bool showDock;

  /// Tab dock yang disorot saat halaman dibuka di atas shell.
  final int? dockIndex;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final session = SessionScope.of(context);
    final role = session.role ?? UserRole.pamdal;

    final page = ListView(
      padding: const EdgeInsets.fromLTRB(
        24,
        0,
        24,
        SiagaDock.reservedHeight + 12,
      ),
      children: [
        const SizedBox(height: 12),
        _Header(role: role, showBack: showBack),
        const SizedBox(height: 18),
        Text(title, style: SiagaText.heading1.copyWith(fontSize: 26)),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(subtitle!, style: SiagaText.bodyMuted),
        ],
        const SizedBox(height: 20),
        for (var i = 0; i < children.length; i++) ...[
          children[i],
          if (i < children.length - 1) const SizedBox(height: 18),
        ],
      ],
    );

    return Scaffold(
      backgroundColor: SiagaColors.abyssalNavy,
      body: AppBackground(
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              Positioned.fill(child: page),
              if (showDock)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: SiagaDock(
                    items: dockItemsFor(role),
                    index: dockIndex ?? session.tab,
                    onTap: (i) {
                      session.selectTab(i);
                      Navigator.of(context).popUntil((r) => r.isFirst);
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.role, required this.showBack});

  final UserRole role;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final navigator = Navigator.of(context);
    return Row(
      children: [
        if (showBack) ...[
          _IconButton(
            icon: Icons.arrow_back,
            label: 'Kembali',
            onTap: navigator.maybePop,
          ),
          const SizedBox(width: 8),
        ],
        RolePill(role),
        const Spacer(),
        _IconButton(
          icon: Icons.notifications_none,
          label: 'Notifikasi',
          onTap: () => navigator.push(
            MaterialPageRoute<void>(builder: (_) => const NotificationPage()),
          ),
        ),
        _IconButton(
          icon: Icons.account_circle_outlined,
          label: 'Profil',
          onTap: () => navigator.push(
            MaterialPageRoute<void>(builder: (_) => const ProfilePage()),
          ),
        ),
        const SizedBox(width: 6),
        const _SosPill(),
      ],
    );
  }
}

class RolePill extends StatelessWidget {
  const RolePill(this.role, {super.key});

  final UserRole role;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: role.badgeColor.withValues(
          alpha: role.isGoldBadge ? 0.22 : 0.35,
        ),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        role.label,
        style: SiagaText.caption.copyWith(
          fontWeight: FontWeight.w500,
          color: role.isGoldBadge
              ? SiagaColors.warmAmber
              : SiagaColors.successText,
        ),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: InkResponse(
        onTap: onTap,
        radius: 24,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, size: 24, color: SiagaColors.pureWhite),
        ),
      ),
    );
  }
}

class _SosPill extends StatelessWidget {
  const _SosPill();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Darurat SOS',
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(
          PageRouteBuilder<void>(
            opaque: true,
            transitionDuration: const Duration(milliseconds: 220),
            pageBuilder: (_, _, _) => const SosPage(),
            transitionsBuilder: (_, a, _, child) =>
                FadeTransition(opacity: a, child: child),
          ),
        ),
        child: Container(
          height: 36,
          constraints: const BoxConstraints(minWidth: 52),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: SiagaColors.garudaCrimson,
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: SiagaColors.garudaCrimson.withValues(alpha: 0.55),
                blurRadius: 14,
              ),
            ],
          ),
          child: const Text(
            'SOS',
            style: TextStyle(
              color: SiagaColors.pureWhite,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

/// Halaman auth: eyebrow "SIAGA / AKUN" dengan tombol kembali, judul, isi.
class AuthPage extends StatelessWidget {
  const AuthPage({
    super.key,
    this.eyebrow = 'SIAGA / AKUN',
    this.title,
    required this.children,
    this.showBack = true,
  });

  final String eyebrow;
  final String? title;
  final List<Widget> children;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SiagaColors.abyssalNavy,
      body: AppBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
            children: [
              Row(
                children: [
                  Text(eyebrow, style: SiagaText.eyebrow),
                  const Spacer(),
                  if (showBack)
                    InkResponse(
                      onTap: Navigator.of(context).maybePop,
                      radius: 24,
                      child: const SizedBox(
                        width: 44,
                        height: 36,
                        child: Icon(
                          Icons.arrow_back,
                          size: 24,
                          color: SiagaColors.pureWhite,
                        ),
                      ),
                    ),
                ],
              ),
              if (title != null) ...[
                const SizedBox(height: 14),
                Text(title!, style: SiagaText.heading1.copyWith(fontSize: 26)),
              ],
              const SizedBox(height: 16),
              for (var i = 0; i < children.length; i++) ...[
                children[i],
                if (i < children.length - 1) const SizedBox(height: 18),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Logo, judul tengah, dan subjudul pada layar auth.
class AuthHero extends StatelessWidget {
  const AuthHero({
    super.key,
    required this.heading,
    this.subtitle,
    this.logo = 84,
  });

  final String heading;
  final String? subtitle;
  final double logo;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SiagaLogo(height: logo),
        const SizedBox(height: 22),
        Text(
          heading,
          textAlign: TextAlign.center,
          style: SiagaText.heading1.copyWith(
            fontSize: 28,
            color: SiagaColors.silverMist,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 12),
          Text(
            subtitle!,
            textAlign: TextAlign.center,
            style: SiagaText.body.copyWith(fontSize: 14.5),
          ),
        ],
      ],
    );
  }
}

/// Lencana kecil di dalam kartu status auth ("Menunggu peninjauan").
class StatusBadge extends StatelessWidget {
  const StatusBadge(this.label, {super.key, this.tone = PillTone.warning});

  final String label;
  final PillTone tone;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: StatusPill(label, tone: tone),
  );
}

/// Logo kecil dipakai pada pratinjau PDF.
class PdfLogo extends StatelessWidget {
  const PdfLogo({super.key});

  @override
  Widget build(BuildContext context) => const SiagaLogo(height: 66);
}
