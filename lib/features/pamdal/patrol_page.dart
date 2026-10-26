import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/state/session.dart';
import '../../core/theme/siaga_colors.dart';
import '../../core/theme/siaga_text.dart';
import '../../core/widgets/charts.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/list_rows.dart';
import '../../core/widgets/mini_map.dart';
import '../../core/widgets/page_scaffolds.dart';
import '../../core/widgets/radar_orb.dart';
import '../../core/widgets/siaga_buttons.dart';
import '../../core/widgets/siaga_pills.dart';
import 'patrol_history_page.dart';

/// Tab Patroli GPS: izin lokasi sebelum mulai, lalu patroli berlangsung.
class PatrolPage extends StatelessWidget {
  const PatrolPage({super.key});

  @override
  Widget build(BuildContext context) {
    final active = SessionScope.of(context).patrolActive;
    return active ? const _ActivePatrol() : const _PermissionGate();
  }
}

class _PermissionGate extends StatelessWidget {
  const _PermissionGate();

  @override
  Widget build(BuildContext context) {
    final session = SessionScope.read(context);
    return MainPage(
      title: 'Mulai patroli',
      subtitle: 'Area utama • 4 checkpoint',
      children: [
        const MiniMap(dimmed: true),
        const Align(
          alignment: Alignment.centerLeft,
          child: StatusPill('Patroli belum dimulai'),
        ),
        GlassCard(
          tone: GlassTone.raised,
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 32,
                color: SiagaColors.warmAmber,
              ),
              const SizedBox(height: 16),
              Text(
                'Izinkan lokasi saat bertugas',
                style: SiagaText.heading1.copyWith(
                  fontSize: 25,
                  color: SiagaColors.silverMist,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'SIAGA memerlukan lokasi latar belakang agar rute dan checkpoint tetap tercatat saat layar terkunci.',
                style: SiagaText.bodyLarge.copyWith(
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 8),
              const InfoRow(
                title: 'Layanan latar depan',
                subtitle:
                    'Notifikasi patroli aktif tetap terlihat selama tugas.',
                trailing: Icon(Icons.notifications_none, size: 22),
              ),
              Text(
                'Lokasi dicatat hanya selama patroli aktif. Anda dapat menghentikan patroli dan mengelola izin melalui pengaturan perangkat.',
                style: SiagaText.body.copyWith(fontSize: 13.5),
              ),
              const SizedBox(height: 20),
              SiagaButton.gold(
                label: 'Lanjutkan & izinkan lokasi',
                onPressed: () => session.setPatrolActive(true),
              ),
              const SizedBox(height: 12),
              SiagaButton.ghost(
                label: 'Batal, belum mulai patroli',
                onPressed: () => session.selectTab(0),
              ),
            ],
          ),
        ),
        SiagaButton.ghost(
          label: 'Riwayat patroli saya',
          icon: Icons.history,
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const PatrolHistoryPage()),
          ),
        ),
      ],
    );
  }
}

class _ActivePatrol extends StatefulWidget {
  const _ActivePatrol();

  @override
  State<_ActivePatrol> createState() => _ActivePatrolState();
}

class _ActivePatrolState extends State<_ActivePatrol> {
  int _seconds = 30 * 60 + 18;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _seconds++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _clock {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(_seconds ~/ 3600)}:${two(_seconds % 3600 ~/ 60)}:${two(_seconds % 60)}';
  }

  @override
  Widget build(BuildContext context) {
    final session = SessionScope.read(context);
    return MainPage(
      title: 'Patroli berlangsung',
      subtitle: 'Budi Santoso • area utama • mulai 07.12 WIB',
      children: [
        GlassCard(
          radius: 22,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              const Icon(
                Icons.verified_outlined,
                color: SiagaColors.successText,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Checkpoint terverifikasi • Area parkir',
                style: SiagaText.body.copyWith(
                  fontWeight: FontWeight.w700,
                  color: SiagaColors.pureWhite,
                ),
              ),
            ],
          ),
        ),
        Column(
          children: [
            const RadarOrb(),
            const SizedBox(height: 4),
            Text(_clock, style: SiagaText.displayLarge.copyWith(fontSize: 46)),
            const SizedBox(height: 14),
            const StatusPill('MQTT Online', tone: PillTone.success),
          ],
        ),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const InfoRow(
                title: 'GPS akurat ±8 meter',
                subtitle: '−6.2744, 106.8455 • diperbarui 07.42',
                trailing: StatusPill('Valid', tone: PillTone.success),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '3 dari 4 checkpoint tercapai',
                      style: SiagaText.bodyLarge.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const SiagaProgress(value: 0.75),
                  ],
                ),
              ),
              Divider(
                height: 1,
                color: SiagaColors.pureWhite.withValues(alpha: 0.08),
              ),
              const InfoRow(
                title: 'Berikutnya: Pos belakang',
                subtitle: 'Radius verifikasi 20 m • otomatis saat tiba',
                chevron: true,
                last: true,
              ),
            ],
          ),
        ),
        SiagaButton.ghost(
          label: 'Hentikan patroli',
          onPressed: () => session.setPatrolActive(false),
        ),
        SiagaButton.ghost(
          label: 'Riwayat patroli saya',
          icon: Icons.history,
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const PatrolHistoryPage()),
          ),
        ),
        const InfoBanner(
          title: 'Tetap terhubung',
          body:
              'Jika jaringan terputus, titik GPS disimpan dalam antrean offline lalu dikirim saat tersambung kembali.',
        ),
      ],
    );
  }
}
