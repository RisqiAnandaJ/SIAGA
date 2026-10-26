import 'package:flutter/material.dart';

import '../theme/siaga_colors.dart';
import '../theme/siaga_text.dart';

/// Pratinjau foto bukti kejadian dengan bingkai kaca.
class EvidencePhoto extends StatelessWidget {
  const EvidencePhoto({
    super.key,
    this.caption = 'Foto simulasi • koridor lantai 1 • 07.18 WIB',
  });

  final String caption;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: 342 / 154,
            child: Image.asset(
              'assets/images/incident_evidence.png',
              fit: BoxFit.cover,
              semanticLabel: 'Foto bukti: genangan air di koridor lantai 1',
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(caption, style: SiagaText.bodyMuted.copyWith(fontSize: 12)),
      ],
    );
  }
}

/// Tombol geser kaca untuk check-in / check-out (mencegah ketukan tidak sengaja).
class SlideToConfirm extends StatefulWidget {
  const SlideToConfirm({
    super.key,
    required this.label,
    required this.onConfirmed,
  });

  final String label;
  final VoidCallback onConfirmed;

  @override
  State<SlideToConfirm> createState() => _SlideToConfirmState();
}

class _SlideToConfirmState extends State<SlideToConfirm> {
  static const double _thumb = 56;
  double _dx = 0;
  bool _confirmed = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final maxDx = c.maxWidth - _thumb - 8;
        return Container(
          height: 64,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: SiagaColors.pureWhite.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Stack(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(left: 40),
                  child: Text(
                    widget.label,
                    style: SiagaText.bodyLarge.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              AnimatedPositioned(
                duration: Duration(milliseconds: _dx == 0 ? 220 : 0),
                curve: Curves.easeOutBack,
                left: _dx,
                child: GestureDetector(
                  onHorizontalDragUpdate: (d) =>
                      setState(() => _dx = (_dx + d.delta.dx).clamp(0, maxDx)),
                  onHorizontalDragEnd: (_) {
                    if (_dx >= maxDx * 0.85 && !_confirmed) {
                      _confirmed = true;
                      widget.onConfirmed();
                    }
                    setState(() => _dx = 0);
                    _confirmed = false;
                  },
                  child: Semantics(
                    button: true,
                    label: widget.label,
                    child: Container(
                      width: _thumb,
                      height: _thumb,
                      decoration: const BoxDecoration(
                        color: SiagaColors.padiGold,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.keyboard_double_arrow_right,
                        color: SiagaColors.abyssalNavy,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
