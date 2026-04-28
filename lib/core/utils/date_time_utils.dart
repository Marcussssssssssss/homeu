import 'package:intl/intl.dart';

extension HomeUDateTimeUtils on DateTime {
  /// Converts a "True UTC" [DateTime] (like created_at) to Malaysia Time (UTC+8).
  DateTime toMalaysiaTime() {
    return toUtc().add(const Duration(hours: 8));
  }

  /// Formats the [DateTime] using Malaysia Time (UTC+8).
  String formatMalaysia(String pattern) {
    return DateFormat(pattern).format(toMalaysiaTime());
  }

  /// Formats the [DateTime] as-is, treating it as Wall Time.
  /// Useful for viewing slots that are already stored as Malaysia Time in UTC containers.
  String formatWallTime(String pattern) {
    return DateFormat(pattern).format(this);
  }
}

extension HomeUStringDateTimeUtils on String {
  /// Parses a "True UTC" timestamp string and converts to Malaysia Time (UTC+8).
  DateTime parseToMalaysiaTime() {
    final parsed = DateTime.parse(this);
    return parsed.toUtc().add(const Duration(hours: 8));
  }

  /// Parses a string that is already "Wall Time" (stored as UTC) and keeps it as-is.
  DateTime parseAsWallTime() {
    return DateTime.parse(this);
  }

  /// Formats a "True UTC" string as Malaysia Time.
  String formatAsMalaysiaTime(String pattern) {
    return parseToMalaysiaTime().formatMalaysia(pattern);
  }

  /// Formats a "Wall Time" string as-is.
  String formatAsWallTime(String pattern) {
    return DateFormat(pattern).format(parseAsWallTime());
  }
}
