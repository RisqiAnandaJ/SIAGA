import 'package:flutter/material.dart';

import '../../core/theme/siaga_colors.dart';
import '../../core/theme/siaga_text.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/list_rows.dart';
import '../../core/widgets/media_widgets.dart';
import '../../core/widgets/siaga_pills.dart';

/// Status penanganan kejadian.
enum IncidentStatus { open, inProgress, done }

extension IncidentStatusX on IncidentStatus {
  String get label => switch (this) {
    IncidentStatus.open => 'Terbuka',
    IncidentStatus.inProgress => 'Dalam Penanganan',
    IncidentStatus.done => 'Selesai',
  };

  PillTone get tone => switch (this) {
    IncidentStatus.open => PillTone.danger,
    IncidentStatus.inProgress => PillTone.warning,
    IncidentStatus.done => PillTone.success,
  };
}

/// Kartu ringkas kejadian pada daftar.
class IncidentListCard extends StatelessWidget {
  const IncidentListCard({
    super.key,
    required this.id,
    required this.title,
    required this.meta,
    required this.status,
    this.summary,
    this.onTap,
    this.featured = false,
    this.category,
  });

  final String id;
  final String title;
  final String meta;
  final IncidentStatus status;
  final String? summary;
  final VoidCallback? onTap;

  /// Kartu unggulan: judul besar dan lencana di atas.
  final bool featured;
  final String? category;

  @override
  Widget build(BuildContext context) {
    final child = featured
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  StatusPill(status.label, tone: status.tone),
                  const SizedBox(width: 10),
                  Text(
                    id,
                    style: SiagaText.caption.copyWith(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: SiagaText.heading1.copyWith(
                  color: SiagaColors.silverMist,
                ),
              ),
              const SizedBox(height: 14),
              Text(meta, style: SiagaText.body.copyWith(fontSize: 13)),
              if (category != null) ...[
                const SizedBox(height: 10),
                Text(category!, style: SiagaText.body.copyWith(fontSize: 13)),
              ],
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InfoRow(
                title: title,
                subtitle: '$id • $meta',
                trailing: StatusPill(status.label, tone: status.tone),
                last: summary == null,
              ),
              if (summary != null) ...[
                const SizedBox(height: 12),
                Text(
                  summary!,
                  style: SiagaText.bodyLarge.copyWith(
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ],
          );

    return GestureDetector(
      onTap: onTap,
      child: GlassCard(child: child),
    );
  }
}

/// Ringkasan lengkap kejadian KJD-024 beserta kronologi.
class IncidentDetailCard extends StatelessWidget {
  const IncidentDetailCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const StatusPill('Dalam Penanganan', tone: PillTone.warning),
              const SizedBox(width: 10),
              Text(
                'KJD-024',
                style: SiagaText.caption.copyWith(fontWeight: FontWeight.w400),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Genangan air di koridor',
            style: SiagaText.heading1.copyWith(color: SiagaColors.silverMist),
          ),
          const SizedBox(height: 14),
          Text(
            'Budi Santoso • 23 Okt 2026, 07.18 WIB',
            style: SiagaText.body.copyWith(fontSize: 13),
          ),
          const SizedBox(height: 10),
          Text(
            'Keselamatan • Gedung utama, lantai 1',
            style: SiagaText.body.copyWith(fontSize: 13),
          ),
          const SizedBox(height: 16),
          Text(
            'Kronologi kejadian',
            style: SiagaText.heading2.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 10),
          Text(
            'Air hujan masuk melalui celah jendela. Lantai koridor menjadi licin. Area diberi tanda peringatan dan dilaporkan kepada PIC PAMDAL.',
            style: SiagaText.bodyLarge.copyWith(fontWeight: FontWeight.w400),
          ),
          const SizedBox(height: 14),
          Text(
            'GPS otomatis • −6.2741, 106.8452',
            style: SiagaText.caption.copyWith(fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }
}

/// Kartu bukti foto kejadian.
class EvidenceCard extends StatelessWidget {
  const EvidenceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const SectionCard(
      title: 'Bukti kejadian',
      children: [EvidencePhoto()],
    );
  }
}

/// Riwayat penanganan kejadian.
class HandlingHistoryCard extends StatelessWidget {
  const HandlingHistoryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const SectionCard(
      title: 'Riwayat penanganan',
      children: [
        InfoRow(
          title: '07.35 • Dalam Penanganan',
          subtitle: 'Rina Wulandari • PIC PAMDAL',
          trailing: StatusPill('Terkini', tone: PillTone.warning),
          body:
              'Petugas kebersihan dihubungi. Area sementara dibatasi sampai lantai aman.',
        ),
        InfoRow(
          title: '07.20 • Laporan diterima',
          subtitle: 'Sistem meneruskan laporan kepada PIC',
          chevron: true,
        ),
        InfoRow(
          title: '07.18 • Laporan dibuat',
          subtitle: 'Budi Santoso • PAMDAL',
          chevron: true,
          last: true,
        ),
      ],
    );
  }
}
