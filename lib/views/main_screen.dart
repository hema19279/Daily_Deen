import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/services/location_service.dart';
import 'prayer_times_screen.dart';
import 'qibla_finder_screen.dart';
import 'calendar_screen.dart';
import '../themes/app_colors.dart';
import 'settings_screen.dart';
import '../viewmodels/settings_viewmodel.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const PrayerTimesScreen(),
    const QiblaFinderScreen(),
    const CalendarScreen(),
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      Provider.of<LocationService>(context, listen: false).getUserLocation(context);
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsViewModel>(
      builder: (context, settingsViewModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.self_improvement,
                  color: AppColors.theme,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Daily Deen',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.theme,
                  ),
                ),
              ],
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(Icons.settings_outlined, color: AppColors.theme),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsScreen()),
                  );
                },
              ),
            ],
          ),
          body: SafeArea(
            child: _screens[_selectedIndex],
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.mosque),
                label: 'Prayer Times',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.explore),
                label: 'Qibla Finder',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today),
                label: 'Calendar',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: AppColors.theme,
            onTap: _onItemTapped,
          ),
        );
      },
    );
  }
}
