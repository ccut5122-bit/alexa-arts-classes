import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../providers/subject_provider.dart';
import '../../models/models.dart';

class ChapterListScreen extends StatefulWidget {
  final String subjectId;
  final String subjectName;

  const ChapterListScreen({
    super.key,
    required this.subjectId,
    required this.subjectName,
  });

  @override
  State<ChapterListScreen> createState() => _ChapterListScreenState();
}

class _ChapterListScreenState extends State<ChapterListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SubjectProvider>().loadChapters(widget.subjectId);
    });
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
        title: Text(widget.subjectName),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Notes'),
            Tab(text: 'MCQs'),
            Tab(text: 'Progress'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _NotesTab(subjectId: widget.subjectId, subjectName: widget.subjectName),
          _McqTab(subjectId: widget.subjectId, subjectName: widget.subjectName),
          _ProgressTab(subjectId: widget.subjectId),
        ],
      ),
    );
  }
}

class _NotesTab extends StatelessWidget {
  final String subjectId;
  final String subjectName;

  const _NotesTab({
    required this.subjectId,
    required this.subjectName,
  });

  @override
  Widget build(BuildContext context) {
    final subjectProv = context.watch<SubjectProvider>();
    final chapters = subjectProv.chapters;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search chapters...',
              prefixIcon: const Icon(Icons.search_rounded),
              hintStyle: GoogleFonts.poppins(color: Colors.grey),
            ),
            onChanged: (value) {},
          ),
        ),
        Expanded(
          child: subjectProv.isLoading
              ? const Center(child: CircularProgressIndicator())
              : chapters.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.menu_book_rounded,
                            size: 80,
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No chapters found',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Content is being uploaded soon',
                            style: GoogleFonts.poppins(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : AnimationLimiter(
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: chapters.length,
                        itemBuilder: (context, index) {
                          final chapter = chapters[index];
                          return AnimationConfiguration.staggeredList(
                            position: index,
                            child: SlideAnimation(
                              verticalOffset: 50,
                              child: FadeInAnimation(
                                child: _ChapterCard(
                                  chapter: chapter,
                                  subjectName: subjectName,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }
}

class _ChapterCard extends StatelessWidget {
  final ChapterModel chapter;
  final String subjectName;

  const _ChapterCard({required this.chapter, required this.subjectName});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              '${chapter.chapterNumber}',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),
        title: Text(
          chapter.title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Row(
            children: [
              _InfoChip(
                icon: Icons.menu_book_rounded,
                label: '${chapter.totalNotesPages} pages',
              ),
              const SizedBox(width: 8),
              _InfoChip(
                icon: Icons.quiz_rounded,
                label: '${chapter.totalMcqs} MCQs',
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: chapter.difficultyColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  chapter.difficulty.toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: chapter.difficultyColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 18,
          color: Colors.grey.shade400,
        ),
        onTap: () {
          Navigator.pushNamed(context, '/notes', arguments: {
            'chapterId': chapter.id,
            'chapterTitle': chapter.title,
            'subjectId': chapter.subjectId,
          });
        },
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey),
        ),
      ],
    );
  }
}

class _McqTab extends StatelessWidget {
  final String subjectId;
  final String subjectName;

  const _McqTab({required this.subjectId, required this.subjectName});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.quiz_rounded,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Test Your Knowledge',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Take chapter-wise MCQ tests',
            style: GoogleFonts.poppins(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/quiz', arguments: {
                'subjectId': subjectId,
                'chapterIds': const [],
                'quizTitle': '$subjectName Practice Test',
                'timeLimit': 15,
                'negativeMarking': true,
              });
            },
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Start Mock Test'),
          ),
        ],
      ),
    );
  }
}

class _ProgressTab extends StatelessWidget {
  final String subjectId;

  const _ProgressTab({required this.subjectId});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_rounded,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Track Your Progress',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'More chapters you study, more progress you see',
            style: GoogleFonts.poppins(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
