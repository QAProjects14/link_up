import 'package:flutter/material.dart';
import 'package:lyceum_notif/screens/settings.dart';

class AppHeader extends StatelessWidget {
  final bool showBack;

  const AppHeader({super.key, this.showBack = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (showBack)
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back_ios_new, size: 26, color: Colors.black87),
            )
          else
            Image.asset('assets/lnulogo.png', height: 45),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/linkuplogo.png', height: 32),
                  const SizedBox(width: 4),
                  Image.asset('assets/linkuptext.png', height: 28),
                ],
              ),
              const SizedBox(height: 2),
              const Text(
                "LYCEUM NORTHWESTERN UNIVERSITY",
                style: TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          if (showBack)
            const SizedBox(width: 26) // balance the row
          else
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              ),
              child: const Icon(Icons.settings_outlined, size: 32, color: Colors.black87),
            ),
        ],
      ),
    );
  }
}
