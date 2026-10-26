import 'package:flutter/material.dart';

import 'siaga_colors.dart';

/// Hierarki tipografi SIAGA (desain.md bagian 4).
class SiagaText {
  const SiagaText._();

  static const List<FontFeature> tabular = [FontFeature.tabularFigures()];

  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: SiagaColors.silverMist,
    fontFeatures: tabular,
  );

  static const TextStyle heading1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.25,
    color: SiagaColors.pureWhite,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: SiagaColors.silverMist,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.45,
    color: SiagaColors.silverMist,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.45,
    color: SiagaColors.silverMist,
  );

  static const TextStyle bodyMuted = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: Color(0xB3E2E8F0),
  );

  static const TextStyle label = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: SiagaColors.silverMist,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.2,
    color: SiagaColors.silverMist,
    fontFeatures: tabular,
  );

  static const TextStyle eyebrow = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.4,
    color: SiagaColors.padiGold,
  );
}
