import 'package:flutter/material.dart';

import '../theme/siaga_colors.dart';
import '../theme/siaga_text.dart';

enum PillTone { success, warning, danger, neutral }

/// Lencana status kapsul.
class StatusPill extends StatelessWidget {
  const StatusPill(
    this.label, {
    super.key,
    this.tone = PillTone.neutral,
    this.dot = false,
  });

  final String label;
  final PillTone tone;

  /// Titik penanda di depan teks (mis. "Belum dibaca").
  final bool dot;

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    switch (tone) {
      case PillTone.success:
        bg = SiagaColors.kapasEmerald.withValues(alpha: 0.35);
        fg = SiagaColors.successText;
      case PillTone.warning:
        bg = SiagaColors.padiGold.withValues(alpha: 0.22);
        fg = SiagaColors.warmAmber;
      case PillTone.danger:
        bg = SiagaColors.garudaCrimson.withValues(alpha: 0.28);
        fg = SiagaColors.dangerText;
      case PillTone.neutral:
        bg = SiagaColors.pureWhite.withValues(alpha: 0.10);
        fg = SiagaColors.silverMist;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: SiagaText.caption.copyWith(
              color: fg,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Pemilih segmen kapsul: segmen aktif berwarna emas.
class PillTabs extends StatelessWidget {
  const PillTabs({
    super.key,
    required this.labels,
    required this.index,
    required this.onChanged,
    this.height = 48,
  });

  final List<String> labels;
  final int index;
  final ValueChanged<int> onChanged;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: SiagaColors.abyssalNavy.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: SiagaColors.pureWhite.withValues(alpha: 0.10),
        ),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutBack,
                  height: height - 8,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: i == index
                        ? SiagaColors.padiGold
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    labels[i],
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.1,
                      fontWeight: FontWeight.w700,
                      color: i == index
                          ? SiagaColors.abyssalNavy
                          : SiagaColors.silverMist,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Kapsul kaca yang dapat dipilih (kategori kejadian).
class GlassChip extends StatelessWidget {
  const GlassChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: selected
              ? SiagaColors.padiGold.withValues(alpha: 0.28)
              : SiagaColors.pureWhite.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? SiagaColors.padiGold.withValues(alpha: 0.5)
                : SiagaColors.pureWhite.withValues(alpha: 0.12),
          ),
        ),
        child: SizedBox(
          height: 40,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selected) ...[
                const Icon(Icons.check, size: 14, color: SiagaColors.warmAmber),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: selected
                      ? SiagaColors.warmAmber
                      : SiagaColors.silverMist,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
