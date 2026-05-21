import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/glucose_color.dart';
import '../l10n/app_localizations.dart';
import '../providers/cgm_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/glucose_chart.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer<CgmProvider>(
      builder: (context, cgm, _) {
        final v = cgm.currentValue;
        final hasData = cgm.glucoseService.hasReadings;
        final stats = cgm.glucoseService.statsForHours(
          cgm.chartHours,
          low: cgm.alerts.low,
          high: cgm.alerts.high,
        );
        final slice = cgm.glucoseService.readingsForHours(cgm.chartHours);
        final predictions = cgm.glucoseService.predictValues();
        final textColor = hasData ? GlucoseColor.textColor(v) : AppColors.text3;
        final delta = cgm.deltaPer5Min;
        final deltaSign = delta >= 0 ? '+' : '';
        final compact = MediaQuery.sizeOf(context).height < 700;

        String predText;
        Color predColor;
        if (!hasData) {
          predText = l10n.autoScanHint;
          predColor = AppColors.text3;
        } else {
          final slope = cgm.glucoseService.calculateSlope();
          if (v < cgm.alerts.low + 10 && slope < -0.5) {
            final mins = ((v - cgm.alerts.critLow) / slope.abs() * 5).abs().round().clamp(5, 120);
            predText = l10n.expectedDropIn(mins);
            predColor = AppColors.yellow;
          } else if (v > cgm.alerts.high - 10 && slope > 0.5) {
            final mins = ((cgm.alerts.critHigh - v) / slope * 5).round().clamp(5, 120);
            predText = l10n.expectedRiseIn(mins);
            predColor = AppColors.amber;
          } else {
            predText = l10n.inTargetRange;
            predColor = AppColors.green2;
          }
        }

        String? alertText;
        if (hasData) {
          if (cgm.alertMessage == 'crit_low') {
            alertText = l10n.alertLowCrit(v.round());
          } else if (cgm.alertMessage == 'low') {
            alertText = l10n.alertLow(v.round());
          } else if (cgm.alertMessage == 'crit_high') {
            alertText = l10n.alertHighCrit(v.round());
          } else if (cgm.alertMessage == 'high') {
            alertText = l10n.alertHigh(v.round());
          }
        }

        final mins = cgm.minutesSinceLastReading;
        final agoText = hasData
            ? cgm.timeAgoText(mins, l10n.justNowNfc, l10n.minutesAgo(mins))
            : l10n.waitingForSensor;
        final valueSize = compact ? 52.0 : 64.0;

        return Column(
          children: [
            AppTopBar(
              title: l10n.appTitle,
              showNotification: cgm.alertMessage != null,
              trailing: IconButton(
                icon: const Icon(Icons.translate_rounded, color: AppColors.text3, size: 22),
                onPressed: cgm.toggleLocale,
                tooltip: l10n.language,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(agoText, style: const TextStyle(color: AppColors.text3, fontSize: 11)),
                        const SizedBox(height: 2),
                        Text(
                          hasData ? '$deltaSign${delta.toStringAsFixed(1)} ${l10n.mgdl}' : '',
                          style: const TextStyle(
                            color: Color(0xFFFF6B6B),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          predText,
                          style: TextStyle(color: predColor, fontSize: 12, fontWeight: FontWeight.w500),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasData ? cgm.displayValue(v) : '--',
                        style: TextStyle(
                          fontSize: valueSize,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -2,
                          height: 1,
                          color: textColor,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          hasData ? cgm.trend.symbol : '',
                          style: TextStyle(fontSize: valueSize * 0.45, color: textColor),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16, bottom: 4),
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Text(cgm.unitLabel, style: const TextStyle(color: AppColors.text3, fontSize: 10)),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GlucoseMainChart(
                  readings: slice,
                  predictions: predictions,
                  low: cgm.alerts.low,
                  high: cgm.alerts.high,
                  heartRate: cgm.heartRate,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
              child: Row(
                children: [
                  _TimeBtn(label: l10n.hour1, active: cgm.chartHours == 1, onTap: () => cgm.setChartHours(1)),
                  const SizedBox(width: 4),
                  _TimeBtn(label: l10n.hour3, active: cgm.chartHours == 3, onTap: () => cgm.setChartHours(3)),
                  const SizedBox(width: 4),
                  _TimeBtn(label: l10n.hour6, active: cgm.chartHours == 6, onTap: () => cgm.setChartHours(6)),
                  const SizedBox(width: 4),
                  _TimeBtn(label: l10n.hour12, active: cgm.chartHours == 12, onTap: () => cgm.setChartHours(12)),
                  const SizedBox(width: 4),
                  _TimeBtn(label: l10n.hour24, active: cgm.chartHours == 24, onTap: () => cgm.setChartHours(24)),
                ],
              ),
            ),
            if (alertText != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A0000),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF5A1111)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: AppColors.red, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(alertText, style: const TextStyle(color: AppColors.red, fontSize: 11)),
                      ),
                    ],
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
              child: Row(
                children: [
                  _StatCard(
                    label: l10n.avg,
                    value: '${stats['avg']?.round() ?? '--'}',
                    color: GlucoseColor.statColor(stats['avg'] as double? ?? 0, isAverage: true),
                  ),
                  const SizedBox(width: 4),
                  _StatCard(
                    label: l10n.tir,
                    value: '${stats['tir'] ?? '--'}%',
                    color: _tirColor(stats['tir'] as int? ?? 0),
                  ),
                  const SizedBox(width: 4),
                  _StatCard(
                    label: l10n.high,
                    value: '${stats['high']?.round() ?? '--'}',
                    color: GlucoseColor.statColor(stats['high'] as double? ?? 0, isAverage: false),
                  ),
                  const SizedBox(width: 4),
                  _StatCard(
                    label: l10n.low,
                    value: '${stats['low']?.round() ?? '--'}',
                    color: GlucoseColor.statColor(stats['low'] as double? ?? 0, isAverage: false),
                  ),
                ],
              ),
            ),
            Container(
              height: 58,
              decoration: const BoxDecoration(
                color: Color(0xFF080808),
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: GlucoseMiniChart(
                readings: cgm.readings,
                windowHours: cgm.chartHours,
                low: cgm.alerts.low,
                high: cgm.alerts.high,
              ),
            ),
          ],
        );
      },
    );
  }

  Color _tirColor(int tir) {
    if (tir >= 70) return AppColors.green2;
    if (tir >= 50) return AppColors.amber;
    return const Color(0xFFEF5350);
  }
}

class _TimeBtn extends StatelessWidget {
  const _TimeBtn({required this.label, required this.active, required this.onTap});
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: active ? const Color(0xFF1A2A40) : AppColors.bg3,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: active ? AppColors.blue.withValues(alpha: 0.6) : AppColors.border2),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                color: active ? AppColors.blueLight : AppColors.text3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        decoration: BoxDecoration(
          color: AppColors.bg3,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Text(
              label.toUpperCase(),
              style: const TextStyle(fontSize: 8, color: AppColors.text3, letterSpacing: 0.4),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
