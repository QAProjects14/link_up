import 'package:flutter/material.dart';
import 'package:lyceum_notif/components/app_header.dart';
import 'package:lyceum_notif/components/notification_card.dart';
import 'package:lyceum_notif/data/app_data.dart';
import 'package:lyceum_notif/models/notification_item.dart';
import 'package:lyceum_notif/screens/notification_detail.dart';

class NotificationListScreen extends StatefulWidget {
  const NotificationListScreen({super.key});

  @override
  State<NotificationListScreen> createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen> {
  late List<NotificationItem> _items;

  @override
  void initState() {
    super.initState();
    _items = AppData.active;
  }

  void _archiveItem(String id) {
    setState(() {
      final idx = AppData.notifications.indexWhere((n) => n.id == id);
      if (idx != -1) AppData.notifications[idx].isArchived = true;
      _items = AppData.active;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppHeader(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                const Text(
                  "NOTIFICATION LIST",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 16),

                if (_items.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Center(
                      child: Text(
                        "No notifications.",
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ),
                  )
                else
                  ..._items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Dismissible(
                        key: Key(item.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          decoration: BoxDecoration(
                            color: const Color(0xFFA63C45),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.only(right: 24),
                          child: const Icon(
                            Icons.inventory_2_outlined,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        onDismissed: (_) => _archiveItem(item.id),
                        child: NotificationCard(
                          item: item,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  NotificationDetailScreen(item: item),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
