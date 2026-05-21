import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'l10n/app_localizations.dart';
import 'providers/cgm_provider.dart';
import 'screens/home_screen.dart';
import 'screens/nfc_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/bottom_nav_tabs.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF080808),
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(const CgmMonitorApp());
}

class CgmMonitorApp extends StatelessWidget {
  const CgmMonitorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CgmProvider()..initialize(),
      child: Consumer<CgmProvider>(
        builder: (context, cgm, _) {
          return MaterialApp(
            title: 'CGM Monitor',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.dark(),
            locale: cgm.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const MainShell(),
          );
        },
      ),
    );
  }
}

class MainShell extends StatelessWidget {
  const MainShell({super.key});

  static const _screens = [HomeScreen(), NfcScreen()];

  @override
  Widget build(BuildContext context) {
    final cgm = context.watch<CgmProvider>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: IndexedStack(
        index: cgm.activeTab,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavTabs(
        currentIndex: cgm.activeTab,
        onTap: cgm.setTab,
        labels: [l10n.home, l10n.nfc],
      ),
    );
  }
}
