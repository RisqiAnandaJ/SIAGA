import 'package:flutter/material.dart';

import '../theme/siaga_colors.dart';
import '../theme/siaga_text.dart';

/// Kolom isian kaca dengan label di atasnya.
class GlassField extends StatefulWidget {
  const GlassField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.initialValue,
    this.icon,
    this.obscure = false,
    this.maxLines = 1,
    this.keyboardType,
    this.readOnly = false,
    this.onTap,
    this.prefix,
    this.errorText,
    this.helper,
    this.onChanged,
  });

  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final String? initialValue;
  final IconData? icon;

  /// Menampilkan ikon tampil/sembunyikan password.
  final bool obscure;
  final int maxLines;
  final TextInputType? keyboardType;
  final bool readOnly;
  final VoidCallback? onTap;
  final String? prefix;
  final String? errorText;
  final String? helper;
  final ValueChanged<String>? onChanged;

  @override
  State<GlassField> createState() => _GlassFieldState();
}

class _GlassFieldState extends State<GlassField> {
  late bool _hidden = widget.obscure;
  late final TextEditingController _controller =
      widget.controller ?? TextEditingController(text: widget.initialValue);

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final multiline = widget.maxLines > 1;
    final trailing = widget.obscure
        ? GestureDetector(
            onTap: () => setState(() => _hidden = !_hidden),
            child: Icon(
              _hidden
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              size: 22,
              color: SiagaColors.silverMist,
            ),
          )
        : (widget.icon != null
              ? Icon(widget.icon, size: 22, color: SiagaColors.silverMist)
              : null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(widget.label!, style: SiagaText.label),
          const SizedBox(height: 8),
        ],
        Container(
          constraints: BoxConstraints(minHeight: multiline ? 96 : 54),
          padding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: multiline ? 14 : 0,
          ),
          decoration: BoxDecoration(
            color: SiagaColors.abyssalNavy.withValues(alpha: 0.50),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.errorText != null
                  ? SiagaColors.garudaCrimson
                  : SiagaColors.pureWhite.withValues(alpha: 0.10),
            ),
          ),
          child: Row(
            crossAxisAlignment: multiline
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              if (widget.prefix != null) ...[
                Text(
                  '${widget.prefix}  •',
                  style: SiagaText.bodyLarge.copyWith(
                    color: SiagaColors.silverMist.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: TextField(
                  controller: _controller,
                  obscureText: _hidden,
                  maxLines: widget.obscure ? 1 : widget.maxLines,
                  keyboardType: widget.keyboardType,
                  readOnly: widget.readOnly,
                  onTap: widget.onTap,
                  onChanged: widget.onChanged,
                  cursorColor: SiagaColors.warmAmber,
                  style: SiagaText.bodyLarge.copyWith(
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: widget.hint,
                    hintStyle: SiagaText.bodyLarge.copyWith(
                      fontWeight: FontWeight.w400,
                      color: SiagaColors.silverMist.withValues(alpha: 0.75),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: multiline ? 0 : 16,
                    ),
                  ),
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 10),
                Padding(
                  padding: EdgeInsets.only(top: multiline ? 2 : 0),
                  child: trailing,
                ),
              ],
            ],
          ),
        ),
        if (widget.errorText != null) ...[
          const SizedBox(height: 6),
          Text(
            widget.errorText!,
            style: SiagaText.bodyMuted.copyWith(color: SiagaColors.dangerText),
          ),
        ] else if (widget.helper != null) ...[
          const SizedBox(height: 8),
          Text(
            widget.helper!,
            style: SiagaText.bodyMuted.copyWith(fontSize: 12),
          ),
        ],
      ],
    );
  }
}

/// Pemilih bergaya dropdown (hanya tampilan; menampilkan nilai terpilih).
class GlassSelect extends StatelessWidget {
  const GlassSelect({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.icon = Icons.keyboard_arrow_down,
  });

  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: SiagaText.label),
        const SizedBox(height: 8),
        PopupMenuButton<String>(
          onSelected: onChanged,
          color: const Color(0xFF0A3E68),
          position: PopupMenuPosition.under,
          itemBuilder: (_) => [
            for (final o in options)
              PopupMenuItem(
                value: o,
                child: Text(o, style: SiagaText.body),
              ),
          ],
          child: Container(
            height: 54,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: SiagaColors.abyssalNavy.withValues(alpha: 0.50),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: SiagaColors.pureWhite.withValues(alpha: 0.10),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    overflow: TextOverflow.ellipsis,
                    style: SiagaText.bodyLarge.copyWith(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                Icon(icon, size: 22, color: SiagaColors.silverMist),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
