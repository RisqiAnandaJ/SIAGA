import 'package:flutter/material.dart';

import '../../core/state/session.dart';
import '../../core/theme/siaga_colors.dart';
import '../../core/theme/siaga_text.dart';
import '../../core/widgets/charts.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/list_rows.dart';
import '../../core/widgets/page_scaffolds.dart';
import '../../core/widgets/siaga_buttons.dart';
import '../../core/widgets/siaga_pills.dart';
import 'announcement_page.dart';

const List<ComparePoint> weeklyAttendance = [
  ComparePoint('Sen', 86, 90),
  ComparePoint('Sel', 92, 90),
  ComparePoint('Rab', 88, 90),
  ComparePoint('Kam', 96, 90),
  ComparePoint('Jum', 92, 90),
  ComparePoint('Sab', 99, 90),
  ComparePoint('Min', 90, 90),
];

/// Dashboard PIC PAMDAL: ringkasan operasional dan hal yang perlu perhatian.
class PicDashboardPage extends StatelessWidget {
  const PicDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final session = SessionScope.read(context);
    return MainPage(
      title: 'Kendali operasional',
      subtitle: 'Rina Wulandari • Jumat, 23 Oktober 2026',
      children: [
        const StatGrid(
          tiles: [
            StatTile(
              value: '7 / 20',
              label: 'Hadir hari ini',
              caption: '7 personel shift pagi',
            ),
            StatTile(
              value: '4',
              label: 'Patroli aktif',
              caption: 'MQTT terhubung',
            ),
            StatTile(
              value: '3',
              label: 'Insiden terbuka',
              caption: '1 prioritas tinggi',
            ),
            StatTile(
              value: '38 / 40',
              label: 'Checkpoint tercapai',
              caption: '95% target harian',
            ),
          ],
        ),
        const SectionCard(
          title: 'Kehadiran pekan ini',
          children: [
            CompareColumnChart(
              data: weeklyAttendance,
              primaryLabel: 'Hadir',
              secondaryLabel: 'Target',
            ),
            SizedBox(height: 6),
            _Footnote('Rata-rata 90% • 19–25 Oktober 2026'),
          ],
        ),
        SectionCard(
          title: 'Patroli & insiden',
          children: [
            const InfoRow(
              title: 'Kepatuhan patroli 94%',
              subtitle: 'Naik 4% dari bulan sebelumnya',
              trailing: StatusPill('Baik', tone: PillTone.success),
            ),
            InfoRow(
              title: '12 insiden bulan ini',
              subtitle: '9 selesai • 2 ditangani • 1 terbuka',
              chevron: true,
              onTap: () => session.selectTab(2),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 14),
              child: _Footnote(
                'Keselamatan 5 • Fasilitas 4 • Keamanan 3',
                plain: true,
              ),
            ),
          ],
        ),
        SectionCard(
          title: 'Perlu perhatian',
          tone: GlassTone.gold,
          children: [
            InfoRow(
              title: '3 pengajuan akun',
              subtitle: 'Email terverifikasi • menunggu peninjauan',
              trailing: const StatusPill('Tinjau', tone: PillTone.warning),
              onTap: () => session.selectTab(3),
            ),
            const InfoRow(
              title: '1 checkpoint terlewat',
              subtitle: 'Agus Setiawan • sesi 07.05',
              trailing: StatusPill('Periksa', tone: PillTone.danger),
              last: true,
            ),
          ],
        ),
        SiagaButton.ghost(
          label: 'Kelola pengumuman',
          icon: Icons.campaign_outlined,
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const AnnouncementPage()),
          ),
        ),
        const _Footnote('Data ilustratif • sinkron terakhir 07.42 WIB'),
      ],
    );
  }
}

class _Footnote extends StatelessWidget {
  const _Footnote(this.text, {this.plain = false});

  final String text;
  final bool plain;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: SiagaText.bodyMuted.copyWith(
        fontSize: 12.5,
        color: plain ? SiagaColors.silverMist : null,
      ),
    );
  }
}
