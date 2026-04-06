import '../models/notification_item.dart';

class AppData {
  static final List<NotificationItem> notifications = [
    NotificationItem(
      id: '1',
      type: 'spreadsheet',
      title: 'Spreadsheet shared with you:\n"PAASCU Accreditation Docs Status"',
      sender: 'Mr. Zachary Javelona',
      department: 'QUALITY ASSURANCE',
      date: '03- 12 - 2026',
      time: '01:35 PM',
    ),
    NotificationItem(
      id: '2',
      type: 'memo',
      title: 'SAS MEMO NO 06 Series of 2026',
      sender: 'Mr. Zachary Javelona',
      department: 'QUALITY ASSURANCE',
      date: '03- 12 - 2026',
      time: '01:35 PM',
      content: memoContent,
    ),
    NotificationItem(
      id: '3',
      type: 'memo',
      title: 'SAS MEMO NO 06 Series of 2026',
      sender: 'Mr. Zachary Javelona',
      department: 'QUALITY ASSURANCE',
      date: '03- 12 - 2026',
      time: '01:35 PM',
      content: memoContent,
    ),
    NotificationItem(
      id: '4',
      type: 'spreadsheet',
      title: 'Spreadsheet shared with you:\n"PAASCU Accreditation Docs Status"',
      sender: 'Mr. Zachary Javelona',
      department: 'QUALITY ASSURANCE',
      date: '03- 12 - 2026',
      time: '01:35 PM',
    ),
  ];

  static List<NotificationItem> get active =>
      notifications.where((n) => !n.isArchived).toList();

  static List<NotificationItem> get archived =>
      notifications.where((n) => n.isArchived).toList();

  static const String memoContent = '''Mr. Zachary Javelona

To: GRADUATING STUDENTS (2nd Semester, A.Y. 2025-2026)
Thru: ALL DEANS AND ACADEMIC HEADS
Subject: GRADUATION PICTORIAL


Please be advised of the following guidelines regarding the graduation pictorial for 2nd Semester Candidates for Graduation A.Y. 2025–2026:
  1. All graduating students may now book their appointments for graduation photo sessions at Francis Portraits, for both batch and virtual/online yearbook purposes. For bookings and inquiries, please contact: (075) 522-0896 or 09190792265.
  2. Formal attire pictorial (half body only) is as follows:
·      Men: Beige long-sleeves Barong Tagalog
·      Women: Beige Filipiniana blouse (modern or traditional)
  1. The toga for each program will be provided by the accredited studio.
  2. Please note that payment for this purpose is not included in the graduation fee. Students are advised to settle their payments directly with the studio.
  3. Students are not required to submit their photographs to this office. The Yearbook Committee will directly coordinate with the accredited studio for the collection of all yearbook photos.
  4. The DEADLINE for graduation is on or before APRIL 30, 2026. Failure to comply with this deadline will result in exclusion from the official electronic "graduation photo presentation" (for Barong/Filipiniana portrait) on the day of the commencement exercises.
  5. Pictures taken in toga shall be used in the batch's ELECTRONIC YEARBOOK.
  6. Interested (graduating) students for a hardcopy of yearbook, please send your request to this email: alumni@lyceum.edu.ph for confirmation (Cost not included in the graduation fee).
For guidance and compliance.

(SGD) EUGENE M. REYES, CSASS, Ed.D., Ph.D.
Vice President, Student Affairs and Alumni Relations
Yearbook In-charge''';
}
