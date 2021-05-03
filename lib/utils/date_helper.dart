import 'package:cloud_firestore/cloud_firestore.dart';

// Convert Timestamp to DateTime
DateTime toDateTime(dynamic data) {
  if (data == null || !(data is Timestamp)) {
    return null;
  }
  final Timestamp ts = data;
  return DateTime.fromMillisecondsSinceEpoch(ts.millisecondsSinceEpoch);
}

// Extension to allow comparing dates only (disregard times)
extension DateHelper on DateTime {
  bool isSameDate(DateTime other) {
    return (this.year == other.year
        && this.month == other.month
        && this.day == other.day);
  }

  String toWeekdayString() {
    switch (this.weekday) {
      case DateTime.sunday:
        return "Sunday";
        break;
      case DateTime.monday:
        return "Monday";
        break;
      case DateTime.tuesday:
        return "Tuesday";
        break;
      case DateTime.wednesday:
        return "Wednesday";
        break;
      case DateTime.thursday:
        return "Thursday";
        break;
      case DateTime.friday:
        return "Friday";
        break;
      case DateTime.saturday:
        return "Saturday";
        break;
    }
    return "";
  }
}
