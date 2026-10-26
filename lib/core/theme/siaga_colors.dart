import 'package:flutter/material.dart';

/// Palet resmi SIAGA - ekstraksi warna lambang Kementerian Dalam Negeri.
class SiagaColors {
  const SiagaColors._();

  static const Color abyssalNavy = Color(0xFF041E34);
  static const Color kemendagriNavy = Color(0xFF093B62);
  static const Color orbNavy = Color(0xFF0D5287);
  static const Color padiGold = Color(0xFFEAA200);
  static const Color warmAmber = Color(0xFFFFC738);
  static const Color kapasEmerald = Color(0xFF247D3B);
  static const Color garudaCrimson = Color(0xFFE60000);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color silverMist = Color(0xFFE2E8F0);
  static const Color cyanGlass = Color(0xFF38BDF8);

  /// Teks lencana pada latar status.
  static const Color successText = Color(0xFFA7F0BF);
  static const Color dangerText = Color(0xFFFFB4B4);
}

/// Mode pencahayaan adaptif (lihat desain.md bagian 2.2).
enum SiagaThemeMode { spatialNavy, daylightPearl }
