import 'package:flutter/material.dart';

import '../../core/theme/siaga_text.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/list_rows.dart';
import '../../core/widgets/page_scaffolds.dart';
import '../../core/widgets/siaga_buttons.dart';
import '../../core/widgets/siaga_fields.dart';
import '../../core/widgets/siaga_pills.dart';

/// Kelola pengumuman operasional untuk personel.
class AnnouncementPage extends StatefulWidget {
  const AnnouncementPage({super.key});

  @override
  State<AnnouncementPage> createState() => _AnnouncementPageState();
}

class _AnnouncementPageState extends State<AnnouncementPage> {
  final _title = TextEditingController(text: 'Pemeriksaan akses tamu');
  final _body = TextEditingController(
    text:
        'Pemeriksaan akses tamu diperketat. Pastikan identitas dan buku kunjungan terisi lengkap.',
  );
  String _audience = 'Seluruh PAMDAL';
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  void _send() {
    if (_title.text.trim().isEmpty || _body.text.trim().isEmpty) {
      setState(() => _error = 'Judul dan isi pengumuman wajib diisi');
      return;
    }
    setState(() => _error = null);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Pengumuman terkirim kepada $_audience.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainPage(
      title: 'Kelola pengumuman',
      subtitle: 'Informasi operasional untuk personel',
      showDock: true,
      dockIndex: 0,
      showBack: true,
      children: [
        SectionCard(
          title: 'Buat pengumuman',
          children: [
            GlassField(label: 'Judul', controller: _title),
            const SizedBox(height: 16),
            GlassField(
              label: 'Isi pengumuman',
              controller: _body,
              maxLines: 3,
              errorText: _error,
            ),
            const SizedBox(height: 16),
            GlassSelect(
              label: 'Penerima',
              value: _audience,
              options: const [
                'Seluruh PAMDAL',
                'Seluruh Pimpinan',
                'Seluruh personel',
              ],
              onChanged: (v) => setState(() => _audience = v),
            ),
            const SizedBox(height: 10),
            Text(
              '20 penerima • tampil di beranda dan pusat notifikasi',
              style: SiagaText.bodyMuted.copyWith(fontSize: 12.5),
            ),
            const SizedBox(height: 14),
            SiagaButton.gold(
              label: 'Kirim pengumuman',
              icon: Icons.send_outlined,
              onPressed: _send,
            ),
          ],
        ),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pengumuman terkirim',
                style: SiagaText.heading2.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 14),
              const StatusPill(
                'Terkirim • 23 Okt, 06.45',
                tone: PillTone.success,
              ),
              const SizedBox(height: 14),
              Text(
                'Pemeriksaan akses tamu',
                style: SiagaText.heading2.copyWith(fontSize: 21),
              ),
              const SizedBox(height: 12),
              Text(
                'Pemeriksaan akses tamu diperketat. Pastikan identitas dan buku kunjungan terisi lengkap.',
                style: SiagaText.bodyLarge.copyWith(
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Rina Wulandari • seluruh PAMDAL • 18 dibaca',
                style: SiagaText.bodyMuted.copyWith(fontSize: 12.5),
              ),
            ],
          ),
        ),
        const GlassCard(
          child: InfoRow(
            title: 'Serah terima perlengkapan',
            subtitle: '22 Okt, 14.30 • Seluruh PAMDAL',
            chevron: true,
            last: true,
            body:
                'Periksa radio komunikasi dan kunci akses sebelum serah terima shift.',
          ),
        ),
      ],
    );
  }
}
