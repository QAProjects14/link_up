import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lyceum_notif/components/app_header.dart';
import 'package:lyceum_notif/models/notification_item.dart';
import 'package:lyceum_notif/services/read_status_service.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationDetailScreen extends StatefulWidget {
  final NotificationItem item;
  const NotificationDetailScreen({super.key, required this.item});

  @override
  State<NotificationDetailScreen> createState() =>
      _NotificationDetailScreenState();
}

class _NotificationDetailScreenState extends State<NotificationDetailScreen>
    with SingleTickerProviderStateMixin {
  bool _marking = false;
  bool _markedByMe = false;
  late int _readCount;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _readCount = widget.item.readCount;
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    _fadeCtrl.forward();
    _checkIfAlreadyRead();
  }

  Future<void> _checkIfAlreadyRead() async {
    final already = await ReadStatusService.isRead(widget.item.id);
    if (already && mounted) setState(() => _markedByMe = true);
  }

  Future<void> _markAsRead() async {
    if (_marking || _markedByMe) return;
    setState(() => _marking = true);
    try {
      await FirebaseFirestore.instance
          .collection('lnu_notifications')
          .doc(widget.item.id)
          .update({'readCount': FieldValue.increment(1)});
      await ReadStatusService.markAsRead(widget.item.id);
      if (mounted) {
        setState(() {
          _readCount++;
          _markedByMe = true;
          _marking = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _marking = false);
    }
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Column(
            children: [
              const AppHeader(showBack: true),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  child: widget.item.type == 'spreadsheet'
                      ? _SpreadsheetBody(
                          item: widget.item,
                          readCount: _readCount,
                          markedByMe: _markedByMe,
                          marking: _marking,
                          onMarkRead: _markAsRead,
                        )
                      : _MemoBody(
                          item: widget.item,
                          readCount: _readCount,
                          markedByMe: _markedByMe,
                          marking: _marking,
                          onMarkRead: _markAsRead,
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

// ─── READ ACTION ──────────────────────────────────────────────────────────────

class _ReadAction extends StatelessWidget {
  final int readCount;
  final bool markedByMe;
  final bool marking;
  final VoidCallback onMarkRead;
  const _ReadAction({
    required this.readCount,
    required this.markedByMe,
    required this.marking,
    required this.onMarkRead,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          transitionBuilder: (child, anim) =>
              FadeTransition(opacity: anim, child: child),
          child: markedByMe
              ? Container(
                  key: const ValueKey('done'),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 13),
                  decoration: BoxDecoration(
                    color: const Color(0xFF34A853).withValues(alpha: 0.09),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: const Color(0xFF34A853).withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_rounded,
                          color: Color(0xFF34A853), size: 18),
                      SizedBox(width: 8),
                      Text('Marked as Read',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF34A853))),
                    ],
                  ),
                )
              : SizedBox(
                  key: const ValueKey('btn'),
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: marking ? null : onMarkRead,
                    icon: marking
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.mark_email_read_outlined, size: 17),
                    label: Text(marking
                        ? 'Marking...'
                        : 'Click Here to Mark as Read'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFA63C45),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      textStyle: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                  ),
                ),
        ),
        if (readCount > 0) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.remove_red_eye_outlined,
                  size: 12, color: Color(0xFFAAAAAA)),
              const SizedBox(width: 5),
              Text(
                '$readCount ${readCount == 1 ? 'person has' : 'people have'} read this',
                style: const TextStyle(fontSize: 11, color: Color(0xFFAAAAAA)),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

// ─── MEMO BODY ────────────────────────────────────────────────────────────────

class _MemoBody extends StatelessWidget {
  final NotificationItem item;
  final int readCount;
  final bool markedByMe;
  final bool marking;
  final VoidCallback onMarkRead;
  const _MemoBody({
    required this.item,
    required this.readCount,
    required this.markedByMe,
    required this.marking,
    required this.onMarkRead,
  });

  @override
  Widget build(BuildContext context) {
    return _DocCard(
      header: _Letterhead(department: item.department),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
                item.mainTitle.isNotEmpty ? item.mainTitle : 'MEMORANDUM',
                style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3,
                    color: const Color(0xFFA63C45))),
          ),
          const SizedBox(height: 14),
          const Divider(thickness: 1.2, color: Color(0xFFE0E0E0)),
          const SizedBox(height: 12),
          _MetaRow(label: 'DATE',
              value: '${item.date}  ${item.time ?? ''}'),
          const SizedBox(height: 7),
          _MetaRow(label: 'FROM', value: item.sender),
          const SizedBox(height: 7),
          _MetaRow(label: 'OFFICE', value: item.department),
          const SizedBox(height: 7),
          _MetaRow(
              label: 'SUBJECT',
              value: item.title.replaceAll('\n', ' ')),
          const SizedBox(height: 14),
          const Divider(thickness: 1.2, color: Color(0xFFE0E0E0)),
          const SizedBox(height: 18),
          _RichContent(
              text: item.content ?? item.title,
              alignment: _alignFromString(item.contentAlign)),
          const SizedBox(height: 28),
          const Divider(thickness: 1, color: Color(0xFFF0F0F0)),
          const SizedBox(height: 14),
          _ReadAction(
              readCount: readCount,
              markedByMe: markedByMe,
              marking: marking,
              onMarkRead: onMarkRead),
          const SizedBox(height: 6),
        ],
      ),
    );
  }
}

// ─── SPREADSHEET BODY ─────────────────────────────────────────────────────────

class _SpreadsheetBody extends StatelessWidget {
  final NotificationItem item;
  final int readCount;
  final bool markedByMe;
  final bool marking;
  final VoidCallback onMarkRead;
  const _SpreadsheetBody({
    required this.item,
    required this.readCount,
    required this.markedByMe,
    required this.marking,
    required this.onMarkRead,
  });

  Future<void> _openLink(BuildContext context) async {
    final url = item.link;
    if (url == null || url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open the link.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _DocCard(
      header: _Letterhead(department: item.department),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
                item.mainTitle.isNotEmpty ? item.mainTitle : 'DOCUMENT SHARED',
                style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3,
                    color: const Color(0xFFA63C45))),
          ),
          const SizedBox(height: 14),
          const Divider(thickness: 1.2, color: Color(0xFFE0E0E0)),
          const SizedBox(height: 12),
          _MetaRow(label: 'DATE',
              value: '${item.date}  ${item.time ?? ''}'),
          const SizedBox(height: 7),
          _MetaRow(label: 'FROM', value: item.sender),
          const SizedBox(height: 7),
          _MetaRow(label: 'OFFICE', value: item.department),
          const SizedBox(height: 7),
          _MetaRow(
              label: 'DOCUMENT',
              value: item.title.replaceAll('\n', ' ')),
          const SizedBox(height: 14),
          const Divider(thickness: 1.2, color: Color(0xFFE0E0E0)),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
                color: const Color(0xFFF9FFF9),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: const Color(0xFFD0EDD0))),
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              const Icon(Icons.table_chart_outlined,
                  color: Color(0xFF0F9D58), size: 42),
              const SizedBox(height: 10),
              const Text(
                  'A spreadsheet document has been shared with you.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 13, color: Color(0xFF555555))),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed:
                      item.link != null && item.link!.isNotEmpty
                          ? () => _openLink(context)
                          : null,
                  icon: const Icon(Icons.open_in_new, size: 16),
                  label: const Text('OPEN DOCUMENT',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                          fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F9D58),
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 22),
          const Divider(thickness: 1, color: Color(0xFFF0F0F0)),
          const SizedBox(height: 14),
          _ReadAction(
              readCount: readCount,
              markedByMe: markedByMe,
              marking: marking,
              onMarkRead: onMarkRead),
          const SizedBox(height: 6),
        ],
      ),
    );
  }
}

// ─── SHARED ───────────────────────────────────────────────────────────────────

class _DocCard extends StatelessWidget {
  final Widget header;
  final Widget body;
  const _DocCard({required this.header, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 18,
              offset: const Offset(0, 6))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header,
          Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 4),
              child: body),
          _DocFooter(),
        ],
      ),
    );
  }
}

class _Letterhead extends StatelessWidget {
  final String department;
  const _Letterhead({required this.department});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFA63C45),
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16), topRight: Radius.circular(16)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(children: [
        Image.asset('assets/lnulogo.png', height: 44),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('LYCEUM NORTHWESTERN UNIVERSITY',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.4)),
            const SizedBox(height: 2),
            const Text('Dagupan City, Pangasinan',
                style: TextStyle(color: Colors.white70, fontSize: 9)),
            const SizedBox(height: 5),
            Container(height: 1, color: Colors.white24),
            const SizedBox(height: 5),
            Text(department,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1)),
          ]),
        ),
      ]),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final String label;
  final String value;
  const _MetaRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(
        width: 62,
        child: Text('$label:',
            style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF999999),
                letterSpacing: 0.4)),
      ),
      const SizedBox(width: 6),
      Expanded(
        child: Text(value,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A))),
      ),
    ]);
  }
}

// ─── RICH CONTENT RENDERER ───────────────────────────────────────────────────

TextAlign _alignFromString(String s) => switch (s) {
      'center' => TextAlign.center,
      'right' => TextAlign.right,
      _ => TextAlign.left,
    };

class _RichContent extends StatelessWidget {
  final String text;
  final TextAlign alignment;

  const _RichContent({required this.text, required this.alignment});

  static List<InlineSpan> _parseInline(String raw) {
    final spans = <InlineSpan>[];
    final pattern = RegExp(r'\*\*(.*?)\*\*|_(.*?)_');
    int last = 0;
    for (final m in pattern.allMatches(raw)) {
      if (m.start > last) {
        spans.add(TextSpan(text: raw.substring(last, m.start)));
      }
      if (m.group(1) != null) {
        spans.add(TextSpan(
            text: m.group(1),
            style: const TextStyle(fontWeight: FontWeight.bold)));
      } else {
        spans.add(TextSpan(
            text: m.group(2),
            style: const TextStyle(fontStyle: FontStyle.italic)));
      }
      last = m.end;
    }
    if (last < raw.length) spans.add(TextSpan(text: raw.substring(last)));
    return spans;
  }

  static const _base = TextStyle(
      fontSize: 13.5, height: 1.8, color: Color(0xFF1A1A1A));

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();

    final lines = text.split('\n');
    final widgets = <Widget>[];

    for (final line in lines) {
      if (line.isEmpty) {
        widgets.add(const SizedBox(height: 6));
        continue;
      }

      final numMatch = RegExp(r'^(\d+)\. (.*)').firstMatch(line);
      if (line.startsWith('• ')) {
        widgets.add(_BulletLine(
            content: line.substring(2),
            spans: _parseInline(line.substring(2)),
            alignment: alignment));
      } else if (numMatch != null) {
        widgets.add(_NumberedLine(
            num: numMatch.group(1)!,
            spans: _parseInline(numMatch.group(2)!),
            alignment: alignment));
      } else {
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: RichText(
            textAlign: alignment,
            text: TextSpan(style: _base, children: _parseInline(line)),
          ),
        ));
      }
    }

    return Column(
      crossAxisAlignment: alignment == TextAlign.center
          ? CrossAxisAlignment.center
          : alignment == TextAlign.right
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
      children: widgets,
    );
  }
}

class _BulletLine extends StatelessWidget {
  final String content;
  final List<InlineSpan> spans;
  final TextAlign alignment;
  const _BulletLine(
      {required this.content, required this.spans, required this.alignment});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('• ',
            style: TextStyle(
                fontSize: 13.5, height: 1.8, color: Color(0xFF1A1A1A))),
        Expanded(
          child: RichText(
            textAlign: alignment,
            text: TextSpan(
                style: const TextStyle(
                    fontSize: 13.5, height: 1.8, color: Color(0xFF1A1A1A)),
                children: spans),
          ),
        ),
      ]),
    );
  }
}

class _NumberedLine extends StatelessWidget {
  final String num;
  final List<InlineSpan> spans;
  final TextAlign alignment;
  const _NumberedLine(
      {required this.num, required this.spans, required this.alignment});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('$num. ',
            style: const TextStyle(
                fontSize: 13.5, height: 1.8, color: Color(0xFF1A1A1A))),
        Expanded(
          child: RichText(
            textAlign: alignment,
            text: TextSpan(
                style: const TextStyle(
                    fontSize: 13.5, height: 1.8, color: Color(0xFF1A1A1A)),
                children: spans),
          ),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _DocFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFAFAFA),
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
      child: const Column(children: [
        Divider(color: Color(0xFFEEEEEE), height: 0),
        SizedBox(height: 10),
        Text('LYCEUM NORTHWESTERN UNIVERSITY — LINKUP NOTIFICATION SYSTEM',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 8,
                color: Color(0xFFBBBBBB),
                letterSpacing: 0.5,
                fontWeight: FontWeight.w600)),
        SizedBox(height: 3),
        Text('VERSION 0.1  |  PRIVACY POLICY  |  TERMS AND CONDITIONS',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 7.5, color: Color(0xFFCCCCCC), letterSpacing: 0.3)),
      ]),
    );
  }
}
