import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  // Logo: fade + scale
  late Animation<double> _logoOpacity;
  late Animation<double> _logoScale;

  // Text block: fade + slide up
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;

  // Loader: fade in at the very end
  late Animation<double> _loaderOpacity;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );

    _logoOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.35, curve: Curves.easeIn),
      ),
    );

    _logoScale = Tween<double>(begin: 0.55, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOutBack),
      ),
    );

    _textOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.4, 0.7, curve: Curves.easeIn),
      ),
    );

    _textSlide = Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _ctrl,
            curve: const Interval(0.4, 0.7, curve: Curves.easeOut),
          ),
        );

    _loaderOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
      ),
    );

    _ctrl.forward();
    _navigate();
  }

  Future<void> _navigate() async {
    // Wait for animation + a comfortable pause
    await Future.delayed(const Duration(milliseconds: 4000));
    if (!mounted) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final seen = prefs.getBool('onboarding_done') ?? false;

      if (!mounted) return;

      // Navigate to home (AppShell) - onboarding can be set later
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      // Fallback to home if any error
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final logoSize = size.width * 0.34;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFBF4A54), Color(0xFF8A2230)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // ── Centre: logo + text ──────────────────────────────
              Center(
                child: AnimatedBuilder(
                  animation: _ctrl,
                  builder: (_, child) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo circle
                      Opacity(
                        opacity: _logoOpacity.value,
                        child: Transform.scale(
                          scale: _logoScale.value,
                          child: Container(
                            width: logoSize,
                            height: logoSize,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.22),
                                  blurRadius: 32,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                            ),
                            padding: EdgeInsets.all(logoSize * 0.14),
                            child: Image.asset('assets/lnu.png'),
                          ),
                        ),
                      ),

                      SizedBox(height: size.height * 0.045),

                      // Text group
                      Opacity(
                        opacity: _textOpacity.value,
                        child: SlideTransition(
                          position: _textSlide,
                          child: Column(
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    'assets/linkuplogo.png',
                                    height: 30,
                                  ),
                                  const SizedBox(width: 8),
                                  Image.asset(
                                    'assets/linkuptext.png',
                                    height: 24,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'LYCEUM NORTHWESTERN UNIVERSITY',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.6,
                                ),
                              ),
                              const SizedBox(height: 5),
                              const Text(
                                'Official Notification System',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Bottom loader ──────────────────────────────────────
              Positioned(
                bottom: size.height * 0.07,
                left: 0,
                right: 0,
                child: AnimatedBuilder(
                  animation: _ctrl,
                  builder: (_, _) => Opacity(
                    opacity: _loaderOpacity.value,
                    child: const Column(
                      children: [
                        SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white54,
                            strokeWidth: 2,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Loading…',
                          style: TextStyle(color: Colors.white38, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
