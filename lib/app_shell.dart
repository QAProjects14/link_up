import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:lyceum_notif/components/bottom_navbar.dart';
import 'package:lyceum_notif/notification_controller.dart';
import 'package:lyceum_notif/screens/dashboard.dart';
import 'package:lyceum_notif/screens/notification_list.dart';

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
    // Request permissions
    await NotificationController.requestPermission();

    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Subscribe to topic
    await FirebaseMessaging.instance.subscribeToTopic('lnu_notifications');

    // Foreground messages
    _fcmForegroundSub = FirebaseMessaging.onMessage.listen((message) {
      NotificationController.showFromFcm(message);
    });

    // When notification is tapped (background)
    FirebaseMessaging.onMessageOpenedApp.listen((_) {
      if (mounted) {
        setState(() => _currentIndex = 1);
      }
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
