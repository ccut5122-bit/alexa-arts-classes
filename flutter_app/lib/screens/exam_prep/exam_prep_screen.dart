import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/config_provider.dart';
import '../../models/models.dart';
import '../../services/firestore_service.dart';

class ExamPrepScreen extends StatefulWidget {
  const ExamPrepScreen({super.key});

  @override
  State<ExamPrepScreen> createState() => _ExamPrepScreenState();
}

class _ExamPrepScreenState extends State<ExamPrepScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JAC Exam Prep'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Date Sheet'),
            Tab(text: 'PYQs'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const _DateSheetTab(),
          const _PYQsTab(),
        ],
      ),
    );
  }
}

class _DateSheetTab extends StatelessWidget {
  const _DateSheetTab();

  @override
  Widget build(BuildContext context) {
    final config = context.watch<ConfigProvider>();
    final examDates = config.examDates;

    return examDates.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_available, size: 80, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text('No exam dates available',
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text('Stay tuned for JAC Board exam schedule',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(color: Colors.grey)),
              ],
            ),
          )
        : ListView(
            children: [
              for (final exam in examDates) _ExamDateCard(exam: exam),
            ],
          );
  }
}

class _ExamDateCard extends StatelessWidget {
  final Map<String, dynamic> exam;
  const _ExamDateCard({required this.exam});

  @override
  Widget build(BuildContext context) {
    final name = exam['name'] ?? '';
    final date = DateTime.tryParse(exam['date'] ?? '');
    final subjects = exam['subjects'] as List<dynamic>? ?? [];

    if (date == null) return const SizedBox.shrink();

    final daysRemaining = date.difference(DateTime.now()).inDays;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.school_rounded,
                    color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    name,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: daysRemaining <= 30
                        ? Colors.red.withOpacity(0.1)
                        : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    daysRemaining <= 30
                        ? '$daysRemaining days left! Hurry up!'
                        : '$daysRemaining days remaining',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: daysRemaining <= 30 ? Colors.red : Colors.green,
                    ),
                  ),
                ),
              ],
            ),
            if (subjects.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('Subject-wise Schedule:',
                  style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              for (final subject in subjects)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.circle, size: 6, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          subject['name'] ?? '',
                          style: GoogleFonts.poppins(fontSize: 12),
                        ),
                      ),
                      Text(
                        DateFormat('dd MMM').format(
                          DateTime.tryParse(subject['date'] ?? '') ?? DateTime.now(),
                        ),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PYQsTab extends StatefulWidget {
  const _PYQsTab();

  @override
  State<_PYQsTab> createState() => _PYQsTabState();
}

class _PYQsTabState extends State<_PYQsTab> {
  final FirestoreService _firestore = FirestoreService();
  List<QuestionModel> _pyqQuestions = [];
  bool _isLoading = true;
  String _selectedSubject = 'all';
  String _selectedYear = 'All';

  final List<Map<String, String>> _subjectOptions = [
    {'id': 'all', 'label': 'All Subjects'},
    {'id': 'history', 'label': 'History'},
    {'id': 'political_science', 'label': 'Political Science'},
    {'id': 'economics', 'label': 'Economics'},
    {'id': 'geography', 'label': 'Geography'},
    {'id': 'sociology', 'label': 'Sociology'},
    {'id': 'psychology', 'label': 'Psychology'},
  ];

  final List<String> _years = [
    'All', '2026', '2025', '2024', '2023', '2022', '2021', '2020', '2019', '2018', '2017',
  ];

  @override
  void initState() {
    super.initState();
    _loadPYQs();
  }

  Future<void> _loadPYQs() async {
    setState(() => _isLoading = true);
    final snap = await FirebaseFirestore.instance
        .collection('questions')
        .where('source', isEqualTo: 'JAC PYQ');

    var query = snap.get();
    final questions = (await query).docs
        .map((d) => QuestionModel.fromFirestore(d))
        .where((q) =>
            _selectedSubject == 'all' ||
            q.subjectId == _selectedSubject)
        .where((q) =>
            _selectedYear == 'All' ||
            (q.year?.toString() ?? '') == _selectedYear)
        .toList();

    setState(() {
      _pyqQuestions = questions;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedSubject,
                  decoration: const InputDecoration(
                    labelText: 'Subject',
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: _subjectOptions
                      .map((s) => DropdownMenuItem(
                          value: s['id'], child: Text(s['label'] ?? s['id']!)))
                      .toList(),
                  onChanged: (value) {
                    setState(() => _selectedSubject = value ?? 'all');
                    _loadPYQs();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedYear,
                  decoration: const InputDecoration(
                    labelText: 'Year',
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: _years
                      .map((y) => DropdownMenuItem(value: y, child: Text(y)))
                      .toList(),
                  onChanged: (value) {
                    setState(() => _selectedYear = value ?? 'All');
                    _loadPYQs();
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _pyqQuestions.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history_edu,
                              size: 80, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          Text('No PYQs found for this filter',
                              style: GoogleFonts.poppins(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 32),
                      itemCount: _pyqQuestions.length,
                      itemBuilder: (context, index) {
                        final question = _pyqQuestions[index];
                        return _PYQCard(question: question);
                      },
                    ),
        ),
      ],
    );
  }
}

class _PYQCard extends StatelessWidget {
  final QuestionModel question;

  const _PYQCard({required this.question});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            (question.year != null && question.year! > 0)
                ? '${question.year}'
                : 'PYQ',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        title: Text(
          question.questionText,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final option in question.options)
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: Text(
                          option.id.toUpperCase(),
                          style: GoogleFonts.poppins(fontSize: 11),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          option.text,
                          style: GoogleFonts.poppins(fontSize: 13),
                        ),
                      ),
                      if (option.id == question.correctOption)
                        const Icon(Icons.check_circle_rounded,
                            color: Colors.green, size: 18),
                    ],
                  ),
                const Divider(height: 24),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Explanation:',
                          style: GoogleFonts.poppins(
                              fontSize: 12, fontWeight: FontWeight.w700, color: Colors.blue)),
                      const SizedBox(height: 4),
                      Text(
                        question.explanation,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          height: 1.6,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _TagChip(label: question.source),
                    if (question.difficulty.isNotEmpty)
                      _TagChip(label: question.difficulty),
                    for (final tag in question.tags.take(2)) _TagChip(label: tag),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  const _TagChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey.shade700),
      ),
    );
  }
}
