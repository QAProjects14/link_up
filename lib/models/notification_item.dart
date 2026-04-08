import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationItem {
  final String id;
  final String type; // 'spreadsheet' or 'memo'
  final String title;
  final String mainTitle;   // custom heading shown in detail view
  final String sender;
  final String department;
  final String date;
  final String? time;
  final String? content;
  final String? link;
  final int readCount;
  bool isArchived;
  final String contentAlign; // 'left', 'center', 'right'

  NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    this.mainTitle = '',
    required this.sender,
    required this.time,
    required this.department,
    required this.date,
    this.content,
    this.link,
    this.readCount = 0,
    this.isArchived = false,
    this.contentAlign = 'left',
  });

  factory NotificationItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationItem(
      id: doc.id,
      type: (data['type'] as String?) ?? 'memo',
      title: (data['title'] as String?) ?? '',
      mainTitle: (data['mainTitle'] as String?) ?? '',
      sender: (data['sender'] as String?) ?? '',
      department: (data['department'] as String?) ?? 'QUALITY ASSURANCE',
      date: (data['date'] as String?) ?? '',
      time: data['time'] as String?,
      content: data['content'] as String?,
      link: data['link'] as String?,
      readCount: (data['readCount'] as int?) ?? 0,
      isArchived: (data['isArchived'] as bool?) ?? false,
      contentAlign: (data['contentAlign'] as String?) ?? 'left',
    );
  }
}
