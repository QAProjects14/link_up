import '../models/notification_item.dart';

class AppData {
  static final List<NotificationItem> notifications = [];

  static List<NotificationItem> get active =>
      notifications.where((n) => !n.isArchived).toList();

  static List<NotificationItem> get archived =>
      notifications.where((n) => n.isArchived).toList();
}
