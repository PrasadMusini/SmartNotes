import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static String dateAndTime(DateTime value) {
    return DateFormat('EEE, d MMM yyyy • h:mm a').format(value);
  }
}
