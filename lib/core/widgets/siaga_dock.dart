import 'package:flutter/material.dart';

import '../state/session.dart';
import '../theme/siaga_colors.dart';
import 'glass_card.dart';

class DockItem {
  const DockItem(this.icon, this.label);

  final IconData icon;
  final String label;
}

/// Susunan tab bawah per peran (desain.md bagian 5.1).
List<DockItem> dockItemsFor(UserRole role) => switch (role) {
  UserRole.pamdal => const [
    DockItem(Icons.home_outlined, 'Beranda'),
    DockItem(Icons.calendar_month_outlined, 'Absensi & Jadwal'),
    DockItem(Icons.radar, 'Patroli GPS'),
    DockItem(Icons.warning_amber_rounded, 'Insiden'),
  ],
  UserRole.picPamdal => const [
    DockItem(Icons.dashboard_outlined, 'Dashboard'),
    DockItem(Icons.calendar_month_outlined, 'Operasional'),
    DockItem(Icons.warning_amber_rounded, 'Insiden'),
    DockItem(Icons.groups_outlined, 'Personel'),
    DockItem(Icons.description_outlined, 'Laporan'),
  ],
  UserRole.pimpinan => const [
    DockItem(Icons.bar_chart_rounded, 'Ringkasan'),
    DockItem(Icons.visibility_outlined, 'Monitoring'),
    DockItem(Icons.warning_amber_rounded, 'Insiden'),
    DockItem(Icons.description_outlined, 'Laporan PDF'),
  ],
};

/// Kapsul kaca melayang. Item aktif berpendar emas dan bergeser dengan pegas.
class SiagaDock extends StatelessWidget {
  const SiagaDock({
    super.key,
    required this.items,
    required this.index,
    required this.onTap,
  });

  final List<DockItem> items;
  final int index;
  final ValueChanged<int> onTap;

  /// Jarak bawah yang perlu disisakan konten agar tidak tertutup dock.
  static const double reservedHeight = 120;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: GlassCard(
        blur: true,
        blurSigma: 36,
        radius: 36,
        tone: GlassTone.raised,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        child: Row(
          children: [
            for (var i = 0; i < items.length; i++)
              Expanded(
                child: _DockButton(
                  item: items[i],
                  active: i == index,
                  onTap: () => onTap(i),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DockButton extends StatelessWidget {
  const _DockButton({
    required this.item,
    required this.active,
    required this.onTap,
  });

  final DockItem item;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? SiagaColors.warmAmber : SiagaColors.silverMist;
    return Semantics(
      button: true,
      selected: active,
      label: item.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutBack,
          height: 60,
          decoration: BoxDecoration(
            color: active
                ? SiagaColors.padiGold.withValues(alpha: 0.14)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(item.icon, size: 24, color: color),
              const SizedBox(height: 4),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10.5,
                  height: 1.1,
                  color: color,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
