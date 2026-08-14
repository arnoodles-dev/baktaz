import 'package:dartx/dartx.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

extension DateTimeExt on DateTime {
  String defaultFormat() => DateFormat('MMM dd, yyyy').format(this);

  String get ago => timeago.format(DateTime.now().toUtc().subtract(DateTime.now().toUtc().difference(this)));

  String get age {
    final DateTime today = DateTime.now();
    int age = today.year - year;

    if (today.month < month || (today.month == month && today.day < day)) {
      age--;
    }

    return age.toString();
  }

  String convertTransferDate() => DateFormat('MM/dd/yyyy  hh:mm a').format(this);

  String formatRelative([String? pattern]) {
    if (isToday) {
      return 'today';
    }

    if (isTomorrow) {
      return 'tomorrow';
    }

    if (wasYesterday) {
      return 'yesterday';
    }

    return formatDate(pattern);
  }

  String formatDate([String? pattern]) => DateFormat(pattern ?? 'MM/dd/yyyy').format(this);

  String formatMonthYear() => DateFormat('MMMM yyyy').format(this);

  String formatDayMonthYear() => DateFormat('EEEE, dd MMMM').format(this);

  ///ex. January 1, 2023
  String formatMonthDayYear() => DateFormat('MMMM d, yyyy').format(this);

  ///ex. Jan 1, 2023
  String formatMonthShortDayYear() => DateFormat('MMM d, yyyy').format(this);

  ///ex. Jan 1
  String formatDayMonthShort() => DateFormat('MMM d').format(this);

  String formatAnalyticsCoverWeek() =>
      '${DateFormat.MMMd().format(findFirstDateOfTheWeek(this))} - ${DateFormat.MMMd().format(findLastDateOfTheWeek(this))}, $year';

  DateTime findFirstDateOfTheWeek(DateTime dateTime) => dateTime.subtract(Duration(days: dateTime.weekday - 1));

  DateTime findLastDateOfTheWeek(DateTime dateTime) =>
      dateTime.add(Duration(days: DateTime.daysPerWeek - dateTime.weekday));

  int getDaysInMonth() {
    const int leapYearDivisor = 4;
    const int centuryDivisor = 100;
    const int quadricentennialDivisor = 400;
    const int leapYearDays = 29;
    const int nonLeapYearDays = 28;

    if (month == DateTime.february) {
      final bool isLeapYear =
          (year % leapYearDivisor == 0) && (year % centuryDivisor != 0) || (year % quadricentennialDivisor == 0);

      return isLeapYear ? leapYearDays : nonLeapYearDays;
    }
    const List<int> daysInMonth = <int>[31, -1, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

    return daysInMonth[month - 1];
  }
}
