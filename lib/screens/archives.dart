import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lyceum_notif/components/app_header.dart';
import 'package:lyceum_notif/components/notification_card.dart';
import 'package:lyceum_notif/models/notification_item.dart';
import 'package:lyceum_notif/screens/notification_detail.dart';

class ArchivesScreen extends StatelessWidget {
  const ArchivesScreen({super.key});

  Future<void> _unarchive(String id) async {
    await FirebaseFirestore.instance
        .collection('lnu_notifications')
        .doc(id)
        .update({'isArchived': false});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppHeader(showBack: true),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('lnu_notifications')
                    .where('isArchived', isEqualTo: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFA63C45),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  final docs = snapshot.data?.docs ?? [];
                  final items =
                      docs.map((d) => NotificationItem.fromFirestore(d)).toList();

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        const Text(
                          "ARCHIVES",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 20),

                        if (items.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 60),
                              child: Text(
                                "No archived notifications.",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          )
                        else
                          ...items.map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: Dismissible(
                                key: Key(item.id),
                                direction: DismissDirection.startToEnd,
                                background: Container(
                                  alignment: Alignment.centerLeft,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4B00FF),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  padding: const EdgeInsets.only(left: 24),
                                  child: const Icon(
                                    Icons.unarchive_outlined,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                                onDismissed: (_) => _unarchive(item.id),
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
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
