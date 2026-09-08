import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/config_provider.dart';

class ExamCountdownCard extends StatefulWidget {
  const ExamCountdownCard({super.key});

  @override
  State<ExamCountdownCard> createState() => _ExamCountdownCardState();
}

class _ExamCountdownCardState extends State<ExamCountdownCard> {
  @override
  Widget build(BuildContext context) {
    final config = context.watch<ConfigProvider>();
    final examDates = config.examDates;

    if (examDates.isEmpty) return const SizedBox.shrink();

    final exam = examDates.first;
    final examDate = DateTime.tryParse(exam['date'] ?? '');
    if (examDate == null) return const SizedBox.shrink();

    final daysRemaining = examDate.difference(DateTime.now()).inDays;
    final isPassed = daysRemaining < 0;
    final cardMargin =
        (Theme.of(context).cardTheme.margin as EdgeInsets?) ?? EdgeInsets.zero;

    return Container(
      margin: EdgeInsets.only(
        left: cardMargin.left,
        right: cardMargin.right,
        top: cardMargin.top,
      ),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.event_available_rounded,
                    color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exam['name'] ?? 'JAC Board Exam',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      DateFormat('MMM dd, yyyy').format(examDate),
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (isPassed)
            Text(
              'Exam Completed! 🎉',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            )
          else
            Row(
              children: [
                _CountdownUnit(value: daysRemaining, label: 'Days'),
                const SizedBox(width: 12),
                Container(
                  width: 1, height: 32,
                  color: Colors.white.withOpacity(0.3),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: LinearProgressIndicator(
                    value: 0.4,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.white),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _CountdownUnit extends StatelessWidget {
  final int value;
  final String label;

  const _CountdownUnit({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$value',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 28,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
