import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageCtrl = PageController();
  int _page = 0;

  // Controls the button/dot color transition between slides
  late AnimationController _colorCtrl;

  static const List<_SlideData> _slides = [
    _SlideData(
      icon: Icons.notifications_active_outlined,
      title: 'Stay Informed',
      subtitle:
          'Receive real-time memoranda and document notifications from the '
          'Quality Assurance Office directly on your device.',
      color: Color(0xFFA63C45),
    ),
    _SlideData(
      icon: Icons.mark_email_read_outlined,
      title: 'Mark as Read',
      subtitle:
          'Open any notification and tap "Mark as Read" to confirm receipt. '
          'Your read status is saved permanently — even after restarting.',
      color: Color(0xFF1565C0),
    ),
    _SlideData(
      icon: Icons.inventory_2_outlined,
      title: 'Archive Anytime',
      subtitle:
          'Swipe left on a notification to archive it. '
          'Access all archived items from Settings → Archives.',
      color: Color(0xFF2E7D32),
    ),
    _SlideData(
      icon: Icons.table_chart_outlined,
      title: 'Open Documents',
      subtitle:
          'Spreadsheet notifications include a direct link. '
          'Tap "Open Document" to view the file in Google Sheets instantly.',
      color: Color(0xFF6A1B9A),
    ),
    _SlideData(
      icon: Icons.campaign_outlined,
      title: 'Push Notifications',
      subtitle:
          'Get notified even when the app is closed or your phone is locked. '
          'Allow notifications when prompted to stay up to date.',
      color: Color(0xFF00695C),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _colorCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _colorCtrl.forward();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _colorCtrl.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/home');
  }

  void _next() {
    if (_page < _slides.length - 1) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final slide = _slides[_page];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Skip ───────────────────────────────────────────────
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 8, top: 4),
                child: TextButton(
                  onPressed: _finish,
                  child: const Text(
                    'Skip',
                    style: TextStyle(color: Color(0xFFAAAAAA), fontSize: 13),
                  ),
                ),
              ),
            ),

            // ── PageView (NO outer FadeTransition — PageView handles it) ──
            Expanded(
              child: PageView.builder(
                controller: _pageCtrl,
                onPageChanged: (i) => setState(() => _page = i),
                itemCount: _slides.length,
                itemBuilder: (_, i) => _SlidePage(
                  data: _slides[i],
                  screenSize: size,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Dots ───────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _slides.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _page == i ? 22 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: _page == i ? slide.color : const Color(0xFFDDDDDD),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // ── Button ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeInOut,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: slide.color,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: slide.color.withValues(alpha: 0.30),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: _next,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _page == _slides.length - 1
                                ? 'Get Started'
                                : 'Next',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            _page == _slides.length - 1
                                ? Icons.check_rounded
                                : Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }
}

// ─── SLIDE PAGE — each slide animates itself independently ───────────────────

class _SlidePage extends StatefulWidget {
  final _SlideData data;
  final Size screenSize;
  const _SlidePage({required this.data, required this.screenSize});

  @override
  State<_SlidePage> createState() => _SlidePageState();
}

class _SlidePageState extends State<_SlidePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 450));
    _opacity =
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide =
        Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _slide,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon circle
              Container(
                width: widget.screenSize.width * 0.36,
                height: widget.screenSize.width * 0.36,
                decoration: BoxDecoration(
                  color: widget.data.color.withValues(alpha: 0.09),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.data.icon,
                  size: widget.screenSize.width * 0.17,
                  color: widget.data.color,
                ),
              ),
              SizedBox(height: widget.screenSize.height * 0.05),
              Text(
                widget.data.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A1A),
                  letterSpacing: 0.2,
                ),
              ),
              SizedBox(height: widget.screenSize.height * 0.02),
              Text(
                widget.data.subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14.5,
                  height: 1.65,
                  color: Color(0xFF666666),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SlideData {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  const _SlideData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });
}
