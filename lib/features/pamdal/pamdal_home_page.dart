import 'package:flutter/material.dart';

import '../../core/state/session.dart';
import '../../core/theme/siaga_colors.dart';
import '../../core/theme/siaga_text.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/list_rows.dart';
import '../../core/widgets/page_scaffolds.dart';
import '../../core/widgets/siaga_buttons.dart';
import '../../core/widgets/siaga_pills.dart';

/// Beranda PAMDAL: ringkasan shift dan patroli milik sendiri.
class PamdalHomePage extends StatelessWidget {
  const PamdalHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final session = SessionScope.of(context);
    return MainPage(
      title: 'Selamat pagi, ${session.profile?.firstName ?? 'Budi'}',
      subtitle: 'Jumat, 23 Oktober 2026 • data ilustratif',
      children: [
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Siap menjaga hari ini',
                style: SiagaText.heading2.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 14),
              const StatusPill('Shift pagi aktif', tone: PillTone.success),
              const SizedBox(height: 16),
              Text(
                '07.00 — 15.00',
                style: SiagaText.displayLarge.copyWith(fontSize: 34),
              ),
              const SizedBox(height: 12),
              Text(
                'Pos utama • Gedung BPSDM',
                style: SiagaText.body.copyWith(fontSize: 14.5),
              ),
              const SizedBox(height: 18),
              InfoRow(
                title: 'Anda sudah check-in',
                subtitle: '06.54 WIB • GPS tervalidasi',
                trailing: const StatusPill('Hadir', tone: PillTone.success),
                last: true,
              ),
              const SizedBox(height: 4),
              SiagaButton.ghost(
                label: 'Lihat absensi & jadwal',
                onPressed: () => session.selectTab(1),
              ),
            ],
          ),
        ),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Patroli saya hari ini',
                style: SiagaText.heading2.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '01 sesi',
                    style: SiagaText.displayLarge.copyWith(fontSize: 30),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 24),
                    child: Text(
                      '3 / 4',
                      style: SiagaText.displayLarge.copyWith(fontSize: 30),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Sesi berlangsung • checkpoint terverifikasi',
                style: SiagaText.body.copyWith(fontSize: 13.5),
              ),
              const SizedBox(height: 14),
              InfoRow(
                title: 'Patroli area utama',
                subtitle: 'Mulai 07.12 • durasi 00:30:18',
                trailing: const StatusPill('Aktif', tone: PillTone.success),
                last: true,
              ),
              const SizedBox(height: 4),
              SiagaButton.gold(
                label: 'Lanjutkan patroli',
                onPressed: () => session.selectTab(2),
              ),
            ],
          ),
        ),
        const InfoBanner(
          title: 'Pengumuman operasional',
          body:
              'Pemeriksaan akses tamu diperketat. Pastikan identitas dan buku kunjungan terisi lengkap.',
        ),
        Text(
          'Ringkasan hanya menampilkan aktivitas Anda sendiri.',
          style: SiagaText.bodyMuted.copyWith(
            color: SiagaColors.silverMist,
            fontSize: 12.5,
          ),
        ),
      ],
    );
  }
}
