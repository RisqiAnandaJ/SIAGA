import 'package:flutter/material.dart';

import '../../core/theme/siaga_colors.dart';
import '../../core/theme/siaga_text.dart';
import '../../core/widgets/charts.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/list_rows.dart';
import '../../core/widgets/page_scaffolds.dart';
import '../../core/widgets/siaga_fields.dart';
import '../../core/widgets/siaga_pills.dart';

const List<ComparePoint> monthlyAttendance = [
  ComparePoint('01', 88, 86),
  ComparePoint('04', 96, 88),
  ComparePoint('07', 90, 90),
  ComparePoint('10', 99, 92),
  ComparePoint('13', 95, 88),
  ComparePoint('17', 102, 90),
  ComparePoint('23', 94, 86),
];

/// Pita "hanya baca" untuk peran Pimpinan.
class ReadOnlyBadge extends StatelessWidget {
  const ReadOnlyBadge(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: StatusPill(text, tone: PillTone.warning),
  );
}

/// Ringkasan eksekutif Pimpinan (hanya baca).
class ExecutiveSummaryPage extends StatelessWidget {
  const ExecutiveSummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MainPage(
      title: 'Ringkasan eksekutif',
      subtitle: 'Ratna Kusuma • 1–23 Oktober 2026',
      children: [
        const ReadOnlyBadge('Akses pemantauan • hanya baca'),
        const StatGrid(
          tiles: [
            StatTile(
              value: '96,2%',
              label: 'Kehadiran',
              caption: '↑ 2,4% bulan ini',
            ),
            StatTile(
              value: '94%',
              label: 'Kepatuhan patroli',
              caption: '↑ 4% bulan ini',
            ),
            StatTile(
              value: '3',
              label: 'Insiden terbuka',
              caption: '2 sedang ditangani',
            ),
            StatTile(
              value: '38 / 40',
              label: 'Checkpoint tercapai',
              caption: '95% target harian',
            ),
          ],
        ),
        const SectionCard(
          title: 'Evaluasi kehadiran bulanan',
          children: [
            CompareColumnChart(
              data: monthlyAttendance,
              primaryLabel: 'Bulan ini',
              secondaryLabel: 'Bulan lalu',
            ),
            SizedBox(height: 6),
            Text(
              'Kehadiran 96,2% • Oktober 2026',
              style: TextStyle(fontSize: 13.5, color: Color(0xFFE2E8F0)),
            ),
          ],
        ),
        SectionCard(
          title: 'Kepatuhan patroli',
          children: [
            Text(
              '94%',
              style: SiagaText.displayLarge.copyWith(
                fontSize: 38,
                color: SiagaColors.warmAmber,
              ),
            ),
            const SizedBox(height: 14),
            const SiagaProgress(value: 0.94),
            const SizedBox(height: 14),
            Text('Target 95% • naik 4% dari September', style: SiagaText.body),
            const SizedBox(height: 14),
            const InfoRow(
              title: '38 dari 40 checkpoint',
              subtitle: 'Tercapai hari ini • 4 sesi masih aktif',
              trailing: StatusPill('95%', tone: PillTone.success),
              last: true,
            ),
          ],
        ),
        const SectionCard(
          title: 'Kategori insiden bulan ini',
          children: [
            CategoryBar(
              label: 'Keselamatan',
              value: 5,
              max: 5,
              color: SiagaColors.padiGold,
            ),
            CategoryBar(
              label: 'Fasilitas',
              value: 4,
              max: 5,
              color: SiagaColors.kapasEmerald,
            ),
            CategoryBar(
              label: 'Keamanan',
              value: 3,
              max: 5,
              color: SiagaColors.cyanGlass,
            ),
            SizedBox(height: 10),
            Text(
              '12 laporan • 9 selesai • 3 belum selesai',
              style: TextStyle(fontSize: 13.5, color: Color(0xFFE2E8F0)),
            ),
          ],
        ),
        Text(
          'Seluruh angka merupakan data ilustratif.',
          style: SiagaText.bodyMuted.copyWith(
            color: SiagaColors.silverMist,
            fontSize: 12.5,
          ),
        ),
      ],
    );
  }
}

/// Monitoring personel (hanya baca): absensi, jadwal, patroli, personel.
class MonitoringPage extends StatefulWidget {
  const MonitoringPage({super.key});

  @override
  State<MonitoringPage> createState() => _MonitoringPageState();
}

class _MonitoringPageState extends State<MonitoringPage> {
  int _tab = 0;
  String _query = '';

  static const _people = [
    (
      'Budi Santoso',
      '06.54 • Pos utama • Shift pagi',
      'Hadir',
      PillTone.success,
    ),
    (
      'Agus Setiawan',
      '06.58 • Gedung utama • Shift pagi',
      'Hadir',
      PillTone.success,
    ),
    (
      'Siti Rahma',
      '07.09 • Area parkir • Shift pagi',
      'Terlambat',
      PillTone.warning,
    ),
    ('Hendra Wijaya', 'Shift sore mulai 15.00', 'Belum', PillTone.neutral),
  ];

  @override
  Widget build(BuildContext context) {
    final q = _query.trim().toLowerCase();
    final people = _people
        .where((p) => q.isEmpty || p.$1.toLowerCase().contains(q))
        .toList();
    return MainPage(
      title: 'Monitoring personel',
      subtitle: 'Seluruh personel • 23 Oktober 2026',
      children: [
        PillTabs(
          labels: const ['Absensi', 'Jadwal', 'Patroli', 'Personel'],
          index: _tab,
          onChanged: (i) => setState(() => _tab = i),
        ),
        const ReadOnlyBadge('Hanya baca • tanpa perubahan data'),
        if (_tab == 0) ...[
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kehadiran hari ini',
                  style: SiagaText.heading2.copyWith(fontSize: 20),
                ),
                const SizedBox(height: 14),
                Text(
                  '7 / 20 hadir',
                  style: SiagaText.displayLarge.copyWith(fontSize: 36),
                ),
                const SizedBox(height: 12),
                Text(
                  '1 terlambat • 13 menunggu shift berikutnya',
                  style: SiagaText.body.copyWith(fontSize: 13.5),
                ),
              ],
            ),
          ),
          GlassField(
            label: 'Cari personel',
            hint: 'Nama atau username',
            icon: Icons.search,
            onChanged: (v) => setState(() => _query = v),
          ),
          SectionCard(
            title: 'Seluruh personel',
            children: [
              for (var i = 0; i < people.length; i++)
                InfoRow(
                  title: people[i].$1,
                  subtitle: people[i].$2,
                  trailing: StatusPill(people[i].$3, tone: people[i].$4),
                  last: i == people.length - 1 && q.isNotEmpty,
                ),
              if (q.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: Text(
                    'Tampilkan 16 personel lainnya →',
                    style: SiagaText.body.copyWith(fontSize: 13.5),
                  ),
                ),
            ],
          ),
          const SectionCard(
            title: 'Detail • Budi Santoso',
            children: [
              InfoRow(
                title: 'PAMDAL • aktif',
                subtitle: 'budi@example.com • akun terverifikasi',
                chevron: true,
              ),
              InfoRow(
                title: 'Jadwal 07.00–15.00',
                subtitle: 'Check-in 06.54 • GPS tervalidasi',
                chevron: true,
              ),
              InfoRow(
                title: 'Patroli area utama',
                subtitle: 'Aktif 00:30:18 • 3/4 checkpoint',
                trailing: StatusPill('Online', tone: PillTone.success),
                last: true,
              ),
            ],
          ),
        ] else if (_tab == 1)
          const SectionCard(
            title: 'Jadwal hari ini',
            children: [
              InfoRow(
                title: '07.00–15.00 • Pagi',
                subtitle: '7 personel • sedang berlangsung',
                trailing: StatusPill('Aktif', tone: PillTone.warning),
              ),
              InfoRow(
                title: '15.00–23.00 • Sore',
                subtitle: '7 personel • Hendra Wijaya koordinator',
              ),
              InfoRow(
                title: '23.00–07.00 • Malam',
                subtitle: '6 personel • Fajar Nugroho koordinator',
                last: true,
              ),
            ],
          )
        else if (_tab == 2)
          const SectionCard(
            title: 'Sesi patroli aktif',
            children: [
              InfoRow(
                title: 'Budi Santoso',
                subtitle: '07.12 • 00:30:18 • 3/4 checkpoint',
                trailing: StatusPill('Online', tone: PillTone.success),
              ),
              InfoRow(
                title: 'Agus Setiawan',
                subtitle: '07.05 • 00:37:18 • 2/4 checkpoint',
                trailing: StatusPill('1 terlewat', tone: PillTone.danger),
              ),
              InfoRow(
                title: 'Siti Rahma',
                subtitle: '07.20 • 00:22:18 • 2/4 checkpoint',
                trailing: StatusPill('Online', tone: PillTone.success),
                last: true,
              ),
            ],
          )
        else
          const SectionCard(
            title: 'Ringkasan personel',
            children: [
              InfoRow(title: '20 PAMDAL', subtitle: 'Seluruhnya aktif'),
              InfoRow(title: '2 PIC PAMDAL', subtitle: 'Pengelola operasional'),
              InfoRow(
                title: '2 Pimpinan',
                subtitle: 'Akses pemantauan',
                last: true,
              ),
            ],
          ),
        Text(
          'Pilih Jadwal, Patroli, atau Personel untuk subview pemantauan lainnya.',
          style: SiagaText.bodyMuted.copyWith(
            color: SiagaColors.silverMist,
            fontSize: 12.5,
          ),
        ),
      ],
    );
  }
}
