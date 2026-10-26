import 'package:flutter/material.dart';

import '../../core/theme/siaga_text.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/list_rows.dart';
import '../../core/widgets/page_scaffolds.dart';
import '../../core/widgets/siaga_buttons.dart';
import '../../core/widgets/siaga_fields.dart';
import '../../core/widgets/siaga_pills.dart';
import '../shared/incident_widgets.dart';

/// Semua laporan kejadian (PIC PAMDAL).
class PicIncidentListPage extends StatefulWidget {
  const PicIncidentListPage({super.key});

  @override
  State<PicIncidentListPage> createState() => _PicIncidentListPageState();
}

class _PicIncidentListPageState extends State<PicIncidentListPage> {
  int _filter = 1;
  String _query = '';

  bool _match(String text) =>
      _query.trim().isEmpty ||
      text.toLowerCase().contains(_query.trim().toLowerCase());

  @override
  Widget build(BuildContext context) {
    final showFeatured =
        _filter == 1 && _match('genangan air di koridor kjd-024 budi santoso');
    final showSecond =
        _filter == 1 &&
        _match('kunci akses perlu diperbaiki kjd-023 agus setiawan');
    final showOpen =
        _filter == 0 && _match('lampu pos berkedip kjd-021 budi santoso');
    final showDone =
        _filter == 2 &&
        _match('pintu akses tidak tertutup kjd-018 budi santoso');

    return MainPage(
      title: 'Semua laporan kejadian',
      subtitle: 'Seluruh personel • 12 laporan bulan ini',
      children: [
        GlassField(
          label: 'Cari laporan',
          hint: 'Judul, nomor, atau nama pelapor',
          icon: Icons.search,
          onChanged: (v) => setState(() => _query = v),
        ),
        PillTabs(
          labels: const ['Terbuka', 'Dalam Penanganan', 'Selesai'],
          index: _filter,
          onChanged: (i) => setState(() => _filter = i),
          height: 52,
        ),
        Text(
          '2 dalam penanganan • urutkan: terbaru',
          style: SiagaText.bodyMuted,
        ),
        if (showFeatured)
          IncidentListCard(
            featured: true,
            id: 'KJD-024',
            title: 'Genangan air di koridor',
            meta: 'Budi Santoso • 23 Okt 2026, 07.18 WIB',
            category: 'Keselamatan • Gedung utama, lantai 1',
            status: IncidentStatus.inProgress,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const IncidentFollowUpPage(),
              ),
            ),
          ),
        if (showSecond) const GlassCard(child: _HandledRow()),
        if (showOpen)
          const IncidentListCard(
            id: 'KJD-021',
            title: 'Lampu pos berkedip',
            meta: '22 Okt, 08.10 • Budi Santoso',
            status: IncidentStatus.open,
            summary:
                'Lampu penerangan pos utama tidak stabil. Menunggu penugasan teknisi.',
          ),
        if (showDone)
          const IncidentListCard(
            id: 'KJD-018',
            title: 'Pintu akses tidak tertutup',
            meta: '20 Okt, 10.25 • Budi Santoso',
            status: IncidentStatus.done,
            summary: 'Penutup pintu telah diperbaiki dan diuji kembali.',
          ),
        if (!(showFeatured || showSecond || showOpen || showDone))
          Text('Tidak ada laporan yang cocok.', style: SiagaText.bodyMuted),
        const SectionCard(
          title: 'Ringkasan status',
          children: [
            InfoRow(
              title: 'Terbuka',
              subtitle: 'Menunggu penugasan • Lampu pos berkedip',
              trailing: StatusPill('1', tone: PillTone.danger),
            ),
            InfoRow(
              title: 'Dalam Penanganan',
              subtitle: 'Diteruskan ke petugas terkait',
              trailing: StatusPill('2', tone: PillTone.warning),
            ),
            InfoRow(
              title: 'Selesai',
              subtitle: 'Ditutup setelah verifikasi',
              trailing: StatusPill('9', tone: PillTone.success),
              last: true,
            ),
          ],
        ),
      ],
    );
  }
}

class _HandledRow extends StatelessWidget {
  const _HandledRow();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InfoRow(
          title: 'Kunci akses perlu diperbaiki',
          subtitle: 'KJD-023 • Agus Setiawan • 23 Okt, 07.05',
          trailing: StatusPill('Ditangani', tone: PillTone.warning),
        ),
        SizedBox(height: 4),
        Text(
          'Penanganan terakhir 07.25 oleh Rina Wulandari. Teknisi melakukan pemeriksaan kunci.',
          style: TextStyle(
            fontSize: 16,
            height: 1.45,
            color: Color(0xFFE2E8F0),
          ),
        ),
      ],
    );
  }
}

/// Detail dan pembaruan penanganan kejadian.
class IncidentFollowUpPage extends StatefulWidget {
  const IncidentFollowUpPage({super.key});

  @override
  State<IncidentFollowUpPage> createState() => _IncidentFollowUpPageState();
}

class _IncidentFollowUpPageState extends State<IncidentFollowUpPage> {
  int _status = 1;
  final _note = TextEditingController(
    text:
        'Petugas kebersihan dihubungi. Area sementara dibatasi sampai lantai aman.',
  );

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  void _save() {
    if (_note.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Catatan tindak lanjut wajib diisi.')),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tindak lanjut tersimpan dan dicatat dalam audit.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainPage(
      title: 'Tindak lanjut insiden',
      subtitle: 'KJD-024 • kendali PIC PAMDAL',
      showDock: true,
      dockIndex: 2,
      showBack: true,
      children: [
        const IncidentDetailCard(),
        const EvidenceCard(),
        const HandlingHistoryCard(),
        SectionCard(
          title: 'Perbarui penanganan',
          tone: GlassTone.gold,
          children: [
            Text('Status baru', style: SiagaText.body.copyWith(fontSize: 13)),
            const SizedBox(height: 8),
            PillTabs(
              labels: const ['Terbuka', 'Dalam Penanganan', 'Selesai'],
              index: _status,
              onChanged: (i) => setState(() => _status = i),
              height: 56,
            ),
            const SizedBox(height: 16),
            GlassField(
              label: 'Catatan tindak lanjut',
              controller: _note,
              maxLines: 3,
            ),
            const SizedBox(height: 14),
            SiagaButton.ghost(
              label: 'Tambah bukti penanganan',
              icon: Icons.photo_camera_outlined,
              onPressed: () {},
            ),
            const SizedBox(height: 12),
            Text(
              'Kelola bukti: tambah dokumentasi atau hapus lampiran tindak lanjut sebelum disimpan. Bukti dan kronologi asli tetap dipertahankan.',
              style: SiagaText.bodyMuted.copyWith(fontSize: 12),
            ),
            const SizedBox(height: 16),
            SiagaButton.gold(label: 'Simpan tindak lanjut', onPressed: _save),
          ],
        ),
      ],
    );
  }
}
