import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';

class SubjectCard extends StatelessWidget {
  final SubjectModel subject;
  const SubjectCard({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.pushNamed(context, '/chapters', arguments: {
              'subjectId': subject.id,
              'subjectName': subject.name,
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: subject.themeColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    _subjectIcon(subject.name),
                    color: subject.themeColor,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  subject.name,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subject.nameHindi,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _subjectIcon(String name) {
    switch (name.toLowerCase()) {
      case 'history':
        return Icons.account_balance_rounded;
      case 'political science':
        return Icons.gavel_rounded;
      case 'economics':
        return Icons.trending_up_rounded;
      case 'geography':
        return Icons.public_rounded;
      case 'sociology':
        return Icons.people_rounded;
      case 'psychology':
        return Icons.psychology_rounded;
      default:
        return Icons.book_rounded;
    }
  }
}
