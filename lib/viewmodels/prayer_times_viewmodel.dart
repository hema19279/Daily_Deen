import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../core/repository/prayer_times_repository.dart';
import '../models/prayer_times_model.dart';
import '../core/services/location_service.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class PrayerTimesViewModel extends ChangeNotifier {
  PrayerTimes prayerTimes = PrayerTimes.defaultTimes();
  bool isLoading = true;
  final PrayerTimesRepository _repository = PrayerTimesRepository();

  Future<void> fetchPrayerTimes(BuildContext context) async {
    final locationService = Provider.of<LocationService>(context, listen: false);

    const delay = Duration(milliseconds: 100);

    while (locationService.currentPosition == null) {
      await Future.delayed(delay);
    }

    final latitude = locationService.currentPosition!.latitude;
    final longitude = locationService.currentPosition!.longitude;

    prayerTimes = await _repository.getPrayerTimes(latitude, longitude);
    isLoading = false;
    notifyListeners();
  }

  // Determine the next prayer
  Map<String, dynamic> getNextPrayer() {

    final now = DateTime.now();
    final format = DateFormat("h:mm a");

    final prayerList = [
      {'name': 'Fajr', 'time': prayerTimes.fajr},
      {'name': 'Sunrise', 'time': prayerTimes.sunrise},
      {'name': 'Dhuhr', 'time': prayerTimes.dhuhr},
      {'name': 'Asr', 'time': prayerTimes.asr},
      {'name': 'Maghrib', 'time': prayerTimes.maghrib},
      {'name': 'Isha', 'time': prayerTimes.isha},
    ];

    for (var prayer in prayerList) {
      try {
        final prayerTime = format.parse(prayer['time']!);
        final todayPrayerTime = DateTime(now.year, now.month, now.day, prayerTime.hour, prayerTime.minute);

        if (now.isBefore(todayPrayerTime)) {
          return prayer;
        }
      } catch (e) {
        if (kDebugMode) {
          print("Error parsing prayer time for ${prayer['name']}: ${prayer['time']} - $e");
        }
      }
    }
    return prayerList.first;
  }

  Map<String, dynamic> getCurrentPrayer() {
    final now = DateTime.now();
    final format = DateFormat("h:mm a"); 

    final prayerList = [
      {'name': 'Fajr', 'time': prayerTimes.fajr},
      {'name': 'Sunrise', 'time': prayerTimes.sunrise},
      {'name': 'Dhuhr', 'time': prayerTimes.dhuhr},
      {'name': 'Asr', 'time': prayerTimes.asr},
      {'name': 'Maghrib', 'time': prayerTimes.maghrib},
      {'name': 'Isha', 'time': prayerTimes.isha},
    ];

    Map<String, dynamic>? lastPrayer;

    for (var prayer in prayerList) {
      try {
        final prayerTime = format.parse(prayer['time']!);
        final todayPrayerTime = DateTime(now.year, now.month, now.day, prayerTime.hour, prayerTime.minute);

        if (now.isAfter(todayPrayerTime)) {
          lastPrayer = prayer; // Keep updating as we find later past prayers
        } else {
          break; // Stop when we reach the next prayer
        }
      } catch (e) {
        if (kDebugMode) {
          print("Error parsing prayer time for ${prayer['name']}: ${prayer['time']} - $e");
        }
      }
    }

    return lastPrayer ?? prayerList.first; // Default to first prayer if none found
  }

  String getRemainingTime(String? nextPrayerTime) {
    if (nextPrayerTime == null) return "N/A"; // Handle null value
    
    try {
      final now = DateTime.now();
      final format = DateFormat("h:mm a"); 
      final nextTime = format.parse(nextPrayerTime);
      var todayNextPrayer = DateTime(now.year, now.month, now.day, nextTime.hour, nextTime.minute);

      if (now.isAfter(todayNextPrayer)) {
        final tomorrow = now.add(const Duration(days: 1));
        todayNextPrayer = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, nextTime.hour, nextTime.minute);
      }

      final remainingDuration = todayNextPrayer.difference(now);
      final hours = remainingDuration.inHours;
      final minutes = remainingDuration.inMinutes.remainder(60);
      final seconds = remainingDuration.inSeconds.remainder(60);

      return "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
    } catch (e) {
      if (kDebugMode) {
        print("Error calculating remaining time: $e");
      }
      return "N/A";
    }
  }

  double getPrayerProgress(String? currentTime, String? nextTime) {
    if (currentTime == null || nextTime == null) return 0.0;

    try {
      final now = DateTime.now();
      final format = DateFormat("h:mm a");

      final current = format.parse(currentTime);
      final next = format.parse(nextTime);

      DateTime todayCurrent = DateTime(now.year, now.month, now.day, current.hour, current.minute);
      DateTime todayNext = DateTime(now.year, now.month, now.day, next.hour, next.minute);

      // If next prayer time is before current (i.e. wraps to next day, like Isha → Fajr)
      if (todayNext.isBefore(todayCurrent)) {
        todayNext = todayNext.add(const Duration(days: 1));
      } else if (currentTime == nextTime) {
        final temp = format.parse(prayerTimes.isha);
        todayCurrent = DateTime(now.year, now.month, now.day, temp.hour, temp.minute);
        todayCurrent = todayCurrent.add(const Duration(days: -1));
        
      }

      final totalDuration = todayNext.difference(todayCurrent).inSeconds;
      final elapsed = now.difference(todayCurrent).inSeconds;

      if (elapsed < 0) return 0.0; // Not started yet
      if (totalDuration <= 0) return 1.0;

      return (elapsed / totalDuration).clamp(0.0, 1.0);
    } catch (e) {
      if (kDebugMode) {
        print("Progress error: $e");
      }
      return 0.0;
    }
  }
}
