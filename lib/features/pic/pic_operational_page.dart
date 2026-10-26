import 'package:flutter/material.dart';

import '../../core/widgets/page_scaffolds.dart';
import '../../core/widgets/siaga_pills.dart';
import 'pic_attendance_section.dart';
import 'pic_patrol_section.dart';
import 'pic_schedule_section.dart';

/// Operasional PIC: jadwal, absensi, dan patroli dalam satu halaman bertab.
class PicOperationalPage extends StatefulWidget {
  const PicOperationalPage({super.key});

  @override
  State<PicOperationalPage> createState() => _PicOperationalPageState();
}

class _PicOperationalPageState extends State<PicOperationalPage> {
  int _tab = 0;

  static const _titles = [
    'Kelola jadwal jaga',
    'Kelola absensi',
    'Pantau patroli',
  ];
  static const _subtitles = [
    '23 Oktober 2026 • 3 shift terjadwal',
    'Seluruh personel • 23 Oktober 2026',
    '4 sesi aktif • diperbarui 07.42 WIB',
  ];

  @override
  Widget build(BuildContext context) {
    return MainPage(
      title: _titles[_tab],
      subtitle: _subtitles[_tab],
      children: [
        PillTabs(
          labels: const ['Jadwal', 'Absensi', 'Patroli'],
          index: _tab,
          onChanged: (i) => setState(() => _tab = i),
        ),
        ...switch (_tab) {
          0 => const [PicScheduleSection()],
          1 => const [PicAttendanceSection()],
          _ => const [PicPatrolSection()],
        },
      ],
    );
  }
}
