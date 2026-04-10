import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lyceum_notif/app_shell.dart';
import 'package:lyceum_notif/firebase_options.dart';
import 'package:lyceum_notif/notification_controller.dart';
import 'package:lyceum_notif/screens/onboarding_screen.dart';
import 'package:lyceum_notif/screens/splash_screen.dart';

// ─── FCM background handler — native only, top-level ─────────────────────────
@pragma('vm:entry-point')
Future<void> _fcmBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await _initAwesomeNotifications();
  await NotificationController.showFromFcm(message);
}

Future<void> _initAwesomeNotifications() async {
  await AwesomeNotifications().initialize(
    'resource://drawable/lnulogo',
    [
      NotificationChannel(
        channelKey: 'lnu_channel',
        channelName: 'LNU Notifications',
        channelDescription:
            'Notifications from Lyceum Northwestern University',
        defaultColor: const Color(0xFFA63C45),
        ledColor: const Color(0xFFA63C45),
        importance: NotificationImportance.Max,
        channelShowBadge: true,
        defaultRingtoneType: DefaultRingtoneType.Notification,
        playSound: true,
        enableVibration: true,
        enableLights: true,
        criticalAlerts: true,
      ),
    ],
    debug: false,
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (!kIsWeb) {
    // Native: register background handler and awesome_notifications
    FirebaseMessaging.onBackgroundMessage(_fcmBackgroundHandler);
    await _initAwesomeNotifications();
    await AwesomeNotifications().setListeners(
      onActionReceivedMethod: NotificationController.onActionReceivedMethod,
      onNotificationCreatedMethod:
          NotificationController.onNotificationCreatedMethod,
      onNotificationDisplayedMethod:
          NotificationController.onNotificationDisplayedMethod,
      onDismissActionReceivedMethod:
          NotificationController.onDismissActionReceivedMethod,
    );
  }

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
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (_) => const SplashScreen(),
        '/onboarding': (_) => const OnboardingScreen(),
        '/home': (_) => const AppShell(),
      },
    );
  }
}
