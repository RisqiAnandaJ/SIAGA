import 'package:flutter/material.dart';

import '../../core/theme/siaga_text.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/list_rows.dart';
import '../../core/widgets/page_scaffolds.dart';
import '../../core/widgets/siaga_pills.dart';

/// Riwayat dan detail patroli milik sendiri.
class PatrolHistoryPage extends StatefulWidget {
  const PatrolHistoryPage({super.key});

  @override
  State<PatrolHistoryPage> createState() => _PatrolHistoryPageState();
}

class _PatrolHistoryPageState extends State<PatrolHistoryPage> {
  int _range = 0;

  @override
  Widget build(BuildContext context) {
    return MainPage(
      title: 'Riwayat patroli saya',
      subtitle: 'Hanya sesi milik Budi Santoso',
      showDock: true,
      dockIndex: 2,
      showBack: true,
      children: [
        PillTabs(
          labels: const ['Hari ini', '7 hari', 'Bulan ini'],
          index: _range,
          onChanged: (i) => setState(() => _range = i),
        ),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sesi terpilih',
                style: SiagaText.heading2.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 14),
              const StatusPill('Sedang berlangsung', tone: PillTone.success),
              const SizedBox(height: 14),
              Text(
                'Patroli area utama',
                style: SiagaText.heading1.copyWith(fontSize: 26),
              ),
              const SizedBox(height: 12),
              Text(
                '23 Oktober 2026 • 07.12–sekarang',
                style: SiagaText.body.copyWith(fontSize: 14.5),
              ),
              const SizedBox(height: 14),
              Text(
                '00:30:18',
                style: SiagaText.displayLarge.copyWith(fontSize: 44),
              ),
              const SizedBox(height: 12),
              Text(
                '3 / 4 checkpoint • akurasi GPS ±8 m',
                style: SiagaText.body.copyWith(fontSize: 13.5),
              ),
            ],
          ),
        ),
        const SectionCard(
          title: 'Checkpoint sesi ini',
          children: [
            InfoRow(
              title: 'Gerbang utama',
              subtitle: '07.12 • 00:00 • −6.2739, 106.8450',
              trailing: StatusPill('Terverifikasi', tone: PillTone.success),
            ),
            InfoRow(
              title: 'Gedung utama',
              subtitle: '07.26 • 00:14 • −6.2741, 106.8452',
              trailing: StatusPill('Terverifikasi', tone: PillTone.success),
            ),
            InfoRow(
              title: 'Area parkir',
              subtitle: '07.42 • 00:30 • −6.2744, 106.8455',
              trailing: StatusPill('Terverifikasi', tone: PillTone.success),
            ),
            InfoRow(
              title: 'Pos belakang',
              subtitle: 'Target berikutnya • radius 20 m',
              trailing: StatusPill('Menunggu'),
              last: true,
            ),
          ],
        ),
        const SectionCard(
          title: 'Sesi sebelumnya',
          children: [
            InfoRow(
              title: '22 Oktober • Area utama',
              subtitle: '07.10–07.54 • durasi 00:44:00',
              trailing: StatusPill('4 / 4', tone: PillTone.success),
            ),
            InfoRow(
              title: '21 Oktober • Area utama',
              subtitle: '07.11–07.56 • durasi 00:45:00',
              trailing: StatusPill('4 / 4', tone: PillTone.success),
              last: true,
            ),
          ],
        ),
      ],
    );
  }
}
