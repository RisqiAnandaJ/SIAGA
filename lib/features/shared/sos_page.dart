import 'package:flutter/material.dart';

import '../../core/constants/emergency_contacts.dart';
import '../../core/theme/siaga_colors.dart';
import '../../core/theme/siaga_text.dart';
import '../../core/widgets/app_background.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/list_rows.dart';
import '../../core/widgets/siaga_buttons.dart';
import '../../core/widgets/siaga_pills.dart';

/// Lembar darurat layar penuh: tiga layanan dengan tombol besar.
class SosPage extends StatelessWidget {
  const SosPage({super.key});

  void _unavailable(BuildContext context, String what) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$what belum tersedia: kontak resmi menunggu konfirmasi BPSDM.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        danger: true,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
            children: [
              Row(
                children: [
                  Text('SIAGA / BERSAMA', style: SiagaText.eyebrow),
                  const Spacer(),
                  InkResponse(
                    onTap: Navigator.of(context).maybePop,
                    radius: 24,
                    child: const SizedBox(
                      width: 44,
                      height: 36,
                      child: Icon(
                        Icons.arrow_back,
                        color: SiagaColors.pureWhite,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'Darurat SOS',
                style: SiagaText.heading1.copyWith(fontSize: 26),
              ),
              const SizedBox(height: 8),
              Text(
                'Tetap tenang. Pilih layanan yang sesuai.',
                style: SiagaText.bodyMuted,
              ),
              const SizedBox(height: 14),
              const Align(
                alignment: Alignment.centerLeft,
                child: StatusPill('Akses darurat', tone: PillTone.danger),
              ),
              const SizedBox(height: 18),
              for (final c in emergencyContacts) ...[
                _EmergencyCard(
                  contact: c,
                  onCall: () => c.phone == null
                      ? _unavailable(context, 'Panggilan')
                      : null,
                  onMap: () =>
                      c.mapQuery == null ? _unavailable(context, 'Peta') : null,
                ),
                const SizedBox(height: 16),
              ],
              const InfoBanner(
                danger: true,
                title: 'Gunakan secara bertanggung jawab',
                body:
                    'Verifikasi ketersediaan layanan dan kontak resmi sebelum menghubungi. Nomor dan alamat tidak ditampilkan; tombol merupakan representasi visual, bukan panggilan aktif.',
              ),
              const SizedBox(height: 16),
              SiagaButton.ghost(
                label: 'Tutup SOS & kembali',
                icon: Icons.close,
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmergencyCard extends StatelessWidget {
  const _EmergencyCard({
    required this.contact,
    required this.onCall,
    required this.onMap,
  });

  final EmergencyContact contact;
  final VoidCallback onCall;
  final VoidCallback onMap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(contact.icon, size: 28, color: SiagaColors.dangerText),
              const SizedBox(width: 12),
              Text(
                contact.name,
                style: SiagaText.heading1.copyWith(
                  fontSize: 24,
                  color: SiagaColors.silverMist,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            contact.description,
            style: SiagaText.body.copyWith(fontSize: 13.5),
          ),
          const SizedBox(height: 14),
          SiagaButton.danger(
            label: 'Panggil Sekarang',
            icon: Icons.phone_outlined,
            height: 56,
            onPressed: onCall,
          ),
          const SizedBox(height: 12),
          SiagaButton.ghost(
            label: 'Buka Peta',
            icon: Icons.location_on_outlined,
            onPressed: onMap,
          ),
        ],
      ),
    );
  }
}
