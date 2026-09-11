import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/models.dart';
import '../../services/firestore_service.dart';
import '../../providers/subject_provider.dart';

class DictionaryScreen extends StatefulWidget {
  const DictionaryScreen({super.key});

  @override
  State<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  final FirestoreService _firestore = FirestoreService();
  final FlutterTts _tts = FlutterTts();
  List<DictionaryEntry> _entries = [];
  String _searchQuery = '';
  bool _isLoading = true;
  String _selectedSubjectId = 'All';

  @override
  void initState() {
    super.initState();
    _loadEntries();
    _initTts();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('hi-IN');
    await _tts.setSpeechRate(0.5);
  }

  Future<void> _loadEntries() async {
    _entries = [];
    final snap = await FirebaseFirestore.instance
        .collection('dictionary')
        .orderBy('term')
        .get();
    setState(() {
      _entries =
          snap.docs.map((d) => DictionaryEntry.fromFirestore(d)).toList();
      _isLoading = false;
    });
  }

  List<DictionaryEntry> get _filteredEntries {
    var filtered = _entries;
    if (_selectedSubjectId != 'All') {
      filtered = filtered
          .where((e) => e.subjectId == _selectedSubjectId)
          .toList();
    }
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered
          .where((e) =>
              e.term.toLowerCase().contains(query) ||
              e.termHindi.contains(_searchQuery) ||
              e.definition.toLowerCase().contains(query))
          .toList();
    }
    return filtered;
  }

  Future<void> _speak(DictionaryEntry entry) async {
    await _tts.speak('${entry.term}. ${entry.definition}');
  }

  @override
  Widget build(BuildContext context) {
    final subjectProv = context.watch<SubjectProvider>();
    final subjects = subjectProv.subjects;

    final subjectChips = <(String id, String label)>[
      ('All', 'All'),
      ...subjects.map((s) => (s.id, s.name)),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Dictionary')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search terms...',
                prefixIcon: const Icon(Icons.search_rounded),
              ),
              onChanged: (value) =>
                  setState(() => _searchQuery = value),
            ),
          ),
          SizedBox(
            height: 45,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: subjectChips.length,
              itemBuilder: (context, index) {
                final (id, label) = subjectChips[index];
                final isSelected = id == _selectedSubjectId;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(label),
                    selected: isSelected,
                    onSelected: (_) =>
                        setState(() => _selectedSubjectId = id),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredEntries.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off_rounded,
                                size: 60,
                                color: Colors.grey.shade400),
                            const SizedBox(height: 8),
                            Text('No terms found',
                                style: GoogleFonts.poppins(
                                    color: Colors.grey)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 32),
                        itemCount: _filteredEntries.length,
                        itemBuilder: (context, index) {
                          final entry = _filteredEntries[index];
                          return _DictionaryCard(
                            entry: entry,
                            onSpeak: () => _speak(entry),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _DictionaryCard extends StatelessWidget {
  final DictionaryEntry entry;
  final VoidCallback onSpeak;

  const _DictionaryCard({required this.entry, required this.onSpeak});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.term,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color:
                              Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      if (entry.termHindi.isNotEmpty)
                        Text(
                          entry.termHindi,
                          style: GoogleFonts.notoSansDevanagari(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onSpeak,
                  icon: const Icon(Icons.volume_up_rounded),
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              entry.definition,
              style: GoogleFonts.poppins(
                fontSize: 13,
                height: 1.6,
                color: Colors.grey.shade800,
              ),
            ),
            if (entry.definitionHindi.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                entry.definitionHindi,
                style: GoogleFonts.notoSansDevanagari(
                  fontSize: 13,
                  height: 1.6,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
            if (entry.example.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Example: ${entry.example}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
