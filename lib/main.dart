import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lyceum_notif/app_shell.dart';
import 'package:lyceum_notif/notification_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AwesomeNotifications().initialize(
    'resource://drawable/lnulogo',
    [
      NotificationChannel(
        channelKey: 'lnu_channel',
        channelName: 'LNU Notifications',
        channelDescription: 'Notifications from Lyceum Northwestern University',
        defaultColor: const Color(0xFFA63C45),
        ledColor: const Color(0xFFA63C45),
        importance: NotificationImportance.High,
        channelShowBadge: true,
        // Show banner & sound even when app is in foreground
        defaultRingtoneType: DefaultRingtoneType.Notification,
        playSound: true,
        enableVibration: true,
      ),
    ],
    debug: false,
  );

  // Register listeners — these run in a background isolate when app is killed
  await AwesomeNotifications().setListeners(
    onActionReceivedMethod: NotificationController.onActionReceivedMethod,
    onNotificationCreatedMethod:
        NotificationController.onNotificationCreatedMethod,
    onNotificationDisplayedMethod:
        NotificationController.onNotificationDisplayedMethod,
    onDismissActionReceivedMethod:
        NotificationController.onDismissActionReceivedMethod,
  );

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.interTextTheme(),
      ),
      home: const AppShell(),
    );
  }
}
