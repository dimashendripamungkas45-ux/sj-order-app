import 'package:intl/intl.dart';

class DateTimeUtils {
  static String formatDate(String date) {
    try {
      final DateTime parsedDate = DateTime.parse(date);
      final DateFormat formatter = DateFormat('dd MMM yyyy');
      return formatter.format(parsedDate);
    } catch (e) {
      return date;
    }
  }

  static String formatDateTime(String dateTime) {
    try {
      final DateTime parsedDateTime = DateTime.parse(dateTime);
      final DateFormat formatter = DateFormat('dd MMM yyyy - HH:mm');
      return formatter.format(parsedDateTime);
    } catch (e) {
      return dateTime;
    }
  }

  static String getTimeAgo(String dateTime) {
    try {
      final DateTime parsedDateTime = DateTime.parse(dateTime);
      final Duration difference = DateTime.now().difference(parsedDateTime);

      if (difference.inDays > 0) {
        return '${difference.inDays} days ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hours ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minutes ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return dateTime;
    }
  }
}

