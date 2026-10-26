import 'package:flutter/material.dart';

import '../theme/siaga_colors.dart';
import '../theme/siaga_text.dart';

/// Skema rute patroli (ilustratif, bukan peta geografis).
class MiniMap extends StatelessWidget {
  const MiniMap({
    super.key,
    this.height = 208,
    this.dimmed = false,
    this.caption = 'SKEMA ILUSTRATIF • BUKAN PETA GEOGRAFIS',
  });

  final double height;

  /// Versi redup untuk layar sebelum patroli dimulai.
  final bool dimmed;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: dimmed ? 0.55 : 1,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: SiagaColors.kemendagriNavy.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: SiagaColors.pureWhite.withValues(alpha: 0.10),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(painter: _MapPainter(dimmed: dimmed)),
              ),
              Positioned(
                left: 16,
                bottom: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: SiagaColors.abyssalNavy.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    caption,
                    style: SiagaText.caption.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: SiagaColors.silverMist.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  const _MapPainter({required this.dimmed});

  final bool dimmed;

  Offset _p(Size s, double x, double y) => Offset(s.width * x, s.height * y);

  @override
  void paint(Canvas canvas, Size size) {
    final road = Paint()..color = SiagaColors.pureWhite.withValues(alpha: 0.07);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(size.width * 0.33, 0, size.width * 0.47, size.height),
        const Radius.circular(10),
      ),
      road,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(
          size.width * 0.07,
          size.height * 0.33,
          size.width * 0.86,
          size.height * 0.54,
        ),
        const Radius.circular(12),
      ),
      road,
    );

    final line = Paint()
      ..color = SiagaColors.warmAmber.withValues(alpha: dimmed ? 0.6 : 1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.square
      ..strokeJoin = StrokeJoin.miter;

    final route = Path()
      ..moveTo(_p(size, 0.11, 0.71).dx, _p(size, 0.11, 0.71).dy)
      ..lineTo(_p(size, 0.11, 0.44).dx, _p(size, 0.11, 0.44).dy)
      ..lineTo(_p(size, 0.41, 0.44).dx, _p(size, 0.41, 0.44).dy)
      ..lineTo(_p(size, 0.41, 0.18).dx, _p(size, 0.41, 0.18).dy)
      ..lineTo(_p(size, 0.74, 0.18).dx, _p(size, 0.74, 0.18).dy);
    canvas.drawPath(route, line);

    final back = Path()
      ..moveTo(_p(size, 0.795, 0.18).dx, _p(size, 0.795, 0.18).dy)
      ..lineTo(_p(size, 0.795, 0.71).dx, _p(size, 0.795, 0.71).dy)
      ..lineTo(_p(size, 0.60, 0.71).dx, _p(size, 0.60, 0.71).dy);
    canvas.drawPath(back, line);

    void node(Offset c, Color fill) {
      canvas.drawCircle(c, 9, Paint()..color = fill);
      canvas.drawCircle(
        c,
        9,
        Paint()
          ..color = SiagaColors.warmAmber
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6,
      );
    }

    node(_p(size, 0.11, 0.71), SiagaColors.kapasEmerald);
    node(_p(size, 0.40, 0.44), SiagaColors.kapasEmerald);
    node(_p(size, 0.76, 0.18), SiagaColors.padiGold);
  }

  @override
  bool shouldRepaint(_MapPainter old) => old.dimmed != dimmed;
}
