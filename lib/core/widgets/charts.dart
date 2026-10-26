import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../theme/siaga_colors.dart';
import '../theme/siaga_text.dart';

class ComparePoint {
  const ComparePoint(this.label, this.primary, this.secondary);

  final String label;
  final double primary;
  final double secondary;
}

/// Grafik kolom berpasangan (data utama emas, pembanding cyan) memakai
/// Syncfusion Charts dengan latar transparan dan kisi sangat tipis.
class CompareColumnChart extends StatelessWidget {
  const CompareColumnChart({
    super.key,
    required this.data,
    required this.primaryLabel,
    required this.secondaryLabel,
    this.height = 150,
  });

  final List<ComparePoint> data;
  final String primaryLabel;
  final String secondaryLabel;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _Legend(color: SiagaColors.warmAmber, label: primaryLabel),
            const SizedBox(width: 120),
            _Legend(color: SiagaColors.cyanGlass, label: secondaryLabel),
          ],
        ),
        SizedBox(
          height: height,
          child: SfCartesianChart(
            backgroundColor: Colors.transparent,
            plotAreaBorderWidth: 0,
            margin: const EdgeInsets.only(top: 10),
            primaryXAxis: CategoryAxis(
              majorGridLines: const MajorGridLines(width: 0),
              axisLine: const AxisLine(width: 0),
              majorTickLines: const MajorTickLines(size: 0),
              labelStyle: SiagaText.caption.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w400,
              ),
            ),
            primaryYAxis: NumericAxis(
              isVisible: false,
              minimum: 0,
              maximum: 110,
              majorGridLines: MajorGridLines(
                width: 1,
                color: SiagaColors.pureWhite.withValues(alpha: 0.06),
              ),
            ),
            series: <CartesianSeries<ComparePoint, String>>[
              ColumnSeries<ComparePoint, String>(
                dataSource: data,
                xValueMapper: (p, _) => p.label,
                yValueMapper: (p, _) => p.primary,
                width: 0.28,
                spacing: 0.25,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(6),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    SiagaColors.warmAmber,
                    SiagaColors.padiGold.withValues(alpha: 0.05),
                  ],
                ),
              ),
              ColumnSeries<ComparePoint, String>(
                dataSource: data,
                xValueMapper: (p, _) => p.label,
                yValueMapper: (p, _) => p.secondary,
                width: 0.28,
                spacing: 0.25,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(6),
                ),
                color: SiagaColors.cyanGlass,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: SiagaText.caption.copyWith(fontWeight: FontWeight.w400),
        ),
      ],
    );
  }
}

/// Batang progres kapsul tipis.
class SiagaProgress extends StatelessWidget {
  const SiagaProgress({
    super.key,
    required this.value,
    this.color = SiagaColors.kapasEmerald,
    this.height = 8,
  });

  final double value;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: Stack(
        children: [
          Container(
            height: height,
            color: SiagaColors.pureWhite.withValues(alpha: 0.10),
          ),
          FractionallySizedBox(
            widthFactor: value.clamp(0, 1),
            child: Container(height: height, color: color),
          ),
        ],
      ),
    );
  }
}

/// Baris batang horizontal untuk kategori insiden.
class CategoryBar extends StatelessWidget {
  const CategoryBar({
    super.key,
    required this.label,
    required this.value,
    required this.max,
    required this.color,
  });

  final String label;
  final int value;
  final int max;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 98,
            child: Text(label, style: SiagaText.body.copyWith(fontSize: 13.5)),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: 0.2 + 0.8 * value / max,
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 28,
            child: Text(
              '$value',
              textAlign: TextAlign.right,
              style: SiagaText.body,
            ),
          ),
        ],
      ),
    );
  }
}
