class HijriGregorianDate {
  final int hijriNumberOfDays;
  final String hijriDate;
  final String hijriDay;
  final String hijriWeekday;
  final String hijriMonth;
  final int hijriMonthNumber;
  final String hijriYear;
  final List<String> holidays;
  final String gregorianDate;
  final String gregorianDay;
  final String gregorianWeekday;
  final String gregorianMonth;
  final int gregorianMonthNumber;
  final String gregorianYear;

  HijriGregorianDate({
    required this.hijriNumberOfDays,
    required this.hijriDate,
    required this.hijriDay,
    required this.hijriWeekday,
    required this.hijriMonth,
    required this.hijriMonthNumber,
    required this.hijriYear,
    required this.holidays,
    required this.gregorianDate,
    required this.gregorianDay,
    required this.gregorianWeekday,
    required this.gregorianMonth,
    required this.gregorianMonthNumber,
    required this.gregorianYear,
  });

  factory HijriGregorianDate.fromJson(Map<String, dynamic> json) {
    return HijriGregorianDate(
      hijriNumberOfDays: json['hijri']['month']['days'],
      hijriDate: json['hijri']['date'],
      hijriDay: json['hijri']['day'],
      hijriWeekday: json['hijri']['weekday']['en'],
      hijriMonth: json['hijri']['month']['en'],
      hijriMonthNumber: json['hijri']['month']['number'],
      hijriYear: json['hijri']['year'],
      holidays: List<String>.from(json['hijri']['holidays']),
      gregorianDate: json['gregorian']['date'],
      gregorianDay: json['gregorian']['day'],
      gregorianWeekday: json['gregorian']['weekday']['en'],
      gregorianMonth: json['gregorian']['month']['en'],
      gregorianMonthNumber: json['gregorian']['month']['number'],
      gregorianYear: json['gregorian']['year'],
    );
  }
}
