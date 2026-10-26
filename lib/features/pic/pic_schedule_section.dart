import 'package:flutter/material.dart';

import '../../core/theme/siaga_colors.dart';
import '../../core/theme/siaga_text.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/list_rows.dart';
import '../../core/widgets/siaga_buttons.dart';
import '../../core/widgets/siaga_fields.dart';
import '../../core/widgets/siaga_pills.dart';

/// Kelola jadwal jaga: daftar hari ini dan formulir tambah jadwal.
class PicScheduleSection extends StatefulWidget {
  const PicScheduleSection({super.key});

  @override
  State<PicScheduleSection> createState() => _PicScheduleSectionState();
}

class _PicScheduleSectionState extends State<PicScheduleSection> {
  static const _days = [21, 22, 23, 24, 25, 26];

  String _personnel = 'Hendra Wijaya, Dewi Lestari';
  final _post = TextEditingController(text: 'Pos utama & gedung utama');
  final _note = TextEditingController(
    text: 'Serah terima di pos utama sebelum shift dimulai.',
  );
  int _day = 24;
  TimeOfDay _start = const TimeOfDay(hour: 15, minute: 0);
  TimeOfDay _end = const TimeOfDay(hour: 23, minute: 0);

  @override
  void dispose() {
    _post.dispose();
    _note.dispose();
    super.dispose();
  }

  String _fmt(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')} : ${t.minute.toString().padLeft(2, '0')} WIB';

  Future<void> _pick(bool start) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: start ? _start : _end,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() => start ? _start = picked : _end = picked);
  }

  String get _dayName {
    const names = {
      21: 'Rabu',
      22: 'Kamis',
      23: 'Jumat',
      24: 'Sabtu',
      25: 'Minggu',
      26: 'Senin',
    };
    return '${names[_day]}, $_day Oktober 2026';
  }

  void _save() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Jadwal $_day Okt tersimpan untuk $_personnel.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SpacedColumn(
      children: [
        const SectionCard(
          title: 'Jadwal hari ini',
          children: [
            InfoRow(
              title: '07.00–15.00 • Pagi',
              subtitle: 'Budi Santoso, Agus Setiawan, Siti Rahma',
              trailing: StatusPill('Aktif', tone: PillTone.warning),
            ),
            InfoRow(
              title: '15.00–23.00 • Sore',
              subtitle: 'Hendra Wijaya, Dewi Lestari • Edit',
              chevron: true,
            ),
            InfoRow(
              title: '23.00–07.00 • Malam',
              subtitle: 'Fajar Nugroho, Rizal Hidayat • Edit',
              chevron: true,
              last: true,
            ),
          ],
        ),
        SectionCard(
          title: 'Tambah jadwal',
          children: [
            GlassSelect(
              label: 'Personel',
              value: _personnel,
              options: const [
                'Hendra Wijaya, Dewi Lestari',
                'Budi Santoso, Agus Setiawan',
                'Fajar Nugroho, Rizal Hidayat',
              ],
              onChanged: (v) => setState(() => _personnel = v),
            ),
            const SizedBox(height: 16),
            GlassField(label: 'Pos penugasan', controller: _post),
            const SizedBox(height: 16),
            GlassField(
              label: 'Tanggal',
              initialValue: '$_day Oktober 2026',
              key: ValueKey(_day),
              icon: Icons.calendar_month_outlined,
              readOnly: true,
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: GlassCard(
                radius: 22,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Oktober 2026',
                      style: SiagaText.heading2.copyWith(fontSize: 20),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final d in _days)
                          GlassChip(
                            label: '$d',
                            selected: d == _day,
                            onTap: () => setState(() => _day = d),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(_dayName, style: SiagaText.bodyMuted),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            GlassField(
              label: 'Jam mulai',
              initialValue: _fmt(_start),
              key: ValueKey('s${_start.hour}${_start.minute}'),
              icon: Icons.schedule,
              readOnly: true,
              onTap: () => _pick(true),
            ),
            const SizedBox(height: 16),
            GlassField(
              label: 'Jam selesai',
              initialValue: _fmt(_end),
              key: ValueKey('e${_end.hour}${_end.minute}'),
              icon: Icons.schedule,
              readOnly: true,
              onTap: () => _pick(false),
            ),
            const SizedBox(height: 16),
            GlassField(
              label: 'Catatan penugasan',
              controller: _note,
              maxLines: 3,
            ),
            const SizedBox(height: 18),
            SiagaButton.gold(label: 'Simpan jadwal', onPressed: _save),
            const SizedBox(height: 12),
            SiagaButton.ghost(label: 'Batal', onPressed: () {}),
          ],
        ),
        Text(
          'Perubahan jadwal dicatat dalam jejak audit.',
          style: SiagaText.bodyMuted.copyWith(
            color: SiagaColors.silverMist,
            fontSize: 12.5,
          ),
        ),
      ],
    );
  }
}
