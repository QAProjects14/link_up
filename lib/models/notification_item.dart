class NotificationItem {
  final String id;
  final String type; // 'spreadsheet' or 'memo'
  final String title;
  final String sender;
  final String department;
  final String date;
  final String? time; // <--- Add this line
  final String? content;
  bool isArchived;

  NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.sender,
    required this.time,
    required this.department,
    required this.date,
    this.content,
    this.isArchived = false,
  });
}
