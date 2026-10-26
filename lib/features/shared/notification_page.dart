import 'package:flutter/material.dart';

import '../../core/state/session.dart';
import '../../core/theme/siaga_text.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/list_rows.dart';
import '../../core/widgets/page_scaffolds.dart';
import '../../core/widgets/siaga_buttons.dart';
import '../../core/widgets/siaga_pills.dart';

class _Notice {
  _Notice({
    required this.title,
    required this.meta,
    required this.body,
    required this.tag,
    required this.tagTone,
    this.read = false,
  });

  final String title;
  final String meta;
  final String body;
  final String tag;
  final PillTone tagTone;
  bool read;
}

/// Pusat notifikasi dalam aplikasi.
class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  int _filter = 0;

  final List<_Notice> _items = [
    _Notice(
      title: 'Checkpoint terlewat',
      meta: '07.40 • Agus Setiawan',
      body:
          'Gedung utama belum terverifikasi dalam sesi 07.05. Periksa telemetri patroli.',
      tag: 'Patroli',
      tagTone: PillTone.danger,
    ),
    _Notice(
      title: 'Pengajuan akun baru',
      meta: '07.30 • Dimas Pratama',
      body: 'Email terverifikasi. Peran PAMDAL menunggu persetujuan Anda.',
      tag: 'Akun',
      tagTone: PillTone.neutral,
    ),
    _Notice(
      title: 'Laporan KJD-024',
      meta: '07.18 • Budi Santoso',
      body: 'Genangan air di koridor memerlukan penanganan.',
      tag: 'Insiden',
      tagTone: PillTone.warning,
    ),
    _Notice(
      title: 'Pengumuman operasional',
      meta: '06.45 • Pemeriksaan akses tamu',
      body: '',
      tag: '',
      tagTone: PillTone.neutral,
      read: true,
    ),
    _Notice(
      title: 'Persetujuan akun selesai',
      meta: '22 Okt, 16.10 • Siti Rahma • Akun aktif',
      body: '',
      tag: '',
      tagTone: PillTone.neutral,
      read: true,
    ),
  ];

  int get _unread => _items.where((n) => !n.read).length;

  @override
  Widget build(BuildContext context) {
    final role = SessionScope.of(context).role ?? UserRole.pamdal;
    final unread = _items.where((n) => !n.read).toList();
    final read = _items.where((n) => n.read).toList();
    final showRead = _filter == 0;

    return MainPage(
      title: 'Pusat notifikasi',
      subtitle: '${SessionScope.of(context).displayName} • ${role.label}',
      showDock: true,
      dockIndex: 0,
      showBack: true,
      children: [
        PillTabs(
          labels: ['Semua', 'Belum dibaca ($_unread)'],
          index: _filter,
          onChanged: (i) => setState(() => _filter = i),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: SiagaTextLink(
            label: 'Tandai semua telah dibaca',
            onTap: () => setState(() {
              for (final n in _items) {
                n.read = true;
              }
            }),
          ),
        ),
        Text('Hari ini', style: SiagaText.heading2.copyWith(fontSize: 22)),
        for (final n in unread)
          _UnreadCard(notice: n, onTap: () => setState(() => n.read = true)),
        if (showRead && read.isNotEmpty)
          GlassCard(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const StatusPill('Sudah dibaca'),
                const SizedBox(height: 8),
                for (var i = 0; i < read.length; i++)
                  InfoRow(
                    title: read[i].title,
                    subtitle: read[i].meta,
                    chevron: true,
                    last: i == read.length - 1,
                  ),
              ],
            ),
          ),
        if (unread.isEmpty && !showRead)
          Text('Semua notifikasi sudah dibaca.', style: SiagaText.bodyMuted),
      ],
    );
  }
}

class _UnreadCard extends StatelessWidget {
  const _UnreadCard({required this.notice, required this.onTap});

  final _Notice notice;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        tone: GlassTone.gold,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const StatusPill('Belum dibaca', tone: PillTone.warning, dot: true),
            const SizedBox(height: 4),
            InfoRow(
              title: notice.title,
              subtitle: notice.meta,
              trailing: StatusPill(notice.tag, tone: notice.tagTone),
            ),
            Text(
              notice.body,
              style: SiagaText.bodyLarge.copyWith(fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ),
    );
  }
}
