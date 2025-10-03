import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../models/prayer_times_model.dart';

class PrayerTimesRepository {
  Future<PrayerTimes> getPrayerTimes(double latitude, double longitude) async {
    final url = Uri.parse(
      "http://api.aladhan.com/v1/timings?latitude=$latitude&longitude=$longitude&method=2",
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final timings = data['data']['timings'];
        final date = data['data']['date']['gregorian']['date'];
        final hijriDate = data['data']['date']['hijri']['date'];
        final hijriMonth = data['data']['date']['hijri']['month']['en'];
        final hijriDay = data['data']['date']['hijri']['day'];
        final hijriWeekday = data['data']['date']['hijri']['weekday']['en'];
        final hijriYear = data['data']['date']['hijri']['year'];

        // Convert all timings from "HH:mm" to "h:mm a"
        final convertedTimings = {
          for (var entry in timings.entries)
            entry.key: _convertTo12Hour(entry.value),
        };

        return PrayerTimes.fromJson({
          ...convertedTimings,
          'date': date,
          'hijriDate': hijriDate,
          'hijriMonth': hijriMonth,
          'hijriDay': hijriDay,
          'hijriWeekday': hijriWeekday,
          'hijriYear': hijriYear,
        });
      } else {
        throw Exception("Failed to load prayer times");
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing prayer times: $e');
      }
      return PrayerTimes.defaultTimes();
    }
  }

  /// Helper method to convert time from "HH:mm" to "h:mm a"
  String _convertTo12Hour(String time24h) {
    try {
      final parsed = DateFormat("HH:mm").parse(time24h);
      return DateFormat("h:mm a").format(parsed);
    } catch (e) {
      if (kDebugMode) {
        print("Time format error for value '$time24h': $e");
      }
      return time24h; // fallback to original
    }
  }
}
