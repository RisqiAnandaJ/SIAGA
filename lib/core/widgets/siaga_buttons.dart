import 'package:flutter/material.dart';

import '../theme/siaga_colors.dart';

enum SiagaButtonKind { gold, ghost, danger }

/// Tombol kapsul penuh. Tinggi minimum 52 dp (>= 48 dp target sentuh).
class SiagaButton extends StatelessWidget {
  const SiagaButton._(
    this.kind, {
    required this.label,
    required this.onPressed,
    this.icon,
    this.height = 52,
  });

  /// Tombol aksi utama bergradien Padi Gold.
  const SiagaButton.gold({
    Key? key,
    required String label,
    required VoidCallback? onPressed,
    IconData? icon,
    double height = 52,
  }) : this._(
         SiagaButtonKind.gold,
         label: label,
         onPressed: onPressed,
         icon: icon,
         height: height,
       );

  /// Tombol sekunder kaca.
  const SiagaButton.ghost({
    Key? key,
    required String label,
    required VoidCallback? onPressed,
    IconData? icon,
    double height = 52,
  }) : this._(
         SiagaButtonKind.ghost,
         label: label,
         onPressed: onPressed,
         icon: icon,
         height: height,
       );

  /// Tombol destruktif / darurat Garuda Crimson.
  const SiagaButton.danger({
    Key? key,
    required String label,
    required VoidCallback? onPressed,
    IconData? icon,
    double height = 52,
  }) : this._(
         SiagaButtonKind.danger,
         label: label,
         onPressed: onPressed,
         icon: icon,
         height: height,
       );

  final SiagaButtonKind kind;
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double height;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final Color fg;
    final BoxDecoration decoration;
    switch (kind) {
      case SiagaButtonKind.gold:
        fg = SiagaColors.abyssalNavy;
        decoration = const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(999)),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [SiagaColors.warmAmber, SiagaColors.padiGold],
          ),
        );
      case SiagaButtonKind.danger:
        fg = SiagaColors.pureWhite;
        decoration = const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(999)),
          color: SiagaColors.garudaCrimson,
        );
      case SiagaButtonKind.ghost:
        fg = SiagaColors.pureWhite;
        decoration = BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(999)),
          color: SiagaColors.pureWhite.withValues(alpha: 0.08),
          border: Border.all(
            color: SiagaColors.pureWhite.withValues(alpha: 0.22),
          ),
        );
    }

    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          height: height,
          decoration: decoration,
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: onPressed,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 22, color: fg),
                    const SizedBox(width: 12),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: fg,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Tautan teks kecil (mis. "Lupa password?").
class SiagaTextLink extends StatelessWidget {
  const SiagaTextLink({
    super.key,
    required this.label,
    required this.onTap,
    this.color = SiagaColors.warmAmber,
    this.fontSize = 13,
  });

  final String label;
  final VoidCallback onTap;
  final Color color;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
