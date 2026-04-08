import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lyceum_notif/components/app_header.dart';
import 'package:lyceum_notif/screens/archives.dart';
import 'package:lyceum_notif/screens/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const Color _maroon = Color(0xFFA63C45);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(showBack: true),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    const _SectionLabel('GENERAL'),
                    const SizedBox(height: 8),
                    _SettingsCard(
                      children: [
                        _SettingsTile(
                          icon: Icons.play_circle_outline,
                          iconColor: const Color(0xFF1565C0),
                          label: 'Tutorial',
                          subtitle: 'View the app walkthrough',
                          onTap: () async {
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.remove('onboarding_done');
                            if (!context.mounted) return;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const OnboardingScreen(),
                              ),
                            );
                          },
                        ),
                        const _Divider(),
                        _SettingsTile(
                          icon: Icons.inventory_2_outlined,
                          iconColor: const Color(0xFF2E7D32),
                          label: 'Archives',
                          subtitle: 'View archived notifications',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ArchivesScreen(),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),
                    const _SectionLabel('SUPPORT'),
                    const SizedBox(height: 8),
                    _SettingsCard(
                      children: [
                        _SettingsTile(
                          icon: Icons.flag_outlined,
                          iconColor: const Color(0xFFF57C00),
                          label: 'Report a Problem',
                          subtitle: 'Send feedback to the QAO team',
                          onTap: () => showDialog(
                            context: context,
                            builder: (_) => const _ReportDialog(),
                          ),
                        ),
                        const _Divider(),
                        _SettingsTile(
                          icon: Icons.info_outline,
                          iconColor: const Color(0xFF546E7A),
                          label: 'About',
                          subtitle: 'LinkUp v0.1 — LNU Notification System',
                          onTap: () => showDialog(
                            context: context,
                            builder: (_) => const _AboutDialog(),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 36),

                    // // Developer credit
                    // Center(
                    //   child: Column(children: [
                    //     Container(
                    //       width: 52,
                    //       height: 52,
                    //       decoration: BoxDecoration(
                    //         color: _maroon.withValues(alpha: 0.08),
                    //         shape: BoxShape.circle,
                    //       ),
                    //       child: const Icon(Icons.person_outline,
                    //           color: _maroon, size: 26),
                    //     ),
                    //     const SizedBox(height: 10),
                    //     const Text(
                    //       'Developed by',
                    //       style: TextStyle(
                    //           fontSize: 11,
                    //           color: Color(0xFFAAAAAA),
                    //           letterSpacing: 0.3),
                    //     ),
                    //     const SizedBox(height: 4),
                    //     const Text(
                    //       'DARWIN JAMES CIANO',
                    //       style: TextStyle(
                    //           fontSize: 13,
                    //           fontWeight: FontWeight.w800,
                    //           color: Color(0xFF333333),
                    //           letterSpacing: 0.5),
                    //     ),
                    //     const SizedBox(height: 3),
                    //     const Text(
                    //       'EnMS Technical Staff',
                    //       style: TextStyle(
                    //           fontSize: 11,
                    //           color: Color(0xFF666666)),
                    //     ),
                    //     const SizedBox(height: 2),
                    //     const Text(
                    //       'Quality Assurance Office',
                    //       style: TextStyle(
                    //           fontSize: 11,
                    //           color: Color(0xFF666666)),
                    //     ),
                    //     const SizedBox(height: 16),
                    //     const Divider(color: Color(0xFFE0E0E0)),
                    //     const SizedBox(height: 10),
                    //     const Text(
                    //       'VERSION 0.1',
                    //       style: TextStyle(
                    //           fontSize: 10,
                    //           color: Color(0xFFBBBBBB),
                    //           letterSpacing: 0.5),
                    //     ),
                    //     const SizedBox(height: 4),
                    Center(
                      child: const Text(
                        'PRIVACY POLICY  |  TERMS AND CONDITIONS',
                        style: TextStyle(
                          fontSize: 9.5,
                          color: Color(0xFFCCCCCC),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    //     const SizedBox(height: 24),
                    //   ]),
                    // ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── REPORT DIALOG ────────────────────────────────────────────────────────────

class _ReportDialog extends StatefulWidget {
  const _ReportDialog();

  @override
  State<_ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<_ReportDialog> {
  int _selected = -1;
  bool _sending = false;
  bool _sent = false;
  final TextEditingController _otherCtrl = TextEditingController();

  static const List<String> _options = [
    "Notifications not appearing",
    "App crashes on open",
    "Cannot mark as read",
    "Document link not working",
    "Others",
  ];

  @override
  void dispose() {
    _otherCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selected < 0) return;
    setState(() => _sending = true);
    final reason = _selected == _options.length - 1
        ? _otherCtrl.text.trim()
        : _options[_selected];
    try {
      await FirebaseFirestore.instance.collection('lnu_reports').add({
        'reason': reason,
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (mounted)
        setState(() {
          _sending = false;
          _sent = true;
        });
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _sent
              ? const SizedBox(
                  key: ValueKey('done'),
                  height: 120,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFF34A853),
                        size: 48,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Report sent. Thank you!',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  key: const ValueKey('form'),
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        'REPORT A PROBLEM',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Center(
                      child: Text(
                        'Select the issue you are experiencing',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF999999),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    ..._options.asMap().entries.map(
                      (e) => _RadioRow(
                        label: e.value,
                        selected: _selected == e.key,
                        onTap: () => setState(() => _selected = e.key),
                      ),
                    ),
                    if (_selected == _options.length - 1) ...[
                      const SizedBox(height: 10),
                      TextField(
                        controller: _otherCtrl,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: 'Describe the issue...',
                          hintStyle: const TextStyle(
                            color: Color(0xFFAAAAAA),
                            fontSize: 13,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF5F5F5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _selected < 0 || _sending ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFA63C45),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: const Color(0xFFCCCCCC),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _sending
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Send Report',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
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

class _RadioRow extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _RadioRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected
                      ? const Color(0xFFA63C45)
                      : const Color(0xFFCCCCCC),
                  width: 2,
                ),
              ),
              child: selected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFA63C45),
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 13.5,
                color: selected
                    ? const Color(0xFF1A1A1A)
                    : const Color(0xFF555555),
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── ABOUT DIALOG ─────────────────────────────────────────────────────────────

class _AboutDialog extends StatelessWidget {
  const _AboutDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/lnulogo.png', height: 56),
            const SizedBox(height: 14),
            const Text(
              'LinkUp',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFFA63C45),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Official Notification System',
              style: TextStyle(fontSize: 12, color: Color(0xFF888888)),
            ),
            const SizedBox(height: 4),
            const Text(
              'Lyceum Northwestern University',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFFAAAAAA),
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 18),
            const Divider(color: Color(0xFFEEEEEE)),
            const SizedBox(height: 12),
            _AboutRow(label: 'Version', value: '0.1.0'),
            _AboutRow(label: 'Developer', value: 'Darwin James Ciano'),
            _AboutRow(label: 'Office', value: 'Quality Assurance Office'),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Close',
                style: TextStyle(color: Color(0xFFA63C45)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AboutRow extends StatelessWidget {
  final String label;
  final String value;
  const _AboutRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFFAAAAAA),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── HELPERS ─────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Color(0xFF999999),
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF999999),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFFCCCCCC), size: 20),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 0, indent: 68, color: Color(0xFFF0F0F0));
  }
}
