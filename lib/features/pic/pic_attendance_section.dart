import 'package:flutter/material.dart';

import '../../core/theme/siaga_text.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/list_rows.dart';
import '../../core/widgets/siaga_buttons.dart';
import '../../core/widgets/siaga_fields.dart';
import '../../core/widgets/siaga_pills.dart';

class _Row {
  const _Row(this.name, this.detail, this.status);

  final String name;
  final String detail;
  final String status;
}

/// Kelola absensi: filter, pencarian, daftar kehadiran, dan koreksi.
class PicAttendanceSection extends StatefulWidget {
  const PicAttendanceSection({super.key});

  @override
  State<PicAttendanceSection> createState() => _PicAttendanceSectionState();
}

class _PicAttendanceSectionState extends State<PicAttendanceSection> {
  static const _rows = [
    _Row('Budi Santoso', '06.54 • Shift pagi • GPS valid', 'Hadir'),
    _Row('Agus Setiawan', '06.58 • Shift pagi • GPS valid', 'Hadir'),
    _Row('Siti Rahma', '07.09 • Shift pagi • Ketuk untuk koreksi', 'Terlambat'),
    _Row('Hendra Wijaya', 'Shift sore • 15.00–23.00', 'Belum'),
  ];

  int _filter = 0;
  int _status = 0;
  String _query = '';
  TimeOfDay _time = const TimeOfDay(hour: 6, minute: 57);
  final _reason = TextEditingController(
    text: 'Kendala sinkronisasi perangkat, dikonfirmasi koordinator shift.',
  );

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  PillTone _tone(String s) => switch (s) {
    'Hadir' => PillTone.success,
    'Terlambat' => PillTone.warning,
    _ => PillTone.neutral,
  };

  List<_Row> get _visible => _rows.where((r) {
    final byTab = switch (_filter) {
      1 => r.status == 'Hadir',
      2 => r.status == 'Belum',
      _ => true,
    };
    final q = _query.trim().toLowerCase();
    return byTab && (q.isEmpty || r.name.toLowerCase().contains(q));
  }).toList();

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _time = picked);
  }

  void _save() {
    if (_reason.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alasan koreksi wajib diisi.')),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Koreksi absensi tersimpan dan dicatat dalam audit.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final time =
        '${_time.hour.toString().padLeft(2, '0')}.${_time.minute.toString().padLeft(2, '0')} WIB';
    final rows = _visible;
    return SpacedColumn(
      children: [
        PillTabs(
          labels: const ['Semua (20)', 'Hadir (7)', 'Belum (13)'],
          index: _filter,
          onChanged: (i) => setState(() => _filter = i),
        ),
        GlassField(
          label: 'Cari personel',
          hint: 'Nama atau username',
          icon: Icons.search,
          onChanged: (v) => setState(() => _query = v),
        ),
        SectionCard(
          title: 'Kehadiran hari ini',
          children: [
            for (var i = 0; i < rows.length; i++)
              InfoRow(
                title: rows[i].name,
                subtitle: rows[i].detail,
                trailing: StatusPill(
                  rows[i].status,
                  tone: _tone(rows[i].status),
                ),
                last: i == rows.length - 1 && _filter != 0,
              ),
            if (rows.isEmpty)
              Text(
                'Tidak ada personel yang cocok.',
                style: SiagaText.bodyMuted,
              ),
            if (_filter == 0)
              Padding(
                padding: const EdgeInsets.only(top: 14),
                child: Text(
                  'Tampilkan 16 personel lainnya →',
                  style: SiagaText.body.copyWith(fontSize: 13.5),
                ),
              ),
          ],
        ),
        SectionCard(
          title: 'Koreksi absensi • Siti Rahma',
          tone: GlassTone.raised,
          children: [
            Text(
              '23 Oktober 2026 • catatan awal 07.09 WIB',
              style: SiagaText.bodyMuted,
            ),
            const SizedBox(height: 14),
            PillTabs(
              labels: const ['Hadir', 'Izin', 'Sakit', 'Alpa'],
              index: _status,
              onChanged: (i) => setState(() => _status = i),
              height: 52,
            ),
            const SizedBox(height: 14),
            GlassField(
              label: 'Waktu masuk terkoreksi',
              initialValue: time,
              key: ValueKey('t${_time.hour}${_time.minute}'),
              icon: Icons.schedule,
              readOnly: true,
              onTap: _pickTime,
            ),
            const SizedBox(height: 14),
            GlassField(
              label: 'Alasan koreksi wajib',
              controller: _reason,
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            SiagaButton.gold(label: 'Simpan koreksi', onPressed: _save),
            const SizedBox(height: 12),
            SiagaButton.ghost(label: 'Batal', onPressed: () {}),
          ],
        ),
      ],
    );
  }
}
