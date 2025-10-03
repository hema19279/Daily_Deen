import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodels/prayer_times_viewmodel.dart';
import '../themes/app_colors.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // Fetch prayer times ONCE after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PrayerTimesViewModel>(context, listen: false).fetchPrayerTimes(context);
    });

    // Refresh remaining time every second
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Clean up
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prayerTimesViewModel = Provider.of<PrayerTimesViewModel>(context);

    if (prayerTimesViewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final prayerTimes = prayerTimesViewModel.prayerTimes;
    final prayerList = [
      {'name': 'Fajr', 'time': prayerTimes.fajr},
      {'name': 'Sunrise', 'time': prayerTimes.sunrise},
      {'name': 'Dhuhr', 'time': prayerTimes.dhuhr},
      {'name': 'Asr', 'time': prayerTimes.asr},
      {'name': 'Maghrib', 'time': prayerTimes.maghrib},
      {'name': 'Isha', 'time': prayerTimes.isha},
    ];

    final now = DateTime.now();
    final currentPrayer = prayerTimesViewModel.getCurrentPrayer();
    final nextPrayer = prayerTimesViewModel.getNextPrayer();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.theme.withAlpha(77)),
            ),
            child: Column(
              children: [
                Text(
                  DateFormat('EEEE, MMMM d, y').format(now),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  '${prayerTimes.hijriWeekday}, ${prayerTimes.hijriMonth} ${prayerTimes.hijriDay}, ${prayerTimes.hijriYear}',
                  style: TextStyle(
                    color: AppColors.theme.withAlpha(204),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Next prayer card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.secondary, AppColors.primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.theme.withAlpha(51),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: AppColors.theme.withAlpha(127), width: 2),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Next Prayer', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                        const SizedBox(height: 8),
                        Text(
                          nextPrayer['name'],
                          style: TextStyle(
                            color: AppColors.theme,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Remaining Time', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                        const SizedBox(height: 8),
                        Text(
                          prayerTimesViewModel.getRemainingTime(nextPrayer['time']),
                          style: TextStyle(
                            color: AppColors.theme,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: prayerTimesViewModel.getPrayerProgress(
                    currentPrayer['time'],
                    nextPrayer['time'],
                  ),
                  backgroundColor: AppColors.textSecondary.withAlpha(100),
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.theme),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Text("Today's Prayer Times", style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),

          // Prayer list
          ...prayerList.map((prayer) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: prayer['name'] == currentPrayer['name']
                    ? AppColors.theme
                    : AppColors.textSecondary.withAlpha(51),
              ),
            ),
            child: ListTile(
              leading: Icon(
                prayer['name'] == 'Fajr' ? Icons.nightlight_round :
                prayer['name'] == 'Sunrise' ? Icons.wb_sunny_outlined :
                prayer['name'] == 'Dhuhr' ? Icons.wb_sunny :
                prayer['name'] == 'Asr' ? Icons.sunny_snowing :
                prayer['name'] == 'Maghrib' ? Icons.brightness_4 :
                Icons.nights_stay,
                color: prayer['name'] == currentPrayer['name']
                    ? AppColors.theme
                    : AppColors.textPrimary,
              ),
              title: Text(
                prayer['name'] ?? '',
                style: TextStyle(
                  color: prayer['name'] == currentPrayer['name']
                      ? AppColors.theme
                      : AppColors.textPrimary,
                  fontWeight: prayer['name'] == currentPrayer['name']
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
              trailing: Text(
                prayer['time'] ?? '',
                style: TextStyle(
                  color: prayer['name'] == currentPrayer['name']
                      ? AppColors.theme
                      : AppColors.textPrimary,
                  fontWeight: prayer['name'] == currentPrayer['name']
                      ? FontWeight.bold
                      : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }
}
