import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:lyceum_notif/components/bottom_navbar.dart';
import 'package:lyceum_notif/notification_controller.dart';
import 'package:lyceum_notif/screens/dashboard.dart';
import 'package:lyceum_notif/screens/notification_list.dart';

// ─── VAPID key — get from Firebase Console ────────────────────────────────────
// Steps: console.firebase.google.com → qaoautomation →
//   Project Settings (gear) → Cloud Messaging → Web Push Certificates →
//   Generate key pair (or copy existing). Paste the public key below.
const _vapidKey = 'YOUR_VAPID_KEY_HERE';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;
  StreamSubscription<RemoteMessage>? _fcmForegroundSub;

  @override
  void initState() {
    super.initState();
    _setup();
  }

  Future<void> _setup() async {
    if (kIsWeb) {
      await _setupWeb();
    } else {
      await _setupNative();
    }
  }

  // ── Web (PWA on Safari / Chrome) ──────────────────────────────────────────

  Future<void> _setupWeb() async {
    // Request notification permission — iOS 16.4+ PWA supports this
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      try {
        // Register this browser/PWA with FCM and subscribe to topic.
        // vapidKey links the browser subscription to your Firebase project.
        final token = await FirebaseMessaging.instance.getToken(
          vapidKey: _vapidKey == 'YOUR_VAPID_KEY_HERE' ? null : _vapidKey,
        );
        if (token != null) {
          // Subscribe the token to the LNU topic via FCM
          await FirebaseMessaging.instance
              .subscribeToTopic('lnu_notifications');
        }
      } catch (_) {
        // getToken fails gracefully if VAPID key is missing or invalid
      }
    }

    // Foreground messages on web — show a browser notification manually
    _fcmForegroundSub = FirebaseMessaging.onMessage.listen((message) {
      final title = message.notification?.title ?? 'LinkUp';
      final body  = message.notification?.body  ?? '';
      // Foreground notifications on web need to be shown manually
      // (the service worker only handles background)
      _showWebSnackBar(title, body);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((_) {
      if (mounted) setState(() => _currentIndex = 1);
    });
  }

  void _showWebSnackBar(String title, String body) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white)),
            if (body.isNotEmpty)
              Text(body,
                  style: const TextStyle(
                      fontSize: 12, color: Colors.white70)),
          ],
        ),
        backgroundColor: const Color(0xFFA63C45),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'VIEW',
          textColor: Colors.white,
          onPressed: () => setState(() => _currentIndex = 1),
        ),
      ),
    );
  }

  // ── Native (Android / iOS app) ────────────────────────────────────────────

  Future<void> _setupNative() async {
    await NotificationController.requestPermission();

    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    await FirebaseMessaging.instance.subscribeToTopic('lnu_notifications');

    _fcmForegroundSub = FirebaseMessaging.onMessage.listen((message) {
      NotificationController.showFromFcm(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((_) {
      if (mounted) setState(() => _currentIndex = 1);
    });
  }

  @override
  void dispose() {
    _fcmForegroundSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: [
            DashboardScreen(onSeeAll: () => setState(() => _currentIndex = 1)),
            const NotificationListScreen(),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
