import 'package:flutter/material.dart';

import '../theme/siaga_colors.dart';
import '../theme/siaga_text.dart';
import 'glass_card.dart';

/// Banner informasi emas dengan ikon "i".
class InfoBanner extends StatelessWidget {
  const InfoBanner({
    super.key,
    required this.title,
    required this.body,
    this.danger = false,
  });

  final String title;
  final String body;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final accent = danger ? SiagaColors.dangerText : SiagaColors.warmAmber;
    return GlassCard(
      tone: danger ? GlassTone.danger : GlassTone.gold,
      radius: 22,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            danger ? Icons.warning_amber_rounded : Icons.info_outline,
            size: 24,
            color: accent,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: SiagaText.bodyLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    color: SiagaColors.pureWhite,
                  ),
                ),
                const SizedBox(height: 4),
                Text(body, style: SiagaText.body.copyWith(fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Baris daftar: judul tebal, subjudul redup, lalu aksesori di kanan.
/// Garis pemisah tipis di bawah kecuali [last].
class InfoRow extends StatelessWidget {
  const InfoRow({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.last = false,
    this.chevron = false,
    this.body,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool last;

  /// Tampilkan tanda panah ">" di kanan.
  final bool chevron;

  /// Paragraf tambahan di bawah subjudul.
  final String? body;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: last
              ? null
              : Border(
                  bottom: BorderSide(
                    color: SiagaColors.pureWhite.withValues(alpha: 0.08),
                  ),
                ),
        ),
        child: Row(
          crossAxisAlignment: body != null
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: SiagaText.bodyLarge.copyWith(
                      fontWeight: FontWeight.w700,
                      color: SiagaColors.silverMist,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(subtitle!, style: SiagaText.bodyMuted),
                  ],
                  if (body != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      body!,
                      style: SiagaText.bodyLarge.copyWith(
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 12), trailing!],
            if (chevron)
              const Icon(
                Icons.chevron_right,
                size: 22,
                color: SiagaColors.silverMist,
              ),
          ],
        ),
      ),
    );
  }
}

/// Kartu statistik angka besar (bento grid 2x2).
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.value,
    required this.label,
    required this.caption,
  });

  final String value;
  final String label;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 24,
      padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: SiagaText.displayLarge.copyWith(
              color: SiagaColors.warmAmber,
              fontSize: 30,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: SiagaText.bodyLarge.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(caption, style: SiagaText.bodyMuted.copyWith(fontSize: 11.5)),
        ],
      ),
    );
  }
}

/// Kolom dengan jarak tetap antaranak (selaras dengan jarak [MainPage]).
class SpacedColumn extends StatelessWidget {
  const SpacedColumn({super.key, required this.children, this.gap = 18});

  final List<Widget> children;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          children[i],
          if (i < children.length - 1) SizedBox(height: gap),
        ],
      ],
    );
  }
}

/// Grid 2x2 untuk empat [StatTile].
class StatGrid extends StatelessWidget {
  const StatGrid({super.key, required this.tiles});

  final List<StatTile> tiles;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < tiles.length; i += 2) ...[
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: tiles[i]),
                const SizedBox(width: 12),
                Expanded(
                  child: i + 1 < tiles.length ? tiles[i + 1] : const SizedBox(),
                ),
              ],
            ),
          ),
          if (i + 2 < tiles.length) const SizedBox(height: 12),
        ],
      ],
    );
  }
}
