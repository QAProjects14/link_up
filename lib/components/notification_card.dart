import 'package:flutter/material.dart';
import 'package:lyceum_notif/models/notification_item.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationCard extends StatelessWidget {
  final NotificationItem item;
  final VoidCallback onTap;

  static const Color _lightGrey = Color(0xFFD9D9D9);

  const NotificationCard({super.key, required this.item, required this.onTap});

  Future<void> _openLink(BuildContext context) async {
    final url = item.link;
    if (url == null || url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the link.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: item.type == 'spreadsheet'
          ? _buildSpreadsheetCard(context)
          : _buildMemoCard(),
    );
  }

  Widget _buildSpreadsheetCard(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 125),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.sender,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  item.department,
                  style: const TextStyle(fontSize: 9, color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      item.date,
                      style: const TextStyle(
                        fontSize: 9,
                        color: Colors.black54,
                      ),
                    ),
                    const Text(
                      " • ",
                      style: TextStyle(fontSize: 9, color: Colors.black54),
                    ),
                    Text(
                      item.time ?? "00:00",
                      style: const TextStyle(
                        fontSize: 9,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                if (item.readCount > 0) ...[
                  const SizedBox(height: 6),
                  _ReadBadge(count: item.readCount),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Link box
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: () => _openLink(context),
              child: Container(
                height: 90,
                decoration: BoxDecoration(
                  color: item.link != null && item.link!.isNotEmpty
                      ? const Color(0xFFE8F5E9)
                      : _lightGrey,
                  borderRadius: BorderRadius.circular(8),
                  border: item.link != null && item.link!.isNotEmpty
                      ? Border.all(color: const Color(0xFF0F9D58), width: 1)
                      : null,
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.open_in_new,
                      size: 18,
                      color: item.link != null && item.link!.isNotEmpty
                          ? const Color(0xFF0F9D58)
                          : Colors.black38,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "OPEN\nDOCUMENT",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: item.link != null && item.link!.isNotEmpty
                            ? const Color(0xFF0F9D58)
                            : Colors.black38,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemoCard() {
    return Container(
      constraints: const BoxConstraints(minHeight: 140),
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset('assets/lnulogo.png', height: 28),
          const SizedBox(height: 8),
          Text(
            item.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.sender,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      item.department,
                      style: const TextStyle(fontSize: 9, color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (item.readCount > 0) ...[
                      const SizedBox(height: 5),
                      _ReadBadge(count: item.readCount),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    item.date,
                    style: const TextStyle(fontSize: 9, color: Colors.black54),
                  ),
                  Text(
                    item.time ?? "00:00",
                    style: const TextStyle(fontSize: 9, color: Colors.black54),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReadBadge extends StatelessWidget {
  final int count;
  const _ReadBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F8FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFBBDDFF), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.remove_red_eye_outlined,
            size: 10,
            color: Color(0xFF2979FF),
          ),
          const SizedBox(width: 4),
          Text(
            '$count ${count == 1 ? 'read' : 'reads'}',
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2979FF),
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
