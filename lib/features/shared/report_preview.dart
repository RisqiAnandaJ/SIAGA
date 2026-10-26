import 'package:flutter/material.dart';

import '../../core/theme/siaga_colors.dart';
import '../../core/widgets/siaga_logo.dart';

const _months = [
  '',
  'Januari',
  'Februari',
  'Maret',
  'April',
  'Mei',
  'Juni',
  'Juli',
  'Agustus',
  'September',
  'Oktober',
  'November',
  'Desember',
];

/// Contoh: "1–23 Oktober 2026".
String formatRange(DateTimeRange r) {
  final s = r.start;
  final e = r.end;
  if (s.year == e.year && s.month == e.month) {
    return '${s.day}–${e.day} ${_months[e.month]} ${e.year}';
  }
  return '${s.day} ${_months[s.month]} – ${e.day} ${_months[e.month]} ${e.year}';
}

/// Ekspor PDF memakai syncfusion_flutter_pdf; belum tersambung.
void exportNotReady(BuildContext context) {
  // TODO(Konfirmasi-BPSDM): tetapkan format laporan, filter, dan kebutuhan
  // tanda tangan, lalu hasilkan PDF dengan syncfusion_flutter_pdf.
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text(
        'Ekspor PDF belum tersambung: format laporan menunggu konfirmasi BPSDM.',
      ),
    ),
  );
}

/// Pratinjau kertas laporan dengan kop surat Kemendagri.
class ReportPreview extends StatelessWidget {
  const ReportPreview({super.key, required this.period});

  final String period;

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF0B2A43);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SiagaColors.pureWhite,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SiagaLogo(height: 66),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'KEMENTERIAN DALAM NEGERI',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: ink,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'BADAN PENGEMBANGAN SUMBER DAYA MANUSIA',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: ink,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 2, thickness: 2, color: ink),
          const SizedBox(height: 14),
          const Center(
            child: Text(
              'LAPORAN OPERASIONAL PAMDAL',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: ink,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Periode $period',
              style: const TextStyle(fontSize: 11.5, color: ink),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Kehadiran personel: 96,2%\nKepatuhan patroli: 94%\nInsiden tercatat: 12\nInsiden selesai: 9',
            style: TextStyle(fontSize: 13, height: 1.5, color: ink),
          ),
          const SizedBox(height: 12),
          const Text(
            'Dokumen contoh • data ilustratif\nBPSDM Kementerian Dalam Negeri',
            style: TextStyle(fontSize: 10.5, color: ink, height: 1.4),
          ),
        ],
      ),
    );
  }
}
