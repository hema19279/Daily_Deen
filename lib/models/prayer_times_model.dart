class PrayerTimes {
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;
  final String date;
  final String hijriDate;
  final String hijriMonth;
  final String hijriDay;
  final String hijriWeekday;
  final String hijriYear;

  PrayerTimes({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.date,
    required this.hijriDate,
    required this.hijriMonth,
    required this.hijriDay,
    required this.hijriWeekday,
    required this.hijriYear,
  });

  factory PrayerTimes.defaultTimes() {
    return PrayerTimes(
      fajr: '00:00 AM',
      sunrise: '00:00 AM',
      dhuhr: '00:00 AM',
      asr: '00:00 AM',
      maghrib: '00:00 AM',
      isha: '00:00 AM',
      date: 'Unknown Date',
      hijriDate: 'Unknown Hijri Date',
      hijriMonth: 'Unknown Hijri Month',
      hijriDay: 'Unknown Hijri Day',
      hijriWeekday: 'Unknown Hijri Weekday',
      hijriYear: 'Unknown Hijri Year',
    );
  }

  factory PrayerTimes.fromJson(Map<String, dynamic> json) {
    return PrayerTimes(
      fajr: json['Fajr'],
      sunrise: json['Sunrise'],
      dhuhr: json['Dhuhr'],
      asr: json['Asr'],
      maghrib: json['Maghrib'],
      isha: json['Isha'],
      date: json['date'],
      hijriDate: json['hijriDate'],
      hijriMonth: json['hijriMonth'],
      hijriDay: json['hijriDay'],
      hijriWeekday: json['hijriWeekday'],
      hijriYear: json['hijriYear'],
    );
  }
}
