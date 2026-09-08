import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../providers/subject_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/gamification_provider.dart';
import '../../models/models.dart';
import '../../services/offline_storage_service.dart';

class NotesViewerScreen extends StatefulWidget {
  final String chapterId;
  final String chapterTitle;
  final String subjectId;

  const NotesViewerScreen({
    super.key,
    required this.chapterId,
    required this.chapterTitle,
    required this.subjectId,
  });

  @override
  State<NotesViewerScreen> createState() => _NotesViewerScreenState();
}

class _NotesViewerScreenState extends State<NotesViewerScreen> {
  final FlutterTts _tts = FlutterTts();
  final OfflineStorageService _offline = OfflineStorageService();
  bool _isPlaying = false;
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _initTTS();
    _checkConnectivity();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SubjectProvider>().loadNotes(widget.chapterId);
      _awardNoteCoins();
    });
  }

  Future<void> _checkConnectivity() async {
    final results = await Connectivity().checkConnectivity();
    final isOffline = results.contains(ConnectivityResult.none);
    setState(() => _isOffline = isOffline);
    if (isOffline) {
      await _loadOfflineNotes();
    }
  }

  Future<void> _loadOfflineNotes() async {
    final cached = await _offline.getCachedNotes(widget.chapterId);
    if (cached.isNotEmpty && context.mounted) {
      // Handle offline
    }
  }

  Future<void> _initTTS() async {
    await _tts.setLanguage('hi-IN');
    await _tts.setSpeechRate(0.5);
    await _tts.setPitch(1.0);
    _tts.setCompletionHandler(() {
      setState(() => _isPlaying = false);
    });
  }

  void _awardNoteCoins() {
    final auth = context.read<AuthProvider>();
    final gam = context.read<GamificationProvider>();
    if (auth.user != null) {
      gam.earnCoins(
        auth.user!.uid,
        3,
        'Reading notes',
      );
    }
  }

  Future<void> _speakNote(NoteModel note) async {
    if (_isPlaying) {
      await _tts.stop();
      setState(() => _isPlaying = false);
    } else {
      final text = '${note.title}. ${note.content}';
      await _tts.speak(text);
      setState(() => _isPlaying = true);
    }
  }

  Future<void> _toggleBookmark(NoteModel note) async {
    final auth = context.read<AuthProvider>();
    if (auth.user == null) return;
    await _offline.saveBookmark(
      userId: auth.user!.uid,
      type: 'note',
      contentId: note.id,
      chapterId: note.chapterId,
      subjectId: note.subjectId,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bookmarked successfully!')),
      );
    }
  }

  Future<void> _downloadForOffline(NoteModel note) async {
    final auth = context.read<AuthProvider>();
    if (auth.user == null) return;

    setState(() {});
    await _offline.cacheNoteEncrypted(
      userId: auth.user!.uid,
      note: note,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Downloaded for offline reading!')),
      );
    }
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subjectProv = context.watch<SubjectProvider>();
    final notes = subjectProv.notes;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.chapterTitle,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      body: subjectProv.isLoading
          ? const Center(child: CircularProgressIndicator())
          : notes.isEmpty
              ? _EmptyNotes()
              : _buildNotesList(notes),
      floatingActionButton: notes.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => _speakNote(notes.first),
              icon: Icon(_isPlaying ? Icons.stop_rounded : Icons.volume_up_rounded),
              label: Text(_isPlaying ? 'Stop' : 'Listen'),
            )
          : null,
    );
  }

  Widget _buildNotesList(List<NoteModel> notes) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return _NotePage(
          note: note,
          isPlaying: _isPlaying,
          onSpeak: () => _speakNote(note),
          onBookmark: () => _toggleBookmark(note),
          onDownload: () => _downloadForOffline(note),
        );
      },
    );
  }
}

class _NotePage extends StatelessWidget {
  final NoteModel note;
  final bool isPlaying;
  final VoidCallback onSpeak;
  final VoidCallback onBookmark;
  final VoidCallback onDownload;

  const _NotePage({
    required this.note,
    required this.isPlaying,
    required this.onSpeak,
    required this.onBookmark,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Page ${note.pageNumber}',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: onBookmark,
                icon: const Icon(Icons.bookmark_border_rounded, size: 20),
                color: Colors.grey,
              ),
              IconButton(
                onPressed: onDownload,
                icon: const Icon(Icons.download_rounded, size: 20),
                color: Colors.grey,
              ),
              IconButton(
                onPressed: onSpeak,
                icon: Icon(
                  isPlaying ? Icons.stop_rounded : Icons.volume_up_rounded,
                  size: 20,
                  color: isPlaying
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            note.title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            note.content,
            style: GoogleFonts.poppins(
              fontSize: 14,
              height: 1.8,
              color: Colors.grey.shade800,
            ),
          ),
          if (note.contentHindi.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                note.contentHindi,
                style: GoogleFonts.notoSansDevanagari(
                  fontSize: 14,
                  height: 1.8,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          ],
          if (note.imageUrl.isNotEmpty) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: note.imageUrl,
                placeholder: (_, __) => Container(
                  height: 200,
                  color: Colors.grey.shade100,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (_, __, ___) => Container(
                  height: 200,
                  color: Colors.grey.shade100,
                  child: const Icon(Icons.broken_image_rounded),
                ),
              ),
            ),
          ],
          if (note.keyPoints.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Key Points',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: Colors.amber.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  for (final point in note.keyPoints)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('•  ', style: TextStyle(color: Colors.amber)),
                          Expanded(
                            child: Text(
                              point,
                              style: GoogleFonts.poppins(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyNotes extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.menu_book_rounded,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Notes coming soon!',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We are preparing quality content for this chapter',
            style: GoogleFonts.poppins(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
