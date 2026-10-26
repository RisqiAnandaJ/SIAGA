import 'package:flutter/material.dart';

import '../../core/theme/siaga_colors.dart';
import '../../core/theme/siaga_text.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/page_scaffolds.dart';
import '../../core/widgets/siaga_buttons.dart';
import '../../core/widgets/siaga_fields.dart';
import '../../core/widgets/siaga_pills.dart';
import '../shared/report_preview.dart';

/// Laporan operasional (PIC PAMDAL): pilih jenis, periode, pratinjau, ekspor.
class PicReportPage extends StatefulWidget {
  const PicReportPage({super.key});

  @override
  State<PicReportPage> createState() => _PicReportPageState();
}

class _PicReportPageState extends State<PicReportPage> {
  String _type = 'Gabungan operasional';
  int _tab = 0;
  DateTimeRange _range = DateTimeRange(
    start: DateTime(2026, 10, 1),
    end: DateTime(2026, 10, 23),
  );
  bool _summaryShown = true;

  Future<void> _pickRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2026, 1, 1),
      lastDate: DateTime(2026, 12, 31),
      initialDateRange: _range,
    );
    if (picked != null) setState(() => _range = picked);
  }

  @override
  Widget build(BuildContext context) {
    final period = formatRange(_range);
    return MainPage(
      title: 'Laporan operasional',
      subtitle: 'Rekap terpusat • data ilustratif',
      children: [
        SectionCard(
          title: 'Pilih laporan',
          children: [
            GlassSelect(
              label: 'Jenis laporan',
              value: _type,
              options: const [
                'Gabungan operasional',
                'Absensi personel',
                'Patroli & checkpoint',
                'Insiden',
              ],
              onChanged: (v) => setState(() => _type = v),
            ),
            const SizedBox(height: 14),
            PillTabs(
              labels: const ['Absensi', 'Patroli', 'Insiden'],
              index: _tab,
              onChanged: (i) => setState(() => _tab = i),
              height: 52,
            ),
            const SizedBox(height: 14),
            GlassField(
              label: 'Rentang tanggal',
              initialValue: period,
              key: ValueKey(period),
              icon: Icons.calendar_month_outlined,
              readOnly: true,
              onTap: _pickRange,
            ),
            const SizedBox(height: 14),
            const GlassField(
              label: 'Cakupan personel',
              initialValue: 'Seluruh personel',
              icon: Icons.groups_outlined,
              readOnly: true,
            ),
            const SizedBox(height: 16),
            SiagaButton.gold(
              label: 'Tampilkan ringkasan',
              onPressed: () => setState(() => _summaryShown = true),
            ),
          ],
        ),
        if (_summaryShown)
          SectionCard(
            title: 'Ringkasan periode',
            children: [
              Text(
                'Kehadiran 96,2% • 20 PAMDAL\nKepatuhan patroli 94%\n12 insiden • 9 selesai • 3 belum selesai',
                style: SiagaText.bodyLarge.copyWith(
                  fontWeight: FontWeight.w400,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Termasuk rincian absen, sesi patroli, checkpoint, dan tindak lanjut insiden.',
                style: SiagaText.body.copyWith(fontSize: 13),
              ),
            ],
          ),
        Text(
          'Pratinjau PDF resmi',
          style: SiagaText.heading2.copyWith(fontSize: 22),
        ),
        ReportPreview(period: period),
        SiagaButton.gold(
          label: 'Ekspor PDF',
          icon: Icons.file_download_outlined,
          height: 56,
          onPressed: () => exportNotReady(context),
        ),
        Text(
          'Kop surat menggunakan lambang Kemendagri. Dokumen contoh, bukan laporan dinas resmi.',
          style: SiagaText.bodyMuted.copyWith(
            color: SiagaColors.silverMist,
            fontSize: 12.5,
          ),
        ),
      ],
    );
  }
}
