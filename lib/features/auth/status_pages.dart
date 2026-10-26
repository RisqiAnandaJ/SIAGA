import 'package:flutter/material.dart';

import '../../core/navigation/auth_router.dart';
import '../../core/state/session.dart';
import '../../core/theme/siaga_text.dart';
import '../../core/utils/id_date.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/list_rows.dart';
import '../../core/widgets/page_scaffolds.dart';
import '../../core/widgets/siaga_buttons.dart';
import '../../core/widgets/siaga_pills.dart';

Future<void> _signOut(BuildContext context) async {
  await SessionScope.read(context).signOut();
  if (context.mounted) openLogin(context);
}

/// Menunggu persetujuan PIC PAMDAL; modul lain terkunci.
class PendingApprovalPage extends StatelessWidget {
  const PendingApprovalPage({
    super.key,
    this.name = '',
    this.email = '',
    this.requestedRole = 'PAMDAL',
    this.submittedAt,
  });

  final String name;
  final String email;
  final String requestedRole;
  final DateTime? submittedAt;

  @override
  Widget build(BuildContext context) {
    final when = submittedAt == null
        ? ''
        : ' • ${formatShortDateTime(submittedAt!)}';
    return AuthPage(
      title: 'Pengajuan terkirim',
      children: [
        AuthHero(
          heading: 'Menunggu persetujuan PIC PAMDAL',
          subtitle:
              'Terima kasih${name.isEmpty ? '' : ', $name'}. Pengajuan Anda sedang ditinjau.',
        ),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const StatusBadge('Menunggu peninjauan'),
              const SizedBox(height: 6),
              InfoRow(
                title: 'Email terverifikasi',
                subtitle: email,
                trailing: const StatusPill('Selesai', tone: PillTone.success),
              ),
              InfoRow(
                title: 'Peran diajukan',
                subtitle: '$requestedRole$when',
                chevron: true,
              ),
              const InfoRow(
                title: 'Akses modul terkunci',
                subtitle: 'Aktif setelah PIC menyetujui akun',
                trailing: Icon(Icons.lock_outline, size: 22),
                last: true,
              ),
            ],
          ),
        ),
        const InfoBanner(
          title: 'Kami akan memberi kabar',
          body: 'Hasil peninjauan dikirim melalui email dan notifikasi akun.',
        ),
        SiagaButton.ghost(label: 'Keluar', onPressed: () => _signOut(context)),
      ],
    );
  }
}

/// Pendaftaran ditolak beserta alasannya.
class RegistrationRejectedPage extends StatelessWidget {
  const RegistrationRejectedPage({super.key, this.reason, this.reviewedAt});

  final String? reason;
  final DateTime? reviewedAt;

  @override
  Widget build(BuildContext context) {
    return AuthPage(
      title: 'Status pendaftaran',
      children: [
        const AuthHero(
          heading: 'Pendaftaran belum disetujui',
          subtitle: 'PIC PAMDAL telah meninjau pengajuan akun Anda.',
        ),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const StatusBadge('Pendaftaran Ditolak', tone: PillTone.danger),
              const SizedBox(height: 16),
              Text(
                'Alasan penolakan',
                style: SiagaText.heading2.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 12),
              Text(
                (reason == null || reason!.trim().isEmpty)
                    ? 'Tidak ada alasan yang dicatat. Hubungi PIC PAMDAL untuk klarifikasi.'
                    : reason!,
                style: SiagaText.bodyLarge.copyWith(
                  fontWeight: FontWeight.w400,
                ),
              ),
              if (reviewedAt != null) ...[
                const SizedBox(height: 14),
                Text(
                  'Ditinjau ${formatLongDateTime(reviewedAt!)}',
                  style: SiagaText.bodyMuted,
                ),
              ],
            ],
          ),
        ),
        const InfoBanner(
          title: 'Modul operasional tidak tersedia',
          body: 'Hubungi PIC PAMDAL untuk klarifikasi data pengajuan.',
        ),
        SiagaButton.ghost(label: 'Keluar', onPressed: () => _signOut(context)),
      ],
    );
  }
}

/// Akun dinonaktifkan oleh PIC PAMDAL.
class InactiveAccountPage extends StatelessWidget {
  const InactiveAccountPage({super.key, this.name = '', this.updatedAt});

  final String name;
  final DateTime? updatedAt;

  @override
  Widget build(BuildContext context) {
    return AuthPage(
      title: 'Status akun',
      children: [
        const AuthHero(
          heading: 'Akun Tidak Aktif',
          subtitle: 'Akses SIAGA untuk akun ini telah dinonaktifkan.',
        ),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const StatusBadge('Akses dinonaktifkan', tone: PillTone.danger),
              const SizedBox(height: 16),
              if (name.isNotEmpty) ...[
                Text(name, style: SiagaText.heading2.copyWith(fontSize: 20)),
                const SizedBox(height: 12),
              ],
              Text(
                'Seluruh modul operasional dikunci. Data riwayat tetap tersimpan sesuai kebijakan pengelolaan akun.',
                style: SiagaText.bodyLarge.copyWith(
                  fontWeight: FontWeight.w400,
                ),
              ),
              if (updatedAt != null) ...[
                const SizedBox(height: 14),
                Text(
                  'Status diperbarui PIC PAMDAL\n${formatLongDateTime(updatedAt!)}',
                  style: SiagaText.bodyMuted,
                ),
              ],
            ],
          ),
        ),
        const InfoBanner(
          title: 'Perlu bantuan?',
          body:
              'Hubungi PIC PAMDAL untuk menanyakan status penugasan dan aktivasi kembali akun.',
        ),
        SiagaButton.ghost(label: 'Keluar', onPressed: () => _signOut(context)),
      ],
    );
  }
}
