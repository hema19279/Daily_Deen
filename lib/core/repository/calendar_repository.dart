import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/calendar_model.dart';

class CalendarRepository {
  Future<List<HijriGregorianDate>> fetchHijriGregorianCalendar(int hijriMonth, int hijriYear) async {
    final url = Uri.parse('https://api.aladhan.com/v1/hToGCalendar/$hijriMonth/$hijriYear');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List dates = data['data'];
      return dates.map((e) => HijriGregorianDate.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load Hijri-Gregorian calendar');
    }
  }

  Future<Map<String, int>> getHijriFromGregorian(DateTime date) async {
    final formattedDate = '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
    
    final url = Uri.parse('https://api.aladhan.com/v1/gToH?date=$formattedDate');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final hijri = data['data']['hijri'];
      final month = hijri['month']['number'];
      final year = int.parse(hijri['year']);
      return {'month': month, 'year': year};
    } else {
      throw Exception('Failed to convert Gregorian to Hijri');
    }
  }
}
