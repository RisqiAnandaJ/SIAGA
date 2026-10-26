import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/siaga_text.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/list_rows.dart';
import '../../core/widgets/media_widgets.dart';
import '../../core/widgets/page_scaffolds.dart';
import '../../core/widgets/siaga_fields.dart';
import '../../core/widgets/siaga_pills.dart';
import '../../core/theme/siaga_colors.dart';

/// Absensi pribadi dan jadwal jaga dalam satu halaman bertab.
class AbsensiJadwalPage extends StatefulWidget {
  const AbsensiJadwalPage({super.key});

  @override
  State<AbsensiJadwalPage> createState() => _AbsensiJadwalPageState();
}

class _AbsensiJadwalPageState extends State<AbsensiJadwalPage> {
  int _tab = 0;
  bool _checkedOut = false;
  late DateTime _now = DateTime.now();
  Timer? _clock;

  @override
  void initState() {
    super.initState();
    _clock = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _clock?.cancel();
    super.dispose();
  }

  String get _time {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(_now.hour)}:${two(_now.minute)}:${two(_now.second)}';
  }

  @override
  Widget build(BuildContext context) {
    return MainPage(
      title: _tab == 0 ? 'Absensi saya' : 'Jadwal jaga',
      subtitle: _tab == 0
          ? 'Jumat, 23 Oktober 2026'
          : '20 personel • Jumat, 23 Oktober 2026',
      children: [
        PillTabs(
          labels: const ['Absensi', 'Jadwal Jaga'],
          index: _tab,
          onChanged: (i) => setState(() => _tab = i),
        ),
        if (_tab == 0) ..._attendance() else ..._schedule(),
      ],
    );
  }

  List<Widget> _attendance() => [
    GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                Text('Waktu perangkat • WIB', style: SiagaText.body),
                const SizedBox(height: 10),
                Text(
                  _time,
                  style: SiagaText.displayLarge.copyWith(fontSize: 46),
                ),
                const SizedBox(height: 14),
                Text(
                  'Shift pagi • 07.00–15.00',
                  style: SiagaText.body.copyWith(fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          StatusPill(
            _checkedOut ? 'Sudah check-out' : 'Sudah check-in • 06.54',
            tone: PillTone.success,
          ),
          const SizedBox(height: 16),
          GlassCard(
            tone: GlassTone.normal,
            radius: 22,
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.verified_user_outlined,
                  color: SiagaColors.successText,
                  size: 26,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'GPS tervalidasi',
                        style: SiagaText.bodyLarge.copyWith(
                          fontWeight: FontWeight.w700,
                          color: SiagaColors.pureWhite,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Akurasi ±8 m • berada di area tugas.\nPemeriksaan anti-fake-GPS: aman.',
                        style: SiagaText.body.copyWith(fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SlideToConfirm(
            label: _checkedOut ? 'Check-out tercatat' : 'Geser untuk check-out',
            onConfirmed: () {
              if (_checkedOut) return;
              setState(() => _checkedOut = true);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Check-out tercatat pukul $_time WIB.')),
              );
            },
          ),
          const SizedBox(height: 12),
          Text(
            'Check-out dicatat sesuai waktu dan lokasi saat konfirmasi.',
            style: SiagaText.bodyMuted.copyWith(fontSize: 12),
          ),
        ],
      ),
    ),
    const SectionCard(
      title: 'Riwayat absensi pribadi',
      children: [
        InfoRow(
          title: 'Hari ini • 23 Oktober',
          subtitle: 'Masuk 06.54 • Pulang belum tercatat',
          trailing: StatusPill('Hadir', tone: PillTone.success),
        ),
        InfoRow(
          title: 'Kamis, 22 Oktober',
          subtitle: '06.52–15.03 • Shift pagi',
          trailing: StatusPill('Hadir', tone: PillTone.success),
        ),
        InfoRow(
          title: 'Rabu, 21 Oktober',
          subtitle: '06.55–15.01 • Shift pagi',
          trailing: StatusPill('Hadir', tone: PillTone.success),
          last: true,
        ),
      ],
    ),
  ];

  List<Widget> _schedule() => [
    const GlassSelect(
      label: 'Tanggal tugas',
      value: '23 Oktober 2026',
      options: ['23 Oktober 2026'],
      onChanged: _noop,
      icon: Icons.calendar_month_outlined,
    ),
    const _ShiftCard(
      title: '07.00–15.00 • Shift pagi',
      badge: 'Sedang berlangsung • 7 personel',
      active: true,
      people: [
        ('Budi Santoso • Anda', 'Pos utama • koordinator shift', 'Hadir'),
        ('Agus Setiawan', 'Gedung utama', 'Hadir'),
        ('Siti Rahma', 'Area parkir • check-in 07.09', 'Terlambat'),
        ('Luki Saputra', 'Pos belakang', 'Hadir'),
        ('Wahyu Prasetyo', 'Akses tamu', 'Hadir'),
        ('Eko Prabowo', 'Gedung pendukung', 'Hadir'),
        ('Rudi Hartono', 'Area layanan', 'Hadir'),
      ],
    ),
    const _ShiftCard(
      title: '15.00–23.00 • Shift sore',
      badge: '7 personel',
      people: [
        ('Hendra Wijaya', 'Pos utama • koordinator shift', null),
        ('Dewi Lestari', 'Gedung utama', null),
        ('Bayu Saptono', 'Area parkir', null),
        ('Yoga Saputra', 'Pos belakang', null),
        ('Indra Permana', 'Akses tamu', null),
        ('Nia Puspita', 'Gedung pendukung', null),
        ('Taufik Hidayat', 'Area layanan', null),
      ],
    ),
    const _ShiftCard(
      title: '23.00–07.00 • Shift malam',
      badge: '6 personel • berakhir 24 Oktober',
      people: [
        ('Fajar Nugroho', 'Pos utama • koordinator shift', null),
        ('Rizal Hidayat', 'Area parkir', null),
        ('Deni Kurniawan', 'Gedung utama', null),
        ('Andi Firmansyah', 'Pos belakang', null),
        ('Ilham Ramadhan', 'Gedung pendukung', null),
        ('Putra Aditya', 'Akses tamu', null),
      ],
    ),
    Text(
      'Jadwal dapat dilihat seluruh PAMDAL. Perubahan hanya oleh PIC PAMDAL.',
      style: SiagaText.bodyMuted.copyWith(
        color: SiagaColors.silverMist,
        fontSize: 12.5,
      ),
    ),
  ];
}

void _noop(String _) {}

class _ShiftCard extends StatelessWidget {
  const _ShiftCard({
    required this.title,
    required this.badge,
    required this.people,
    this.active = false,
  });

  final String title;
  final String badge;
  final bool active;
  final List<(String, String, String?)> people;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      tone: active ? GlassTone.gold : GlassTone.normal,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: SiagaText.heading2.copyWith(fontSize: 20)),
          const SizedBox(height: 12),
          StatusPill(badge, tone: active ? PillTone.warning : PillTone.neutral),
          const SizedBox(height: 8),
          for (var i = 0; i < people.length; i++)
            InfoRow(
              title: people[i].$1,
              subtitle: people[i].$2,
              last: i == people.length - 1,
              chevron: people[i].$3 == null,
              trailing: people[i].$3 == null
                  ? null
                  : StatusPill(
                      people[i].$3!,
                      tone: people[i].$3 == 'Hadir'
                          ? PillTone.success
                          : PillTone.warning,
                    ),
            ),
        ],
      ),
    );
  }
}
