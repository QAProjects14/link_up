import 'package:flutter/material.dart';
import 'package:lyceum_notif/components/bottom_navbar.dart';
import 'package:lyceum_notif/screens/dashboard.dart';
import 'package:lyceum_notif/screens/notification_list.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

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
