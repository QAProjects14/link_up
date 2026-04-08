import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationController {
  @pragma('vm:entry-point')
  static Future<void> onNotificationCreatedMethod(
    ReceivedNotification receivedNotification,
  ) async {}

  @pragma('vm:entry-point')
  static Future<void> onNotificationDisplayedMethod(
    ReceivedNotification receivedNotification,
  ) async {}

  @pragma('vm:entry-point')
  static Future<void> onDismissActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {}

  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    await AwesomeNotifications().setGlobalBadgeCounter(0);
  }

  /// Called from the FCM background isolate (app killed / background).
  /// Also called from AppShell for foreground FCM messages.
  @pragma('vm:entry-point')
  static Future<void> showFromFcm(RemoteMessage message) async {
    final notification = message.notification;
    final title = notification?.title ??
        message.data['title'] as String? ??
        'LNU LinkUp';
    final body = notification?.body ??
        message.data['body'] as String? ??
        'You have a new notification.';

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: message.messageId.hashCode.abs() % 2147483647,
        channelKey: 'lnu_channel',
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
        wakeUpScreen: true,
      ),
    );
  }

  /// Request all required permissions. Returns true if granted.
  static Future<bool> requestPermission() async {
    final isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      return await AwesomeNotifications().requestPermissionToSendNotifications(
        permissions: [
          NotificationPermission.Alert,
          NotificationPermission.Sound,
          NotificationPermission.Badge,
          NotificationPermission.Vibration,
          NotificationPermission.Light,
        ],
      );
    }
    return true;
  }
}
