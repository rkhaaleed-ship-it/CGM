import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/cgm_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_toggle.dart';
import '../widgets/app_top_bar.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer<CgmProvider>(
      builder: (context, cgm, _) {
        final a = cgm.alerts;
        final sensor = cgm.sensor;
        final rem = sensor.remaining;

        return Column(
          children: [
            AppTopBar(title: l10n.settings),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
                children: [
                  _SectionTitle(l10n.sensorStatus),
                  _SensorCard(cgm: cgm, rem: rem),
                  _SectionTitle(l10n.dataSource),
                  _SettingsGroup(
                    children: [
                      _SettingsRow(
                        icon: Icons.power,
                        iconBg: const Color(0xFF0F1A2E),
                        label: l10n.xdripApi,
                        sub: cgm.apiService.xdripUrl,
                        trailing: Text(
                          cgm.xdripConnected ? '${l10n.connected} ✓' : l10n.disconnected,
                          style: TextStyle(
                            color: cgm.xdripConnected ? AppColors.green2 : AppColors.text3,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      _SettingsRow(
                        icon: Icons.cloud_outlined,
                        iconBg: const Color(0xFF0A0A1A),
                        label: l10n.nightscout,
                        sub: l10n.backup,
                        trailing: Text(
                          a.nightscoutEnabled ? l10n.connected : '${l10n.notEnabled} ›',
                          style: const TextStyle(color: AppColors.text3, fontSize: 12),
                        ),
                        onTap: () => cgm.updateAlerts(a.copyWith(nightscoutEnabled: !a.nightscoutEnabled)),
                      ),
                      _SettingsRow(
                        icon: Icons.sensors,
                        iconBg: const Color(0xFF0A1A0A),
                        label: l10n.directNfc,
                        sub: l10n.libre1Only,
                        trailing: AppToggle(
                          value: a.nfcDirectEnabled,
                          onChanged: (v) => cgm.updateAlerts(a.copyWith(nfcDirectEnabled: v)),
                        ),
                      ),
                      _SettingsRow(
                        icon: Icons.bluetooth,
                        iconBg: const Color(0xFF0A1A2E),
                        label: l10n.bluetooth,
                        sub: sensor.bleConnected ? l10n.bluetoothConnected : l10n.bluetoothScan,
                        trailing: Icon(
                          sensor.bleConnected ? Icons.check_circle : Icons.bluetooth_searching,
                          color: sensor.bleConnected ? AppColors.green2 : AppColors.text3,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  _SectionTitle(l10n.alertLimits),
                  _SettingsGroup(
                    children: [
                      _RangeRow(
                        label: l10n.critLow,
                        value: a.critLow,
                        min: 40,
                        max: 70,
                        color: const Color(0xFFFF6B6B),
                        onChanged: (v) => cgm.updateAlerts(a.copyWith(critLow: v)),
                      ),
                      _RangeRow(
                        label: l10n.lowAlert,
                        value: a.low,
                        min: 60,
                        max: 100,
                        color: const Color(0xFFFCA5A5),
                        onChanged: (v) => cgm.updateAlerts(a.copyWith(low: v)),
                      ),
                      _RangeRow(
                        label: l10n.highAlert,
                        value: a.high,
                        min: 140,
                        max: 250,
                        color: const Color(0xFFFCD34D),
                        onChanged: (v) => cgm.updateAlerts(a.copyWith(high: v)),
                      ),
                      _RangeRow(
                        label: l10n.critHigh,
                        value: a.critHigh,
                        min: 200,
                        max: 350,
                        color: const Color(0xFFFB923C),
                        onChanged: (v) => cgm.updateAlerts(a.copyWith(critHigh: v)),
                      ),
                    ],
                  ),
                  _SectionTitle(l10n.notifications),
                  _SettingsGroup(
                    children: [
                      _ToggleRow(
                        icon: Icons.notifications_outlined,
                        iconBg: const Color(0xFF1A1A0A),
                        label: l10n.alertsEnabled,
                        sub: l10n.soundVibrate,
                        value: a.alertsEnabled,
                        onChanged: (v) => cgm.updateAlerts(a.copyWith(alertsEnabled: v)),
                      ),
                      _ToggleRow(
                        icon: Icons.nightlight_round,
                        iconBg: const Color(0xFF0A0A1A),
                        label: l10n.nightMode,
                        sub: l10n.nightModeSub,
                        value: a.nightMode,
                        onChanged: (v) => cgm.updateAlerts(a.copyWith(nightMode: v)),
                      ),
                      _ToggleRow(
                        icon: Icons.trending_down,
                        iconBg: const Color(0xFF1A0A0A),
                        label: l10n.rapidDrop,
                        sub: l10n.rapidDropSub,
                        value: a.rapidDropAlert,
                        onChanged: (v) => cgm.updateAlerts(a.copyWith(rapidDropAlert: v)),
                      ),
                      _ToggleRow(
                        icon: Icons.trending_up,
                        iconBg: const Color(0xFF1A0A0A),
                        label: l10n.rapidRise,
                        sub: l10n.rapidRiseSub,
                        value: a.rapidRiseAlert,
                        onChanged: (v) => cgm.updateAlerts(a.copyWith(rapidRiseAlert: v)),
                      ),
                    ],
                  ),
                  _SectionTitle(l10n.sendToMainApp),
                  _SettingsGroup(
                    children: [
                      _ToggleRow(
                        icon: Icons.send_outlined,
                        iconBg: const Color(0xFF0A1A0A),
                        label: l10n.xdripBroadcast,
                        sub: l10n.autoSend,
                        value: a.xdripBroadcastEnabled,
                        onChanged: (v) => cgm.updateAlerts(a.copyWith(xdripBroadcastEnabled: v)),
                      ),
                      _SettingsRow(
                        icon: Icons.link,
                        iconBg: const Color(0xFF0A0A1A),
                        label: l10n.nightscoutUrl,
                        sub: cgm.apiService.nightscoutUrl,
                        trailing: Text(l10n.configureUrl, style: const TextStyle(color: AppColors.text3, fontSize: 12)),
                      ),
                    ],
                  ),
                  _SectionTitle(l10n.language),
                  _SettingsGroup(
                    children: [
                      _SettingsRow(
                        icon: Icons.language,
                        iconBg: const Color(0xFF111111),
                        label: l10n.language,
                        sub: cgm.locale.languageCode == 'ar' ? l10n.arabic : l10n.english,
                        trailing: AppToggle(
                          value: cgm.locale.languageCode == 'ar',
                          onChanged: (_) => cgm.toggleLocale(),
                        ),
                      ),
                      _SettingsRow(
                        icon: Icons.straighten,
                        iconBg: const Color(0xFF111111),
                        label: l10n.unit,
                        sub: cgm.useMmol ? l10n.mmoll : l10n.mgdl,
                        trailing: AppToggle(
                          value: cgm.useMmol,
                          onChanged: cgm.setUseMmol,
                        ),
                      ),
                    ],
                  ),
                  _SectionTitle(l10n.about),
                  _SettingsGroup(
                    children: [
                      _SettingsRow(
                        icon: Icons.phone_android,
                        iconBg: const Color(0xFF111111),
                        label: l10n.version,
                        sub: l10n.versionSub,
                      ),
                      _SettingsRow(
                        icon: Icons.code,
                        iconBg: const Color(0xFF111111),
                        label: l10n.flutterFramework,
                        sub: l10n.flutterSub,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 6),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(color: AppColors.red, fontSize: 11, letterSpacing: 1),
      ),
    );
  }
}

class _SensorCard extends StatelessWidget {
  const _SensorCard({required this.cgm, required this.rem});
  final CgmProvider cgm;
  final Duration rem;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final sensor = cgm.sensor;
    final dots = '●' * sensor.signalStrength + '○' * (4 - sensor.signalStrength);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1A0A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1A4A1A)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('📡 ${sensor.name}', style: const TextStyle(color: AppColors.green2, fontSize: 15, fontWeight: FontWeight.w500)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F2A0F),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF1E5A1E)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(color: AppColors.green2, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      sensor.isConnected ? l10n.connected : l10n.disconnected,
                      style: const TextStyle(color: AppColors.green2, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _SensorInfoRow(l10n.remaining, l10n.daysHours(rem.inDays, rem.inHours % 24)),
          _SensorInfoRow(l10n.lastReading, l10n.minutesAgo(cgm.minutesSinceLastReading)),
          _SensorInfoRow(l10n.lastValue, '${cgm.displayValue(cgm.currentValue)} ${cgm.unitLabel}'),
          _SensorInfoRow(l10n.signalStrength, '${l10n.excellent} $dots'),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: 1 - sensor.lifeProgress,
              minHeight: 5,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation(AppColors.green2),
            ),
          ),
        ],
      ),
    );
  }
}

class _SensorInfoRow extends StatelessWidget {
  const _SensorInfoRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.text3, fontSize: 12)),
          Text(value, style: const TextStyle(color: Color(0xFFDDDDDD), fontSize: 12)),
        ],
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.bg3,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.iconBg,
    required this.label,
    this.sub,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final Color iconBg;
  final String label;
  final String? sub;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, size: 15, color: AppColors.text2),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(color: Color(0xFFDDDDDD), fontSize: 13)),
                  if (sub != null) Text(sub!, style: const TextStyle(color: AppColors.text3, fontSize: 11)),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.icon,
    required this.iconBg,
    required this.label,
    required this.sub,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final Color iconBg;
  final String label;
  final String sub;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return _SettingsRow(
      icon: icon,
      iconBg: iconBg,
      label: label,
      sub: sub,
      trailing: AppToggle(value: value, onChanged: onChanged),
    );
  }
}

class _RangeRow extends StatelessWidget {
  const _RangeRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.color,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final Color color;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(color: color, fontSize: 13)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.bg2,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border2),
                ),
                child: Text('${value.round()} ${l10n.mgdl}', style: TextStyle(color: color, fontSize: 12)),
              ),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: (max - min).round(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
