import 'package:flutter/material.dart';

import '../../core/theme/siaga_text.dart';
import '../../core/widgets/list_rows.dart';
import '../../core/widgets/mini_map.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/siaga_buttons.dart';
import '../../core/widgets/siaga_pills.dart';
import 'checkpoint_page.dart';

/// Pantau patroli: sesi aktif, telemetri, dan tautan kelola checkpoint.
class PicPatrolSection extends StatefulWidget {
  const PicPatrolSection({super.key});

  @override
  State<PicPatrolSection> createState() => _PicPatrolSectionState();
}

class _PicPatrolSectionState extends State<PicPatrolSection> {
  int _selected = 0;

  static const _sessions = [
    (
      'Budi Santoso',
      '07.12 • 00:30:18 • 3/4 checkpoint',
      'Online',
      PillTone.success,
    ),
    (
      'Agus Setiawan',
      '07.05 • 00:37:18 • 2/4 checkpoint',
      '1 terlewat',
      PillTone.danger,
    ),
    (
      'Siti Rahma',
      '07.20 • 00:22:18 • 2/4 checkpoint',
      'Online',
      PillTone.success,
    ),
    (
      'Luki Saputra',
      '07.25 • 00:17:18 • 1/4 checkpoint',
      'Antrean 5',
      PillTone.warning,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final name = _sessions[_selected].$1;
    return SpacedColumn(
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: StatusPill(
            'MQTT Online • telemetri tersambung',
            tone: PillTone.success,
          ),
        ),
        const MiniMap(),
        Text(
          'Jalur dan posisi berupa skema, bukan geografi terukur.',
          style: SiagaText.bodyMuted.copyWith(fontSize: 12.5),
        ),
        SectionCard(
          title: 'Seluruh sesi aktif',
          children: [
            for (var i = 0; i < _sessions.length; i++)
              InfoRow(
                title: _sessions[i].$1,
                subtitle: _sessions[i].$2,
                trailing: StatusPill(_sessions[i].$3, tone: _sessions[i].$4),
                onTap: () => setState(() => _selected = i),
                last: i == _sessions.length - 1,
              ),
          ],
        ),
        SectionCard(
          title: 'Telemetri • $name',
          children: [
            Text(
              'Akurasi ±8 m • titik terakhir 07.42 WIB\n−6.2744, 106.8455',
              style: SiagaText.bodyLarge.copyWith(fontWeight: FontWeight.w400),
            ),
            const SizedBox(height: 8),
            const InfoRow(
              title: 'Area parkir terverifikasi',
              subtitle: '07.42 • radius 20 m • checkpoint 3/4',
              trailing: StatusPill('Valid', tone: PillTone.success),
              last: true,
            ),
          ],
        ),
        SiagaButton.ghost(
          label: 'Kelola checkpoint',
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const CheckpointPage()),
          ),
        ),
        const InfoBanner(
          title: 'Sesi offline tetap tercatat',
          body:
              'Luki Saputra memiliki 5 titik dalam antrean. Sinkron otomatis saat koneksi tersedia.',
        ),
      ],
    );
  }
}
