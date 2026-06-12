class DateFormatter {
  /// Converts a DateTime object or ISO string to a local readable time (e.g. HH:mm) or date.
  static String toLocalTime(DateTime dateTime) {
    final localDateTime = dateTime.toLocal();
    final hour = localDateTime.hour.toString().padLeft(2, '0');
    final minute = localDateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  static String toLocalDate(DateTime dateTime) {
    final localDateTime = dateTime.toLocal();
    final day = localDateTime.day.toString().padLeft(2, '0');
    final month = localDateTime.month.toString().padLeft(2, '0');
    final year = localDateTime.year;
    return '$day/$month/$year';
  }
}
