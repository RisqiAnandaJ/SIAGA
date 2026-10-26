import 'package:flutter/material.dart';

import '../../core/navigation/auth_router.dart';
import '../../core/state/session.dart';
import '../../core/theme/siaga_colors.dart';
import '../../core/utils/phone.dart';
import '../../core/theme/siaga_text.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/list_rows.dart';
import '../../core/widgets/page_scaffolds.dart';
import '../../core/widgets/siaga_buttons.dart';
import '../../core/widgets/siaga_pills.dart';
import '../auth/reset_password_page.dart';

/// Profil dan pengaturan pribadi.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final session = SessionScope.of(context);
    final role = session.role ?? UserRole.pamdal;
    final profile = session.profile;
    final name = session.displayName;
    final username = profile?.username ?? role.demoUsername;
    final email = profile?.email ?? role.demoEmail;
    final phone = maskPhone(profile?.phone ?? '+62 • kontak disamarkan');
    final initials = name
        .split(' ')
        .where((p) => p.isNotEmpty)
        .map((p) => p[0])
        .take(2)
        .join()
        .toUpperCase();
    final navigator = Navigator.of(context);

    return MainPage(
      title: 'Profil & pengaturan',
      subtitle: 'Kelola preferensi pribadi Anda',
      showDock: true,
      dockIndex: 0,
      showBack: true,
      children: [
        GlassCard(
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: SiagaColors.pureWhite.withValues(alpha: 0.12),
                    ),
                    child: Text(
                      initials,
                      style: SiagaText.heading1.copyWith(
                        color: SiagaColors.warmAmber,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: SiagaText.heading1.copyWith(
                            color: SiagaColors.silverMist,
                          ),
                        ),
                        const SizedBox(height: 8),
                        StatusPill(
                          role.label,
                          tone: role.isGoldBadge
                              ? PillTone.warning
                              : PillTone.success,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              InfoRow(
                title: username,
                subtitle: 'Username',
                trailing: const Icon(Icons.person_outline, size: 22),
              ),
              InfoRow(
                title: email,
                subtitle: 'Email terverifikasi',
                trailing: const Icon(Icons.mail_outline, size: 22),
              ),
              InfoRow(
                title: phone,
                subtitle: 'Nomor handphone',
                trailing: const Icon(Icons.phone_outlined, size: 22),
                last: true,
              ),
            ],
          ),
        ),
        SectionCard(
          title: 'Tampilan aplikasi',
          children: [
            PillTabs(
              labels: const ['Spatial Navy', 'Daylight Pearl'],
              index: session.themeMode.index,
              onChanged: (i) => session.setThemeMode(SiagaThemeMode.values[i]),
              height: 54,
            ),
            const SizedBox(height: 14),
            Text(
              'Spatial Navy untuk pemantauan nyaman. Daylight Pearl meningkatkan keterbacaan saat bertugas di luar ruangan.',
              style: SiagaText.body.copyWith(fontSize: 13),
            ),
          ],
        ),
        SectionCard(
          title: 'Keamanan & aplikasi',
          children: [
            InfoRow(
              title: 'Ubah password',
              subtitle: 'Jaga keamanan akses akun',
              trailing: const Icon(Icons.lock_outline, size: 22),
              onTap: () => navigator.push(
                MaterialPageRoute<void>(
                  builder: (_) =>
                      ResetPasswordPage(email: email, signOutAfter: false),
                ),
              ),
            ),
            InfoRow(
              title: 'Izin lokasi',
              subtitle: 'Aktif selama patroli berlangsung',
              trailing: const Icon(Icons.location_on_outlined, size: 22),
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Kelola izin lokasi melalui pengaturan perangkat.',
                  ),
                ),
              ),
            ),
            InfoRow(
              title: 'Tentang SIAGA',
              subtitle: 'BPSDM Kementerian Dalam Negeri • v1.0',
              chevron: true,
              last: true,
              onTap: () => showAboutDialog(
                context: context,
                applicationName: 'SIAGA',
                applicationVersion: '1.0',
                applicationLegalese: 'BPSDM Kementerian Dalam Negeri',
              ),
            ),
          ],
        ),
        SiagaButton.ghost(
          label: 'Keluar',
          onPressed: () async {
            await session.signOut();
            if (context.mounted) openLogin(context);
          },
        ),
      ],
    );
  }
}
