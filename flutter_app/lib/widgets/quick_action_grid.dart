import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/subject_provider.dart';

class QuickActionGrid extends StatelessWidget {
  const QuickActionGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = <_QuickAction>[
      _QuickAction(
        icon: Icons.quiz_rounded,
        label: 'Practice Test',
        color: const Color(0xFF4CAF50),
        onTap: (context) => _startPracticeTest(context),
      ),
      _QuickAction(
        icon: Icons.history_edu_rounded,
        label: 'PYQs',
        color: const Color(0xFF2196F3),
        onTap: (context) => Navigator.pushNamed(context, '/exam-prep'),
      ),
      _QuickAction(
        icon: Icons.auto_awesome_rounded,
        label: 'Smart Revision',
        color: const Color(0xFF9C27B0),
        onTap: (context) => _startSmartRevision(context),
      ),
      _QuickAction(
        icon: Icons.forum_rounded,
        label: 'Doubts',
        color: const Color(0xFFFF9800),
        onTap: (context) => Navigator.pushNamed(context, '/forum'),
      ),
    ];

    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      childAspectRatio: 0.92,
      children: List.generate(actions.length, (index) {
        final action = actions[index];
        return InkWell(
          onTap: () => action.onTap(context),
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: action.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(action.icon, color: action.color, size: 26),
              ),
              const SizedBox(height: 8),
              Text(
                action.label,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  void _startPracticeTest(BuildContext context) {
    final subjects = context.read<SubjectProvider>().subjects;
    if (subjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No subjects available yet')),
      );
      return;
    }
    _showSubjectPicker(
      context,
      subjects.map((s) => s.name).toList(),
      isRevision: false,
    );
  }

  void _startSmartRevision(BuildContext context) {
    final subjects = context.read<SubjectProvider>().subjects;
    if (subjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No subjects available yet')),
      );
      return;
    }
    _showSubjectPicker(
      context,
      subjects.map((s) => s.name).toList(),
      isRevision: true,
    );
  }

  void _showSubjectPicker(
    BuildContext context,
    List<String> subjects, {
    required bool isRevision,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                isRevision ? 'Smart Revision - Select Subject' : 'Practice Test - Select Subject',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: subjects.length,
                itemBuilder: (context, index) {
                  final subject = subjects[index];
                  return ListTile(
                    leading: Icon(
                      isRevision
                          ? Icons.auto_awesome_rounded
                          : Icons.quiz_rounded,
                      color: isRevision
                          ? const Color(0xFF9C27B0)
                          : const Color(0xFF4CAF50),
                    ),
                    title: Text(
                      subject,
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                    ),
                    onTap: () {
                      Navigator.pop(sheetCtx);
                      Navigator.pushNamed(context, '/quiz', arguments: {
                        'subjectId': subject,
                        'chapterIds': const <String>[],
                        'quizTitle': isRevision
                            ? '$subject Smart Revision'
                            : '$subject Practice Test',
                        'timeLimit': isRevision ? 20 : 15,
                        'negativeMarking': true,
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final void Function(BuildContext) onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}