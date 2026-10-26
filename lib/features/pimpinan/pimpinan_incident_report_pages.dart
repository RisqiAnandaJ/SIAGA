import 'package:flutter/material.dart';

import '../../core/theme/siaga_colors.dart';
import '../../core/theme/siaga_text.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/list_rows.dart';
import '../../core/widgets/page_scaffolds.dart';
import '../../core/widgets/siaga_buttons.dart';
import '../../core/widgets/siaga_fields.dart';
import '../../core/widgets/siaga_pills.dart';
import '../shared/incident_widgets.dart';
import '../shared/report_preview.dart';
import 'pimpinan_pages.dart';

/// Pemantauan insiden (hanya baca).
class ExecutiveIncidentPage extends StatefulWidget {
  const ExecutiveIncidentPage({super.key});

  @override
  State<ExecutiveIncidentPage> createState() => _ExecutiveIncidentPageState();
}

class _ExecutiveIncidentPageState extends State<ExecutiveIncidentPage> {
  int _filter = 1;

  @override
  Widget build(BuildContext context) {
    return MainPage(
      title: 'Pemantauan insiden',
      subtitle: 'Seluruh laporan • dokumentasi & status terkini',
      children: [
        const ReadOnlyBadge('Hanya baca'),
        PillTabs(
          labels: const ['Terbuka', 'Dalam Penanganan', 'Selesai'],
          index: _filter,
          onChanged: (i) => setState(() => _filter = i),
          height: 52,
        ),
        GlassCard(
          child: switch (_filter) {
            0 => const _OtherReport(
              title: 'Lampu pos berkedip',
              meta: 'KJD-021 • Budi Santoso • 08.10',
              pill: StatusPill('Terbuka', tone: PillTone.danger),
            ),
            1 => const _OtherReport(
              title: 'Kunci akses perlu diperbaiki',
              meta: 'KJD-023 • Agus Setiawan • 07.05',
              pill: StatusPill('Ditangani', tone: PillTone.warning),
            ),
            _ => const _OtherReport(
              title: 'Pintu akses tidak tertutup',
              meta: 'KJD-018 • Budi Santoso • 20 Okt',
              pill: StatusPill('Selesai', tone: PillTone.success),
            ),
          },
        ),
        Text(
          'Detail terpilih • KJD-024',
          style: SiagaText.heading2.copyWith(fontSize: 22),
        ),
        const IncidentDetailCard(),
        const EvidenceCard(),
        const HandlingHistoryCard(),
        const InfoBanner(
          title: 'Pemantauan tanpa perubahan',
          body:
              'Status, catatan penanganan, dan dokumentasi dikelola PIC PAMDAL. Pimpinan dapat memantau seluruh kronologi.',
        ),
      ],
    );
  }
}

class _OtherReport extends StatelessWidget {
  const _OtherReport({
    required this.title,
    required this.meta,
    required this.pill,
  });

  final String title;
  final String meta;
  final Widget pill;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Laporan lain', style: SiagaText.heading2.copyWith(fontSize: 20)),
        const SizedBox(height: 14),
        InfoRow(title: title, subtitle: meta, trailing: pill, last: true),
      ],
    );
  }
}

/// Laporan eksekutif: periode, pratinjau, dan ekspor PDF.
class ExecutiveReportPage extends StatefulWidget {
  const ExecutiveReportPage({super.key});

  @override
  State<ExecutiveReportPage> createState() => _ExecutiveReportPageState();
}

class _ExecutiveReportPageState extends State<ExecutiveReportPage> {
  String _kind = 'Eksekutif • seluruh operasional';
  DateTimeRange _range = DateTimeRange(
    start: DateTime(2026, 10, 1),
    end: DateTime(2026, 10, 23),
  );

  Future<void> _pickRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2026, 1, 1),
      lastDate: DateTime(2026, 12, 31),
      initialDateRange: _range,
    );
    if (picked != null) setState(() => _range = picked);
  }

  String _short(DateTime d) {
    const m = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${d.day.toString().padLeft(2, '0')} ${m[d.month]}';
  }

  @override
  Widget build(BuildContext context) {
    final period = formatRange(_range);
    return MainPage(
      title: 'Laporan eksekutif',
      subtitle: 'Pratinjau dan ekspor PDF resmi',
      children: [
        SectionCard(
          title: 'Periode laporan',
          children: [
            GlassField(
              label: 'Rentang tanggal',
              initialValue: period,
              key: ValueKey(period),
              icon: Icons.calendar_month_outlined,
              readOnly: true,
              onTap: _pickRange,
            ),
            const SizedBox(height: 14),
            GlassCard(
              radius: 22,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Oktober 2026',
                    style: SiagaText.heading2.copyWith(fontSize: 20),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Awal ${_short(_range.start)} → Akhir ${_short(_range.end)}',
                    style: SiagaText.body.copyWith(fontSize: 13),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      StatusPill(_short(_range.start), tone: PillTone.warning),
                      const Expanded(
                        child: Divider(
                          indent: 16,
                          endIndent: 16,
                          color: SiagaColors.silverMist,
                        ),
                      ),
                      StatusPill(_short(_range.end), tone: PillTone.warning),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Pemilih tanggal • rentang aktif ditandai emas',
                    style: SiagaText.bodyMuted.copyWith(fontSize: 12.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            GlassSelect(
              label: 'Jenis ringkasan',
              value: _kind,
              options: const [
                'Eksekutif • seluruh operasional',
                'Kehadiran & jadwal',
                'Patroli & checkpoint',
                'Insiden',
              ],
              onChanged: (v) => setState(() => _kind = v),
            ),
            const SizedBox(height: 16),
            SiagaButton.gold(
              label: 'Buat laporan PDF',
              icon: Icons.description_outlined,
              height: 56,
              onPressed: () => exportNotReady(context),
            ),
          ],
        ),
        Text(
          'Pratinjau dokumen',
          style: SiagaText.heading2.copyWith(fontSize: 22),
        ),
        ReportPreview(period: period),
        SectionCard(
          title: 'Cakupan laporan',
          children: [
            Text(
              'Kehadiran bulanan • kepatuhan patroli • pencapaian checkpoint • kategori dan penyelesaian insiden.',
              style: SiagaText.bodyLarge.copyWith(fontWeight: FontWeight.w400),
            ),
            const SizedBox(height: 14),
            Text(
              'Akses Pimpinan: lihat data dan ekspor. Tidak mengubah catatan operasional.',
              style: SiagaText.body.copyWith(fontSize: 13),
            ),
          ],
        ),
        SiagaButton.gold(
          label: 'Ekspor PDF',
          icon: Icons.file_download_outlined,
          height: 56,
          onPressed: () => exportNotReady(context),
        ),
        Text(
          'Dokumen contoh dengan lambang resmi Kemendagri.',
          style: SiagaText.bodyMuted.copyWith(
            color: SiagaColors.silverMist,
            fontSize: 12.5,
          ),
        ),
      ],
    );
  }
}
