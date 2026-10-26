import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/siaga_colors.dart';
import '../theme/siaga_text.dart';

/// Nada kaca: menentukan warna isian dan tepi.
enum GlassTone { normal, raised, gold, danger, success }

/// Kartu kaca Liquid Glass. Secara bawaan statis (tanpa BackdropFilter) agar
/// aman dipakai di daftar panjang; setel [blur] hanya untuk elemen melayang.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.radius = 28,
    this.tone = GlassTone.normal,
    this.blur = false,
    this.blurSigma = 24,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final GlassTone tone;
  final bool blur;
  final double blurSigma;

  List<Color> get _fill {
    switch (tone) {
      case GlassTone.raised:
        return [
          const Color(0xFF0E4A7A).withValues(alpha: 0.78),
          const Color(0xFF0A3E68).withValues(alpha: 0.70),
        ];
      case GlassTone.gold:
        return [
          SiagaColors.padiGold.withValues(alpha: 0.16),
          SiagaColors.padiGold.withValues(alpha: 0.06),
        ];
      case GlassTone.danger:
        return [
          SiagaColors.garudaCrimson.withValues(alpha: 0.22),
          SiagaColors.garudaCrimson.withValues(alpha: 0.08),
        ];
      case GlassTone.success:
        return [
          SiagaColors.kapasEmerald.withValues(alpha: 0.38),
          SiagaColors.kapasEmerald.withValues(alpha: 0.18),
        ];
      case GlassTone.normal:
        return [
          SiagaColors.pureWhite.withValues(alpha: 0.14),
          SiagaColors.pureWhite.withValues(alpha: 0.05),
        ];
    }
  }

  Color get _rim {
    switch (tone) {
      case GlassTone.gold:
        return SiagaColors.padiGold.withValues(alpha: 0.35);
      case GlassTone.danger:
        return SiagaColors.garudaCrimson.withValues(alpha: 0.35);
      case GlassTone.success:
        return SiagaColors.successText.withValues(alpha: 0.28);
      default:
        return SiagaColors.pureWhite.withValues(alpha: 0.24);
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius);
    final surface = Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _fill,
        ),
        border: Border.all(color: _rim, width: 1.1),
      ),
      child: child,
    );

    if (!blur) return surface;

    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: surface,
        ),
      ),
    );
  }
}

/// Kartu kaca berjudul: judul 20px lalu isi.
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    this.title,
    required this.children,
    this.tone = GlassTone.normal,
    this.titleGap = 14,
    this.trailing,
  });

  final String? title;
  final List<Widget> children;
  final GlassTone tone;
  final double titleGap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      tone: tone,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Padding(
              padding: EdgeInsets.only(bottom: titleGap),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title!,
                      style: SiagaText.heading2.copyWith(fontSize: 20),
                    ),
                  ),
                  ?trailing,
                ],
              ),
            ),
          ...children,
        ],
      ),
    );
  }
}
