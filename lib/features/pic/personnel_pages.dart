import 'package:flutter/material.dart';

import '../../core/theme/siaga_text.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/list_rows.dart';
import '../../core/widgets/page_scaffolds.dart';
import '../../core/widgets/siaga_buttons.dart';
import '../../core/widgets/siaga_fields.dart';
import '../../core/widgets/siaga_pills.dart';
import 'personnel_detail_page.dart';
import 'registration_pages.dart';

class _Person {
  const _Person(this.name, this.role, this.username, {this.active = true});

  final String name;
  final String role;
  final String username;
  final bool active;
}

/// Direktori personel (PIC PAMDAL): cari, filter peran dan status.
class PersonnelDirectoryPage extends StatefulWidget {
  const PersonnelDirectoryPage({super.key});

  @override
  State<PersonnelDirectoryPage> createState() => _PersonnelDirectoryPageState();
}

class _PersonnelDirectoryPageState extends State<PersonnelDirectoryPage> {
  static const _people = [
    _Person('Budi Santoso', 'PAMDAL', 'budi.santoso'),
    _Person('Agus Setiawan', 'PAMDAL', 'agus.setiawan'),
    _Person('Siti Rahma', 'PAMDAL', 'siti.rahma'),
    _Person('Rina Wulandari', 'PIC PAMDAL', 'rina.wulandari'),
    _Person('Ratna Kusuma', 'Pimpinan', 'ratna.kusuma'),
    _Person('Arif Susanto', 'PAMDAL', 'arif.susanto', active: false),
  ];
  static const _roles = [null, 'PAMDAL', 'PIC PAMDAL', 'Pimpinan'];

  int _role = 0;
  int _status = 0;
  String _query = '';

  List<_Person> get _visible => _people.where((p) {
    final q = _query.trim().toLowerCase();
    return (_roles[_role] == null || p.role == _roles[_role]) &&
        p.active == (_status == 0) &&
        (q.isEmpty ||
            p.name.toLowerCase().contains(q) ||
            p.username.contains(q));
  }).toList();

  void _open(BuildContext context, {String? name}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => PersonnelDetailPage(name: name)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rows = _visible;
    return MainPage(
      title: 'Direktori personel',
      subtitle: '24 akun • 20 PAMDAL • 2 PIC • 2 Pimpinan',
      children: [
        SiagaButton.gold(
          label: 'Tambah personel',
          icon: Icons.person_add_alt_1_outlined,
          height: 56,
          onPressed: () => _open(context),
        ),
        GlassField(
          label: 'Pencarian',
          hint: 'Nama atau username',
          icon: Icons.search,
          onChanged: (v) => setState(() => _query = v),
        ),
        PillTabs(
          labels: const ['Semua', 'PAMDAL', 'PIC', 'Pimpinan'],
          index: _role,
          onChanged: (i) => setState(() => _role = i),
        ),
        PillTabs(
          labels: const ['Aktif (23)', 'Nonaktif (1)'],
          index: _status,
          onChanged: (i) => setState(() => _status = i),
        ),
        SectionCard(
          title: 'Daftar personel',
          children: [
            for (var i = 0; i < rows.length; i++)
              InfoRow(
                title: rows[i].name,
                subtitle: rows[i].role == 'PAMDAL'
                    ? '${rows[i].role} • ${rows[i].username} • Detail / Edit'
                    : '${rows[i].role} • ${rows[i].username}',
                trailing: StatusPill(
                  rows[i].active ? 'Aktif' : 'Nonaktif',
                  tone: rows[i].active ? PillTone.success : PillTone.neutral,
                ),
                onTap: () => _open(context, name: rows[i].name),
                last: i == rows.length - 1,
              ),
            if (rows.isEmpty)
              Text(
                'Tidak ada personel yang cocok.',
                style: SiagaText.bodyMuted,
              ),
          ],
        ),
        SectionCard(
          title: 'Administrasi akun',
          children: [
            InfoRow(
              title: 'Antrean pendaftaran',
              subtitle: '3 pengajuan baru menunggu peninjauan',
              trailing: const StatusPill('3', tone: PillTone.warning),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const RegistrationQueuePage(),
                ),
              ),
            ),
            Text(
              'Buka detail personel untuk mengubah data, peran, dan menonaktifkan akses.',
              style: SiagaText.body.copyWith(fontSize: 13.5),
            ),
          ],
        ),
      ],
    );
  }
}
