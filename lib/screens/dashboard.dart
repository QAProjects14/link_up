import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lyceum_notif/components/app_header.dart';
import 'package:lyceum_notif/components/notification_card.dart';
import 'package:lyceum_notif/models/notification_item.dart';
import 'package:lyceum_notif/screens/notification_detail.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback? onSeeAll;
  const DashboardScreen({super.key, this.onSeeAll});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const Color _primaryMaroon = Color(0xFFA63C45);
  static const Color _lightGrey = Color(0xFFD9D9D9);

  final List<Map<String, String>> _carouselData = [
    {
      "title": "Mission",
      "content":
          "LNU is committed to providing a learning environment that fosters the development of globally competitive professionals who are compassionate, responsible and productive citizens.",
    },
    {
      "title": "Vision",
      "content":
          "LNU will be a highly ranked internationally recognized private university, and a model of integrated flexible learning, research, innovation, and sustainable public engagement.",
    },
    {
      "title": "Values",
      "content":
          "• Excellence\n• Professionalism\n• Integrity\n• Creativity\n• Spirituality",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;

    return Column(
      children: [
        const AppHeader(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 15),

                // Carousel
                SizedBox(
                  height: screenHeight * 0.28,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _carouselData.length,
                itemBuilder: (context, index) =>
                    _buildInfoCard(_carouselData[index]),
              ),
            ),

            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _carouselData.length,
                (i) => _buildDot(isActive: _currentPage == i),
              ),
            ),

            const SizedBox(height: 20),

            // Notification section header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "NOTIFICATION LIST",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
                GestureDetector(
                  onTap: widget.onSeeAll,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4B00FF),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      "SEE ALL",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Firestore preview
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('lnu_notifications')
                  .where('isArchived', isEqualTo: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: _primaryMaroon,
                        strokeWidth: 2,
                      ),
                    ),
                  );
                }

                final docs = snapshot.data?.docs ?? [];
                final items = docs
                    .map((d) => NotificationItem.fromFirestore(d))
                    .take(2)
                    .toList();

                if (items.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text(
                        "No notifications yet.",
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ),
                  );
                }

                return Column(
                  children: items
                      .map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
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
                      )
                      .toList(),
                );
              },
            ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(Map<String, String> data) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            image: const DecorationImage(
              image: AssetImage('assets/missioncard.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: _primaryMaroon.withOpacity(0.75),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['title']!,
                  style: GoogleFonts.galada(
                    color: Colors.white,
                    fontSize: 34,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(right: 80),
                  child: Text(
                    data['content']!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12.5,
                      height: 1.3,
                    ),
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Spacer(),
                const Text(
                  "LYCEUM NORTHWESTERN UNIVERSITY\nQUALITY SINCE 1969",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 12,
          right: 15,
          child: CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Image.asset('assets/lnu.png'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDot({bool isActive = false}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 3),
      height: 6,
      width: isActive ? 16 : 6,
      decoration: BoxDecoration(
        color: isActive ? _primaryMaroon : _lightGrey,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
