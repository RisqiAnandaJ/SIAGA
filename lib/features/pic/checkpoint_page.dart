import 'package:flutter/material.dart';

import '../../core/theme/siaga_text.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/list_rows.dart';
import '../../core/widgets/page_scaffolds.dart';
import '../../core/widgets/siaga_buttons.dart';
import '../../core/widgets/siaga_fields.dart';
import '../../core/widgets/siaga_pills.dart';

class _Checkpoint {
  _Checkpoint(this.name, this.lat, this.lng, this.radius);

  String name;
  String lat;
  String lng;
  int radius;
  bool active = true;
}

/// Kelola titik checkpoint patroli (khusus PIC PAMDAL).
class CheckpointPage extends StatefulWidget {
  const CheckpointPage({super.key});

  @override
  State<CheckpointPage> createState() => _CheckpointPageState();
}

class _CheckpointPageState extends State<CheckpointPage> {
  final List<_Checkpoint> _points = [
    _Checkpoint('Gerbang utama', '−6.2739', '106.8450', 20),
    _Checkpoint('Gedung utama', '−6.2741', '106.8452', 25),
    _Checkpoint('Area parkir', '−6.2744', '106.8455', 20),
    _Checkpoint('Pos belakang', '−6.2746', '106.8451', 20),
  ];
  int _selected = 2;

  late final _name = TextEditingController();
  late final _lat = TextEditingController();
  late final _lng = TextEditingController();
  late final _radius = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load(_selected);
  }

  void _load(int i) {
    _selected = i;
    final p = _points[i];
    _name.text = p.name;
    _lat.text = p.lat;
    _lng.text = p.lng;
    _radius.text = '${p.radius} meter';
  }

  @override
  void dispose() {
    for (final c in [_name, _lat, _lng, _radius]) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    final radius = int.tryParse(_radius.text.replaceAll(RegExp(r'\D'), ''));
    if (_name.text.trim().isEmpty || radius == null || radius <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama dan radius checkpoint harus valid.'),
        ),
      );
      return;
    }
    setState(() {
      _points[_selected]
        ..name = _name.text.trim()
        ..lat = _lat.text.trim()
        ..lng = _lng.text.trim()
        ..radius = radius;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Checkpoint tersimpan.')));
  }

  void _add() {
    setState(() {
      _points.add(_Checkpoint('Checkpoint baru', '−6.2740', '106.8450', 20));
      _load(_points.length - 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = _points[_selected];
    return MainPage(
      title: 'Kelola checkpoint',
      subtitle:
          '${_points.where((c) => c.active).length} titik aktif • area utama',
      showDock: true,
      dockIndex: 1,
      showBack: true,
      children: [
        SiagaButton.gold(
          label: 'Tambah checkpoint',
          icon: Icons.add,
          height: 56,
          onPressed: _add,
        ),
        SectionCard(
          title: 'Titik verifikasi',
          children: [
            for (var i = 0; i < _points.length; i++)
              InfoRow(
                title: _points[i].name,
                subtitle:
                    '${_points[i].lat}, ${_points[i].lng} • radius ${_points[i].radius} m • ${i == _selected ? 'Dipilih' : (_points[i].active ? 'Edit' : 'Nonaktif')}',
                trailing: i == _selected
                    ? const StatusPill('Aktif', tone: PillTone.success)
                    : null,
                chevron: i != _selected,
                onTap: () => setState(() => _load(i)),
                last: i == _points.length - 1,
              ),
          ],
        ),
        SectionCard(
          title: 'Edit • ${p.name}',
          children: [
            GlassField(label: 'Nama checkpoint', controller: _name),
            const SizedBox(height: 14),
            GlassField(
              label: 'Lintang',
              controller: _lat,
              keyboardType: const TextInputType.numberWithOptions(
                signed: true,
                decimal: true,
              ),
            ),
            const SizedBox(height: 14),
            GlassField(
              label: 'Bujur',
              controller: _lng,
              keyboardType: const TextInputType.numberWithOptions(
                signed: true,
                decimal: true,
              ),
            ),
            const SizedBox(height: 14),
            GlassField(label: 'Radius verifikasi', controller: _radius),
            const SizedBox(height: 16),
            const InfoBanner(
              title: 'Koordinat contoh',
              body:
                  'Validasi titik di lapangan sebelum dipakai dalam operasional nyata.',
            ),
            const SizedBox(height: 16),
            SiagaButton.gold(label: 'Simpan checkpoint', onPressed: _save),
            const SizedBox(height: 12),
            SiagaButton.ghost(
              label: p.active ? 'Nonaktifkan titik' : 'Aktifkan titik',
              onPressed: () => setState(() => p.active = !p.active),
            ),
            const SizedBox(height: 4),
            Text(
              'Perubahan checkpoint dicatat dalam jejak audit.',
              style: SiagaText.bodyMuted.copyWith(fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }
}
