import 'package:flutter/material.dart';

import '../theme/siaga_colors.dart';

/// Kanvas Abyssal Navy dengan tiga bola pendaran (mesh orbs).
class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child, this.danger = false});

  final Widget child;

  /// Rona merah tua untuk lembar darurat SOS.
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: SiagaColors.abyssalNavy),
        const _Orb(
          alignment: Alignment(-1.0, -0.85),
          color: SiagaColors.orbNavy,
          alpha: 0.55,
          size: 620,
        ),
        _Orb(
          alignment: const Alignment(1.2, 0.1),
          color: danger ? SiagaColors.garudaCrimson : SiagaColors.padiGold,
          alpha: danger ? 0.22 : 0.10,
          size: 560,
        ),
        _Orb(
          alignment: const Alignment(-0.2, 1.3),
          color: danger ? SiagaColors.garudaCrimson : SiagaColors.kapasEmerald,
          alpha: danger ? 0.25 : 0.12,
          size: 560,
        ),
        child,
      ],
    );
  }
}

class _Orb extends StatelessWidget {
  const _Orb({
    required this.alignment,
    required this.color,
    required this.alpha,
    required this.size,
  });

  final Alignment alignment;
  final Color color;
  final double alpha;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Align(
        alignment: alignment,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                color.withValues(alpha: alpha),
                color.withValues(alpha: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
