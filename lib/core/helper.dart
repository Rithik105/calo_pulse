import 'package:cloud_firestore/cloud_firestore.dart';

DateTime normalizeDate(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

bool isValidEmail(String email) {
  final bool emailValid = RegExp(
    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
  ).hasMatch(email);
  return emailValid;
}

String formatDate(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final target = DateTime(date.year, date.month, date.day);

  if (target == today) return 'Today';
  if (target == today.subtract(const Duration(days: 1))) {
    return 'Yesterday';
  }

  return '${date.day}/${date.month}/${date.year}';
}

DateTime parseDate(dynamic value) {
  if (value is Timestamp) {
    return value.toDate();
  } else if (value is String) {
    return DateTime.parse(value);
  } else if (value is DateTime) {
    return value;
  }
  throw Exception('Invalid date format');
}
