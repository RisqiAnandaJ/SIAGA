import 'package:flutter/material.dart';

/// Layanan darurat Panic Button. Data kontak wajib tersedia lokal agar tetap
/// dapat dipakai tanpa internet.
class EmergencyContact {
  const EmergencyContact({
    required this.name,
    required this.description,
    required this.icon,
    this.phone,
    this.mapQuery,
  });

  final String name;
  final String description;
  final IconData icon;

  /// Nomor telepon resmi; `null` sampai dikonfirmasi BPSDM.
  final String? phone;

  /// Kueri peta (`geo:`); `null` sampai alamat resmi dikonfirmasi.
  final String? mapQuery;
}

// TODO(Konfirmasi-BPSDM): isi nomor telepon dan alamat resmi ketiga layanan
// sebelum fitur panggilan (`tel:`) dan peta (`geo:`) diaktifkan.
const List<EmergencyContact> emergencyContacts = [
  EmergencyContact(
    name: 'RS JMC',
    description: 'Bantuan medis & kegawatdaruratan',
    icon: Icons.monitor_heart_outlined,
  ),
  EmergencyContact(
    name: 'Polsek Pancoran',
    description: 'Bantuan keamanan & kepolisian',
    icon: Icons.shield_outlined,
  ),
  EmergencyContact(
    name: 'Damkar Kalibata',
    description: 'Kebakaran & penyelamatan',
    icon: Icons.local_fire_department_outlined,
  ),
];
