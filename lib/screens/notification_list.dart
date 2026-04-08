import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lyceum_notif/components/app_header.dart';
import 'package:lyceum_notif/components/notification_card.dart';
import 'package:lyceum_notif/models/notification_item.dart';
import 'package:lyceum_notif/screens/notification_detail.dart';

class NotificationListScreen extends StatelessWidget {
  const NotificationListScreen({super.key});

  Future<void> _archiveItem(String id) async {
    await FirebaseFirestore.instance
        .collection('lnu_notifications')
        .doc(id)
        .update({'isArchived': true});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppHeader(),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('lnu_notifications')
                .where('isArchived', isEqualTo: false)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFA63C45),
                    strokeWidth: 2,
                  ),
                );
              }
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      'Error: ${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 13),
                    ),
                  ),
                );
              }

              final docs = snapshot.data?.docs ?? [];
              final items = docs
                  .map((d) => NotificationItem.fromFirestore(d))
                  .toList();

              return SingleChildScrollView(
                // Extra bottom padding so last card clears the floating navbar
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    const Text(
                      'NOTIFICATION LIST',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (items.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 60),
                        child: Center(
                          child: Text(
                            'No notifications.',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ),
                      )
                    else
                      ...items.asMap().entries.map(
                        (e) => _AnimatedCard(
                          index: e.key,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: Dismissible(
                              key: Key(e.value.id),
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
                                  size: 26,
                                ),
                              ),
                              onDismissed: (_) => _archiveItem(e.value.id),
                              child: NotificationCard(
                                item: e.value,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        NotificationDetailScreen(item: e.value),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Staggered fade+slide animation for each list item
class _AnimatedCard extends StatefulWidget {
  final int index;
  final Widget child;
  const _AnimatedCard({required this.index, required this.child});

  @override
  State<_AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<_AnimatedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    Future.delayed(Duration(milliseconds: 60 * widget.index), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _fade,
    child: SlideTransition(position: _slide, child: widget.child),
  );
}
