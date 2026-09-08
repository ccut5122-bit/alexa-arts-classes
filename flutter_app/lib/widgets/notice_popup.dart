import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/config_provider.dart';

class NoticePopup extends StatelessWidget {
  const NoticePopup({super.key});

  @override
  Widget build(BuildContext context) {
    final config = context.watch<ConfigProvider>();
    final notices = config.notices;
    final popupNotices = notices.where((n) => n['isPopup'] == true).toList();
    final popupNotice = popupNotices.isNotEmpty ? popupNotices.first : null;

    if (popupNotice == null) {
      return Column(
        children: [
          for (final notice in config.notices)
            if (notice['isPopup'] != true)
              _NoticeBanner(notice: notice),
        ],
      );
    }

    // Show popup dialog on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          icon: Icon(
            _typeIcon(popupNotice['type']),
            size: 48,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: Text(
            popupNotice['title'] ?? '',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
          ),
          content: Text(
            popupNotice['body'] ?? '',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'OK',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
    });

    return Column(
      children: [
        for (final notice in config.notices)
          if (notice['isPopup'] != true)
            _NoticeBanner(notice: notice),
      ],
    );
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'urgent':
        return Icons.warning_amber_rounded;
      case 'warning':
        return Icons.info_rounded;
      default:
        return Icons.campaign_rounded;
    }
  }
}

class _NoticeBanner extends StatelessWidget {
  final Map<String, dynamic> notice;
  const _NoticeBanner({required this.notice});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.campaign_rounded,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              notice['title'] ?? '',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
