import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class NotificationItem {
  String title;
  String message;
  DateTime datetime;
  bool archived;

  NotificationItem({
    required this.title,
    required this.message,
    required this.datetime,
    this.archived = false,
  });
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  DateTime? filterDate;

  List<NotificationItem> notifications = [
    NotificationItem(
      title: "Enrollment Update",
      message: "Enrollment starts next week",
      datetime: DateTime(2026, 3, 10, 9, 30),
    ),
    NotificationItem(
      title: "University Event",
      message: "Annual celebration announcement",
      datetime: DateTime(2026, 3, 11, 15, 0),
    ),
    NotificationItem(
      title: "Scholarship Notice",
      message: "Apply before deadline",
      datetime: DateTime(2026, 3, 12, 10, 15),
    ),
  ];

  List<NotificationItem> get filteredNotifications {
    if (filterDate == null)
      return notifications.where((n) => !n.archived).toList();
    return notifications
        .where(
          (n) =>
              !n.archived &&
              n.datetime.year == filterDate!.year &&
              n.datetime.month == filterDate!.month &&
              n.datetime.day == filterDate!.day,
        )
        .toList();
  }

  Future<void> _pickDate(BuildContext context) async {
    DateTime now = DateTime.now();
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: filterDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );

    if (picked != null) {
      setState(() => filterDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: () => _pickDate(context),
          ),
          if (filterDate != null)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () => setState(() => filterDate = null),
            ),
        ],
      ),
      body: filteredNotifications.isEmpty
          ? const Center(child: Text("No notifications found"))
          : ListView.builder(
              itemCount: filteredNotifications.length,
              itemBuilder: (context, index) {
                final item = filteredNotifications[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    title: Text(
                      item.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(item.message),
                        const SizedBox(height: 6),
                        Text(
                          "Date: ${DateFormat.yMMMd().format(item.datetime)}, Time: ${DateFormat.Hm().format(item.datetime)}",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.archive),
                      onPressed: () => setState(() => item.archived = true),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
