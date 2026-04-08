import 'package:shared_preferences/shared_preferences.dart';

/// Stores which notification IDs this device has marked as read.
/// Persists across app kills, restarts, and minimizations via SharedPreferences.
class ReadStatusService {
  static const String _prefix = 'read_';

  static Future<bool> isRead(String notificationId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_prefix$notificationId') ?? false;
  }

  static Future<void> markAsRead(String notificationId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_prefix$notificationId', true);
  }

  static Future<Set<String>> getAllReadIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs
        .getKeys()
        .where((k) => k.startsWith(_prefix))
        .map((k) => k.substring(_prefix.length))
        .toSet();
  }
}
