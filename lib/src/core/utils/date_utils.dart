import 'package:intl/intl.dart';

class DateUtils {
  // Format date to display format
  static String formatDate(DateTime date) {
    return DateFormat('dd.MM.yyyy').format(date);
  }

  // Format date with time
  static String formatDateTime(DateTime date) {
    return DateFormat('dd.MM.yyyy HH:mm').format(date);
  }

  // Format date for API
  static String formatDateForAPI(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  // Parse date from string
  static DateTime? parseDate(String dateString) {
    try {
      return DateFormat('yyyy-MM-dd').parse(dateString);
    } catch (e) {
      return null;
    }
  }

  // Get current year
  static int getCurrentYear() {
    return DateTime.now().year;
  }

  // Check if date is in the past
  static bool isDateInPast(DateTime date) {
    return date.isBefore(DateTime.now());
  }

  // Check if date is in the future
  static bool isDateInFuture(DateTime date) {
    return date.isAfter(DateTime.now());
  }

  // Get years list for dropdown (current year - 10 to current year + 5)
  static List<int> getYearsList() {
    int currentYear = getCurrentYear();
    return List.generate(16, (index) => currentYear - 10 + index);
  }

  // Get months list
  static List<String> getMonthsList() {
    return [
      'Yanvar', 'Fevral', 'Mart', 'Aprel', 'May', 'Iyun',
      'Iyul', 'Avgust', 'Sentabr', 'Oktabr', 'Noyabr', 'Dekabr'
    ];
  }

  // Get month name by number
  static String getMonthName(int month) {
    List<String> months = getMonthsList();
    if (month >= 1 && month <= 12) {
      return months[month - 1];
    }
    return '';
  }

  // Calculate age from birth date
  static int calculateAge(DateTime birthDate) {
    DateTime now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month || 
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  // Check if year is leap year
  static bool isLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }

  // Get days in month
  static int getDaysInMonth(int year, int month) {
    List<int> daysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    if (month == 2 && isLeapYear(year)) {
      return 29;
    }
    return daysInMonth[month - 1];
  }
} 