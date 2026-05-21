import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/glucose_color.dart';
import '../l10n/app_localizations.dart';
import '../providers/cgm_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_top_bar.dart';

class NfcScreen extends StatelessWidget {
  const NfcScreen({super.key});

  static String _nfcErrorLabel(AppLocalizations l10n, String? key) {
    return switch (key) {
      'nfcNotAvailable' => l10n.nfcNotAvailable,
      'nfcDisabled' => l10n.nfcDisabled,
      'scanTimeout' => l10n.scanTimeout,
      'sensorNotActive' => l10n.sensorNotActive,
      _ => l10n.scanFailed,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer<CgmProvider>(
      builder: (context, cgm, _) {
        final state = cgm.nfcState;
        final reading = cgm.lastNfcReading;

        String ringLabel;
        Color ringBorder;
        switch (state) {
          case NfcScanState.scanning:
            ringLabel = l10n.searching;
            ringBorder = AppColors.red;
          case NfcScanState.success:
            ringLabel = l10n.readSuccess;
            ringBorder = AppColors.green2;
          case NfcScanState.error:
            ringLabel = _nfcErrorLabel(l10n, cgm.nfcErrorMessage);
            ringBorder = AppColors.amber;
          case NfcScanState.idle:
            ringLabel = l10n.tapToRead;
            ringBorder = AppColors.border2;
        }

        final last3 = cgm.readings.length >= 3
            ? cgm.readings.sublist(cgm.readings.length - 3).map((r) => r.valueMgDl.round()).join(' → ')
            : '--';
        final avg24 = cgm.glucoseService.statsForHours(24)['avg']?.round() ?? 0;
        final rem = cgm.sensor.remaining;

        return Column(
          children: [
            AppTopBar(
              title: l10n.nfcReading,
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.bg3,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border2),
                ),
                child: Text(cgm.sensor.model, style: const TextStyle(color: AppColors.text3, fontSize: 12)),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: state != NfcScanState.scanning ? cgm.startNfcScan : null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 170,
                        height: 170,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: ringBorder, width: 3),
                          boxShadow: state == NfcScanState.scanning
                              ? [BoxShadow(color: AppColors.red.withValues(alpha: 0.4), blurRadius: 16, spreadRadius: 2)]
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Transform.rotate(
                              angle: 1.5708,
                              child: const Icon(Icons.sensors, size: 52, color: AppColors.red),
                            ),
                            const SizedBox(height: 8),
                            Text(ringLabel, style: const TextStyle(color: AppColors.text2, fontSize: 13)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (state == NfcScanState.scanning)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: cgm.nfcProgress,
                          minHeight: 3,
                          backgroundColor: AppColors.border,
                          valueColor: const AlwaysStoppedAnimation(AppColors.red),
                        ),
                      ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.placePhoneHint,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.text3, fontSize: 12, height: 1.7),
                    ),
                    const SizedBox(height: 4),
                    Text(l10n.libreCompat, style: const TextStyle(color: Color(0xFF333333), fontSize: 11)),
                    const SizedBox(height: 20),
                    if (state == NfcScanState.success && reading != null) ...[
                      _NfcResultCard(cgm: cgm, reading: reading, last3: last3, avg24: avg24, rem: rem),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: cgm.sendNfcToHome,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: Text(l10n.sendToHome),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            onPressed: () {
                              cgm.resetNfcState();
                              cgm.startNfcScan();
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.text2,
                              side: const BorderSide(color: AppColors.border2),
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: Text(l10n.readAgain),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 20),
                    _InfoBox(
                      title: l10n.systemRequirements,
                      lines: [l10n.reqAndroid, l10n.reqIos, l10n.reqLibre1, l10n.reqLibre2, l10n.reqPermission],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A0A0A),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF3A1111)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.medicalWarningTitle, style: const TextStyle(color: Color(0xFFCC4444), fontWeight: FontWeight.w500, fontSize: 11)),
                          const SizedBox(height: 4),
                          Text(l10n.medicalWarningBody, style: const TextStyle(color: Color(0xFF884444), fontSize: 11, height: 1.7)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _NfcResultCard extends StatelessWidget {
  const _NfcResultCard({
    required this.cgm,
    required this.reading,
    required this.last3,
    required this.avg24,
    required this.rem,
  });

  final CgmProvider cgm;
  final dynamic reading;
  final String last3;
  final int avg24;
  final Duration rem;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final v = reading.valueMgDl as double;
    final color = GlucoseColor.textColor(v);
    final time = DateFormat.Hm().format(reading.timestamp as DateTime);

    String trendText;
    Color trendColor;
    if (v < cgm.alerts.low) {
      trendText = l10n.lowTrend;
      trendColor = const Color(0xFFEF5350);
    } else if (v > cgm.alerts.high) {
      trendText = l10n.highTrend;
      trendColor = AppColors.amber;
    } else {
      trendText = l10n.inTargetTrend;
      trendColor = AppColors.green2;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1E0A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1A4A1A)),
      ),
      child: Column(
        children: [
          Text(l10n.nfcSuccessLabel, style: const TextStyle(color: AppColors.green2, fontSize: 11)),
          const SizedBox(height: 6),
          Text(
            cgm.displayValue(v),
            style: TextStyle(fontSize: 56, fontWeight: FontWeight.w700, color: color, height: 1),
          ),
          Text(cgm.unitLabel, style: const TextStyle(color: AppColors.text2, fontSize: 13)),
          const SizedBox(height: 8),
          Text(l10n.nowTime(time), style: const TextStyle(color: AppColors.text3, fontSize: 11)),
          Text(trendText, style: TextStyle(color: trendColor, fontSize: 12)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF0D200D),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                _InfoRow(l10n.avg24h, '$avg24 ${l10n.mgdl}'),
                _InfoRow(l10n.last3Readings, '$last3 → ${v.round()}'),
                _InfoRow(
                  l10n.sensorRemaining,
                  l10n.daysHours(rem.inDays, rem.inHours % 24),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.text3, fontSize: 11)),
          Text(value, style: const TextStyle(color: AppColors.text2, fontSize: 11)),
        ],
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  const _InfoBox({required this.title, required this.lines});
  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bg3,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: AppColors.text2, fontSize: 12)),
          const SizedBox(height: 4),
          ...lines.map((l) => Text(l, style: const TextStyle(color: AppColors.text3, fontSize: 12, height: 1.8))),
        ],
      ),
    );
  }
}
