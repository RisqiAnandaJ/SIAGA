import 'package:flutter/material.dart';

import '../theme/siaga_colors.dart';
import '../theme/siaga_text.dart';

/// Lingkaran radar kaca hijau dengan cincin konsentris berdenyut:
/// menandakan telemetri GPS & MQTT sedang aktif.
class RadarOrb extends StatefulWidget {
  const RadarOrb({super.key, this.size = 160});

  final double size;

  @override
  State<RadarOrb> createState() => _RadarOrbState();
}

class _RadarOrbState extends State<RadarOrb>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ripple = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  )..repeat();

  @override
  void dispose() {
    _ripple.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final outer = widget.size * 1.3;
    return SizedBox(
      width: outer,
      height: outer,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _ripple,
            builder: (_, _) => CustomPaint(
              size: Size.square(outer),
              painter: _RipplePainter(_ripple.value, widget.size),
            ),
          ),
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: SiagaColors.kapasEmerald.withValues(alpha: 0.28),
              border: Border.all(
                color: SiagaColors.successText.withValues(alpha: 0.45),
                width: 1.4,
              ),
            ),
          ),
          Container(
            width: widget.size * 0.78,
            height: widget.size * 0.78,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: SiagaColors.successText.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.radar,
                  size: 38,
                  color: SiagaColors.successText,
                ),
                const SizedBox(height: 14),
                Text(
                  'PATROLI AKTIF',
                  style: SiagaText.caption.copyWith(
                    fontWeight: FontWeight.w800,
                    color: SiagaColors.silverMist,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RipplePainter extends CustomPainter {
  _RipplePainter(this.t, this.core);

  final double t;
  final double core;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final maxR = size.width / 2;
    for (var i = 0; i < 3; i++) {
      final p = (t + i / 3) % 1;
      final radius = core / 2 + (maxR - core / 2) * p;
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..color = SiagaColors.kapasEmerald.withValues(alpha: 0.55 * (1 - p)),
      );
    }
  }

  @override
  bool shouldRepaint(_RipplePainter old) => old.t != t;
}
