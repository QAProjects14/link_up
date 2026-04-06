import 'package:flutter/material.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      height: 90,
      padding: const EdgeInsets.only(top: 10, bottom: 20),
      child: Center(
        child: Container(
          width: 320,
          height: 60,
          decoration: BoxDecoration(
            color: const Color(0xFF636363),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            children: [
              Expanded(child: _NavItem(icon: Icons.home_outlined, label: 'HOME', isActive: currentIndex == 0, onTap: () => onTap(0))),
              Expanded(child: _NavItem(icon: Icons.notifications_none, label: 'NOTIFICATIONS', isActive: currentIndex == 1, onTap: () => onTap(1))),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFA63C45) : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
