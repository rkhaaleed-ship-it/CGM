import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../core/glucose_color.dart';
import '../models/glucose_reading.dart';
import '../theme/app_theme.dart';

/// Main glucose scatter chart with zones, prediction line, and sidebar.
class GlucoseMainChart extends StatelessWidget {
  const GlucoseMainChart({
    super.key,
    required this.readings,
    required this.predictions,
    this.low = GlucoseColor.low,
    this.high = GlucoseColor.high,
    this.critHigh = GlucoseColor.critHigh,
    this.heartRate = 87,
    this.steps = 3421,
  });

  final List<GlucoseReading> readings;
  final List<double> predictions;
  final double low;
  final double high;
  final double critHigh;
  final int heartRate;
  final int steps;

  @override
  Widget build(BuildContext context) {
    if (readings.isEmpty) {
      return const Center(child: Text('—', style: TextStyle(color: AppColors.text3)));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final chartHeight = constraints.maxHeight.isFinite && constraints.maxHeight > 0
            ? constraints.maxHeight
            : 220.0;

        final vals = readings.map((r) => r.valueMgDl).toList();
    final spots = List.generate(vals.length, (i) => FlSpot(i.toDouble(), vals[i]));

    final lastIdx = vals.length - 1.0;
    final predSpots = <FlSpot>[
      FlSpot(lastIdx, vals.last),
      ...List.generate(
        predictions.length,
        (i) => FlSpot(lastIdx + i + 1, predictions[i]),
      ),
    ];

    return SizedBox(
      height: chartHeight,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 48),
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: lastIdx + predictions.length + 2,
                minY: 40,
                maxY: 290,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: 50,
                  getDrawingHorizontalLine: (_) => const FlLine(
                    color: Color(0xFF181818),
                    strokeWidth: 1,
                  ),
                  getDrawingVerticalLine: (_) => const FlLine(
                    color: Color(0xFF181818),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: 50,
                      getTitlesWidget: (v, _) => Text(
                        v.toInt().toString(),
                        style: const TextStyle(color: AppColors.text3, fontSize: 9),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      interval: math.max(1, vals.length / 6),
                      getTitlesWidget: (v, _) {
                        final idx = v.round();
                        if (idx < 0 || idx >= readings.length) return const SizedBox.shrink();
                        if (idx % math.max(1, (vals.length / 6).ceil()) != 0 &&
                            idx != readings.length - 1) {
                          return const SizedBox.shrink();
                        }
                        final t = readings[idx].timestamp;
                        return Text(
                          '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(color: AppColors.text3, fontSize: 9),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: AppColors.border2),
                ),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => AppColors.bg3,
                    getTooltipItems: (spots) => spots.map((s) {
                      return LineTooltipItem(
                        '${s.y.round()} mg/dL',
                        const TextStyle(color: Colors.white, fontSize: 11),
                      );
                    }).toList(),
                  ),
                ),
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(
                      y: low,
                      color: const Color(0xFFEF5350),
                      strokeWidth: 0.8,
                    ),
                    HorizontalLine(
                      y: high,
                      color: AppColors.amber,
                      strokeWidth: 0.8,
                      dashArray: [6, 4],
                    ),
                  ],
                ),
                rangeAnnotations: RangeAnnotations(
                  verticalRangeAnnotations: [],
                  horizontalRangeAnnotations: [
                    HorizontalRangeAnnotation(
                      y1: 40,
                      y2: low,
                      color: const Color(0x8C500000),
                    ),
                    HorizontalRangeAnnotation(
                      y1: high,
                      y2: critHigh,
                      color: const Color(0x2E503200),
                    ),
                    HorizontalRangeAnnotation(
                      y1: low,
                      y2: high,
                      color: const Color(0x1E003200),
                    ),
                  ],
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: false,
                    barWidth: 0,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, _, __, ___) {
                        return FlDotCirclePainter(
                          radius: vals.length > 72 ? 2.5 : 4,
                          color: GlucoseColor.dotColor(spot.y),
                          strokeWidth: 0,
                        );
                      },
                    ),
                    color: Colors.transparent,
                  ),
                  LineChartBarData(
                    spots: predSpots,
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: AppColors.predColor,
                    barWidth: 1.5,
                    dashArray: [5, 4],
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, _, __, idx) {
                        if (idx == 0) {
                          return FlDotCirclePainter(radius: 0, color: Colors.transparent);
                        }
                        return FlDotCirclePainter(
                          radius: 2.5,
                          color: AppColors.predColor.withValues(alpha: 0.5),
                          strokeWidth: 0,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: 48,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                border: const Border(left: BorderSide(color: AppColors.border)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  _SidebarBtn(icon: Icons.water_drop_outlined, color: AppColors.blue),
                  const SizedBox(height: 10),
                  _SidebarBtn(icon: Icons.add, color: AppColors.text2),
                  const Spacer(),
                  _SidebarStat(icon: Icons.favorite, value: '$heartRate', label: 'bpm'),
                  const SizedBox(height: 10),
                  _SidebarStat(icon: Icons.directions_walk, value: '$steps', label: 'steps'),
                  const SizedBox(height: 8),
                ],
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

class _SidebarBtn extends StatelessWidget {
  const _SidebarBtn({required this.icon, required this.color});
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: AppColors.bg3,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border2),
      ),
      child: Icon(icon, size: 16, color: color),
    );
  }
}

class _SidebarStat extends StatelessWidget {
  const _SidebarStat({required this.icon, required this.value, required this.label});
  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 16, color: AppColors.text2),
        Text(value, style: const TextStyle(color: AppColors.text, fontSize: 13, fontWeight: FontWeight.w500)),
        Text(label, style: const TextStyle(color: AppColors.text3, fontSize: 9)),
      ],
    );
  }
}

/// 24-hour minimap with window selector box.
class GlucoseMiniChart extends StatelessWidget {
  const GlucoseMiniChart({
    super.key,
    required this.readings,
    this.low = GlucoseColor.low,
    this.high = GlucoseColor.high,
    this.windowHours = 3,
  });

  final List<GlucoseReading> readings;
  final double low;
  final double high;
  final int windowHours;

  @override
  Widget build(BuildContext context) {
    if (readings.isEmpty) return const SizedBox.shrink();

    final vals = readings.map((r) => r.valueMgDl).toList();
    final spots = List.generate(vals.length, (i) => FlSpot(i.toDouble(), vals[i]));
    final windowStart = math.max(0, vals.length - windowHours * 12);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
        children: [
          LineChart(
            LineChartData(
              minX: 0,
              maxX: (vals.length - 1).toDouble(),
              minY: 40,
              maxY: 300,
              gridData: const FlGridData(show: false),
              titlesData: const FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              lineTouchData: const LineTouchData(enabled: false),
              extraLinesData: ExtraLinesData(
                horizontalLines: [
                  HorizontalLine(y: low, color: const Color(0xFFEF5350), strokeWidth: 0.5),
                  HorizontalLine(y: high, color: AppColors.amber, strokeWidth: 0.5),
                ],
              ),
              rangeAnnotations: RangeAnnotations(
                horizontalRangeAnnotations: [
                  HorizontalRangeAnnotation(
                    y1: 40,
                    y2: low,
                    color: const Color(0x73500000),
                  ),
                ],
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                      radius: 1.2,
                      color: GlucoseColor.dotColor(spot.y),
                      strokeWidth: 0,
                    ),
                  ),
                  color: Colors.transparent,
                  barWidth: 0,
                ),
              ],
            ),
          ),
          Positioned(
            left: (windowStart / vals.length) * MediaQuery.of(context).size.width * 0.88,
            top: 2,
            bottom: 2,
            width: MediaQuery.of(context).size.width * 0.22,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
              ),
            ),
          ),
          const Positioned(
            top: 3,
            left: 8,
            child: Text('24h', style: TextStyle(color: AppColors.text3, fontSize: 9)),
          ),
        ],
        );
      },
    );
  }
}
