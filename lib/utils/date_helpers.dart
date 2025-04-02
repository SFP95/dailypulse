class DateHelpers {
  static DateTime parseDateTime(dynamic date) {
    if (date is String) {
      return DateTime.parse(date);
    } else if (date is int) {
      return DateTime.fromMillisecondsSinceEpoch(date);
    }
    return DateTime.now();
  }
}