import 'package:flutter/material.dart';
import '../core/repository/calendar_repository.dart';
import '../models/calendar_model.dart';

class CalendarViewModel extends ChangeNotifier {
  final CalendarRepository _repository = CalendarRepository();

  Map<String, List<HijriGregorianDate>> calendarCache = {};
  List<HijriGregorianDate> calendarDates = [];
  bool isLoading = false;
  int? currentHijriMonth;
  int? currentHijriYear;

  Future<void> loadCalendar(int month, int year) async {
    isLoading = true;
    notifyListeners();

    final cacheKey = '$month-$year';
    if (calendarCache.containsKey(cacheKey)) {
      calendarDates = calendarCache[cacheKey]!;
      isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final DateTime gregorianDate = DateTime(year, month, 1);
      final hijri = await _repository.getHijriFromGregorian(gregorianDate);
      final hijriMonth = hijri['month'] ?? 1;
      final hijriYear = hijri['year'] ?? 1;

      currentHijriMonth = hijriMonth;
      currentHijriYear = hijriYear;

      calendarDates = await _repository.fetchHijriGregorianCalendar(hijriMonth, hijriYear);
      calendarCache[cacheKey] = calendarDates;
    } catch (e) {
      calendarDates = [];
    }

    isLoading = false;
    notifyListeners();
  }

  void saveCurrentCalendarDate(int month, int year) {
    currentHijriMonth = month;
    currentHijriYear = year;
    notifyListeners();
  }
} 