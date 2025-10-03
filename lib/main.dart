import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/settings_viewmodel.dart';
import 'views/main_screen.dart';
import 'viewmodels/prayer_times_viewmodel.dart';
import 'viewmodels/qibla_viewmodel.dart';
import 'viewmodels/calendar_viewmodel.dart';
import 'core/services/location_service.dart';
import 'themes/app_colors.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PrayerTimesViewModel()),
        ChangeNotifierProvider(create: (_) => QiblaViewModel()),
        ChangeNotifierProvider(create: (_) => CalendarViewModel()),
        ChangeNotifierProvider(create: (_) => LocationService()),
        ChangeNotifierProvider(create: (_) => SettingsViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsViewModel>(
      builder: (context, settingsViewModel, child) {
        return Builder(
          builder: (context) {
            return MaterialApp(
              title: 'Daily Deen',
              theme: ThemeData(
                useMaterial3: true,
                brightness: settingsViewModel.isDarkMode ? Brightness.dark : Brightness.light,
                scaffoldBackgroundColor: AppColors.primary,
                appBarTheme: AppBarTheme(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: AppColors.textPrimary,
                ),
                textTheme: TextTheme(
                  bodyMedium: TextStyle(color: AppColors.textPrimary),
                ),
                colorScheme: ColorScheme.fromSeed(
                  seedColor: AppColors.theme,
                  brightness: settingsViewModel.isDarkMode ? Brightness.dark : Brightness.light,
                ),
              ),
              home: const MainScreen(),
              debugShowCheckedModeBanner: false,
            );
          },
        );
      },
    );
  }
}
