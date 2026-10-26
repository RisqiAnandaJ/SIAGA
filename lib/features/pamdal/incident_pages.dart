import 'package:flutter/material.dart';

import '../../core/theme/siaga_colors.dart';
import '../../core/theme/siaga_text.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/list_rows.dart';
import '../../core/widgets/media_widgets.dart';
import '../../core/widgets/page_scaffolds.dart';
import '../../core/widgets/siaga_buttons.dart';
import '../../core/widgets/siaga_fields.dart';
import '../../core/widgets/siaga_pills.dart';
import '../shared/incident_widgets.dart';

/// Daftar laporan kejadian milik sendiri.
class MyIncidentsPage extends StatefulWidget {
  const MyIncidentsPage({super.key});

  @override
  State<MyIncidentsPage> createState() => _MyIncidentsPageState();
}

class _MyIncidentsPageState extends State<MyIncidentsPage> {
  int _filter = 0;

  @override
  Widget build(BuildContext context) {
    final openOnly = _filter == 1;
    final doneOnly = _filter == 2;
    final showCurrent = !openOnly && !doneOnly;

    return MainPage(
      title: 'Laporan kejadian saya',
      subtitle: '3 laporan pribadi • Oktober 2026',
      children: [
        SiagaButton.gold(
          label: 'Lapor kejadian',
          icon: Icons.add,
          height: 56,
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const ReportIncidentPage()),
          ),
        ),
        PillTabs(
          labels: const ['Semua', 'Terbuka', 'Selesai'],
          index: _filter,
          onChanged: (i) => setState(() => _filter = i),
        ),
        if (showCurrent)
          IncidentListCard(
            featured: true,
            id: 'KJD-024',
            title: 'Genangan air di koridor',
            meta: 'Budi Santoso • 23 Okt 2026, 07.18 WIB',
            category: 'Keselamatan • Gedung utama, lantai 1',
            status: IncidentStatus.inProgress,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const MyIncidentDetailPage(),
              ),
            ),
          ),
        if (!doneOnly)
          const IncidentListCard(
            id: 'KJD-021',
            title: 'Lampu pos berkedip',
            meta: '22 Okt, 08.10 • Budi Santoso',
            status: IncidentStatus.open,
            summary:
                'Lampu penerangan pos utama tidak stabil. Menunggu penugasan teknisi.',
          ),
        if (!openOnly)
          const IncidentListCard(
            id: 'KJD-018',
            title: 'Pintu akses tidak tertutup',
            meta: '20 Okt, 10.25 • Budi Santoso',
            status: IncidentStatus.done,
            summary: 'Penutup pintu telah diperbaiki dan diuji kembali.',
          ),
        Text(
          'Anda hanya dapat melihat laporan sendiri. Penanganan dilakukan oleh PIC PAMDAL.',
          style: SiagaText.bodyMuted.copyWith(
            color: SiagaColors.silverMist,
            fontSize: 12.5,
          ),
        ),
      ],
    );
  }
}

/// Detail kejadian milik sendiri (hanya lihat).
class MyIncidentDetailPage extends StatelessWidget {
  const MyIncidentDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainPage(
      title: 'Detail kejadian',
      subtitle: 'Laporan Anda • KJD-024',
      showDock: true,
      dockIndex: 3,
      showBack: true,
      children: [
        IncidentDetailCard(),
        EvidenceCard(),
        HandlingHistoryCard(),
        InfoBanner(
          title: 'Penanganan hanya dapat dilihat',
          body:
              'Status dan catatan tindak lanjut dikelola PIC PAMDAL. Kronologi asli Anda tetap tersimpan.',
        ),
      ],
    );
  }
}

/// Formulir laporan kejadian baru.
class ReportIncidentPage extends StatefulWidget {
  const ReportIncidentPage({super.key});

  @override
  State<ReportIncidentPage> createState() => _ReportIncidentPageState();
}

class _ReportIncidentPageState extends State<ReportIncidentPage> {
  static const _categories = [
    'Keselamatan',
    'Keamanan',
    'Fasilitas',
    'Lainnya',
  ];

  final _title = TextEditingController();
  final _story = TextEditingController();
  int _category = 0;
  bool _hasPhoto = true;
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    _story.dispose();
    super.dispose();
  }

  void _submit({required bool draft}) {
    if (!draft && (_title.text.trim().isEmpty || _story.text.trim().isEmpty)) {
      setState(() => _error = 'Judul dan kronologi wajib diisi');
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          draft ? 'Draf laporan disimpan.' : 'Laporan kejadian terkirim.',
        ),
      ),
    );
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return MainPage(
      title: 'Lapor kejadian',
      subtitle: 'Catat fakta dan kondisi di lapangan',
      showDock: true,
      dockIndex: 3,
      showBack: true,
      children: [
        SectionCard(
          title: 'Informasi kejadian',
          children: [
            Text('Kategori', style: SiagaText.label),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var i = 0; i < _categories.length; i++)
                  GlassChip(
                    label: _categories[i],
                    selected: i == _category,
                    onTap: () => setState(() => _category = i),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            GlassField(
              label: 'Judul kejadian',
              hint: 'Ringkas kejadian',
              controller: _title,
              onChanged: (_) => setState(() => _error = null),
            ),
            const SizedBox(height: 16),
            GlassField(
              label: 'Kronologi',
              hint: 'Uraikan apa yang terjadi dan tindakan Anda',
              controller: _story,
              maxLines: 5,
              errorText: _error,
            ),
            const SizedBox(height: 16),
            GlassCard(
              tone: GlassTone.success,
              radius: 22,
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.verified_user_outlined,
                    size: 24,
                    color: SiagaColors.successText,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lokasi terdeteksi otomatis',
                          style: SiagaText.bodyLarge.copyWith(
                            fontWeight: FontWeight.w700,
                            color: SiagaColors.pureWhite,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Gedung utama, lantai 1 • −6.2741, 106.8452 • akurasi ±8 m',
                          style: SiagaText.body.copyWith(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SectionCard(
          title: 'Bukti foto',
          children: [
            if (_hasPhoto) ...[
              const EvidencePhoto(),
              const SizedBox(height: 6),
              const InfoRow(
                title: 'bukti_koridor.jpg',
                subtitle: '1,2 MB • unggahan selesai',
                trailing: StatusPill('100%', tone: PillTone.success),
              ),
            ],
            SiagaButton.ghost(
              label: _hasPhoto ? 'Tambah foto bukti' : 'Ambil foto bukti',
              icon: Icons.photo_camera_outlined,
              onPressed: () => setState(() => _hasPhoto = true),
            ),
          ],
        ),
        Text(
          'Pelapor: Budi Santoso • PAMDAL\nDokumentasi contoh, bukan kejadian nyata.',
          style: SiagaText.bodyMuted.copyWith(
            color: SiagaColors.silverMist,
            fontSize: 12.5,
          ),
        ),
        SiagaButton.gold(
          label: 'Kirim laporan kejadian',
          height: 56,
          onPressed: () => _submit(draft: false),
        ),
        SiagaButton.ghost(
          label: 'Simpan sebagai draf',
          onPressed: () => _submit(draft: true),
        ),
      ],
    );
  }
}
