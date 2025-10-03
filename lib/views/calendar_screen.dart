import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodels/calendar_viewmodel.dart';
import '../themes/app_colors.dart';
import '../models/calendar_model.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  int? gregorianMonth;
  int? gregorianYear;

  final DateFormat _dateFormat = DateFormat('dd-MM-yyyy');

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();

    // Load based on current Gregorian month/year
    Future.microtask(() async {
      if (!mounted) return;

      final viewModel = Provider.of<CalendarViewModel>(context, listen: false);
      
      if (viewModel.calendarDates.isEmpty) {
        await viewModel.loadCalendar(now.month, now.year);
      }

      final dates = viewModel.calendarDates;
      if (dates.isNotEmpty) {
        gregorianMonth = dates.first.gregorianMonthNumber;
        gregorianYear = int.tryParse(dates.first.gregorianYear);
      }
    });
  }

  void _changeMonth(int offset) {
    if (gregorianMonth == null || gregorianYear == null) return;

    int newMonth = gregorianMonth! + offset;
    int newYear = gregorianYear!;

    if (newMonth < 1) {
      newMonth = 12;
      newYear -= 1;
    } else if (newMonth > 12) {
      newMonth = 1;
      newYear += 1;
    }

    gregorianMonth = newMonth;
    gregorianYear = newYear;

    final viewModel = Provider.of<CalendarViewModel>(context, listen: false);
    viewModel.saveCurrentCalendarDate(newMonth, newYear);
    viewModel.loadCalendar(newMonth, newYear);
  }

  void _jumpToToday() {
    final now = DateTime.now();
    gregorianMonth = now.month;
    gregorianYear = now.year;

    final viewModel = Provider.of<CalendarViewModel>(context, listen: false);
    viewModel.saveCurrentCalendarDate(now.month, now.year);
    viewModel.loadCalendar(now.month, now.year);
  }

  DateTime _parseDate(String dateString) {
    return _dateFormat.parse(dateString);
  }

  bool _isToday(String gregorianDate) {
    final parsed = _parseDate(gregorianDate);
    final now = DateTime.now();
    return parsed.year == now.year &&
        parsed.month == now.month &&
        parsed.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<CalendarViewModel>(context);
    final dates = viewModel.calendarDates;

    return Scaffold(
      appBar: AppBar(title: const Text("Hijri Calendar")),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : dates.isEmpty
              ? const Center(child: Text("No data available"))
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCalendarHeader(dates),
                        const SizedBox(height: 16),
                        _buildWeekDays(),
                        const SizedBox(height: 8),
                        _buildHijriCalendarGrid(dates),
                        const SizedBox(height: 24),
                        _buildEventSection(dates),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildCalendarHeader(List<HijriGregorianDate> dates) {
    final hijriMonthName = dates.first.hijriMonth;
    final hijriYearText = dates.first.hijriYear;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.theme.withAlpha(77)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$hijriMonthName $hijriYearText',
            style: TextStyle(
              color: AppColors.theme,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios, size: 18, color: AppColors.theme),
                onPressed: () => _changeMonth(-1),
              ),
              IconButton(
                icon: Icon(Icons.arrow_forward_ios, size: 18, color: AppColors.theme),
                onPressed: () => _changeMonth(1),
              ),
              IconButton(
                icon: Icon(Icons.today, size: 18, color: AppColors.theme),
                onPressed: () => _jumpToToday(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeekDays() {
    const weekDays = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekDays
          .map(
            (day) => SizedBox(
              width: 32,
              child: Text(
                day,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.theme,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildHijriCalendarGrid(List<HijriGregorianDate> dates) {
    const weekDays = {'Al Ahad':0, 'Al Athnayn':1, 'Al Thalaata':2, 'Al Arba\'a':3, 'Al Khamees':4, 'Al Juma\'a':5, 'Al Sabt':6};

    final dayOffset = (weekDays[dates.first.hijriWeekday] ?? 0) % 7;
    final gridLength = ((dates.first.hijriNumberOfDays + dayOffset) / 7).ceil() * 7;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: gridLength,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        final dayIndex = index - dayOffset;
        final isValidDay = dayIndex >= 0 && dayIndex < dates.length;

        if (!isValidDay) return const SizedBox();

        final day = dates[dayIndex];
        final hijriDay = day.hijriDay;
        final isToday = _isToday(day.gregorianDate);
        final hasEvent = day.holidays.isNotEmpty;

        return GestureDetector(
          onTapDown: (TapDownDetails details) => _showDayDetails(context, details.globalPosition, day),
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isToday ? AppColors.theme.withAlpha(51) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: isToday ? Border.all(color: AppColors.theme) : null,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    hijriDay,
                    style: TextStyle(
                      color: isToday ? AppColors.theme : AppColors.textPrimary,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  if (hasEvent)
                    Container(
                      width: 4,
                      height: 4,
                      margin: const EdgeInsets.only(top: 2),
                      decoration: BoxDecoration(
                        color: AppColors.theme,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDayDetails(BuildContext context, Offset position, HijriGregorianDate day) {
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final overlayOffset = overlay.localToGlobal(Offset.zero);

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy - overlayOffset.dy,
        overlay.size.width - position.dx,
        overlay.size.height - position.dy,
      ),
      items: [
        PopupMenuItem(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hijri Date:', style: TextStyle(color: AppColors.theme)),
              Text('${day.hijriWeekday}, ${day.hijriMonth} ${day.hijriDay}, ${day.hijriYear}'),
              Text('Gregorian Date:', style: TextStyle(color: AppColors.theme)),
              Text('${day.gregorianWeekday}, ${day.gregorianMonth} ${day.gregorianDay}, ${day.gregorianYear}'),
              if (day.holidays.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Holidays:', style: TextStyle(color: AppColors.theme)),
                      ...day.holidays.map((holiday) => Text(holiday)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEventSection(List<HijriGregorianDate> dates) {
    final events = dates
        .where((d) => d.holidays.isNotEmpty)
        .map((e) => {
              'date': '${e.hijriDay} ${e.hijriMonth}',
              'title': e.holidays.join(', '),
              'type': 'holy',
            })
        .toList();

    if (events.isEmpty) {
      return const Text("No upcoming events this month.");
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Upcoming Islamic Events",
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        ...events.map((event) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.theme.withAlpha(51),
                  width: 1.5,
                ),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.theme.withAlpha(26),
                  child: Icon(Icons.star, color: AppColors.theme),
                ),
                title: Text(
                  event['title'] ?? '',
                  style: TextStyle(
                    color: AppColors.theme,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  event['date'] ?? '',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            )),
      ],
    );
  }
}
