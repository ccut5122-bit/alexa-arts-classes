import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../services/offline_storage_service.dart';
import '../../providers/auth_provider.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  final OfflineStorageService _offline = OfflineStorageService();
  List<Map<String, dynamic>> _bookmarks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _offline.init().then((_) => _loadBookmarks());
  }

  Future<void> _loadBookmarks() async {
    final auth = context.read<AuthProvider>();
    if (auth.user == null) return;

    final bookmarks = await _offline.getBookmarks(auth.user!.uid);
    setState(() {
      _bookmarks = bookmarks;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Bookmarks')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _bookmarks.isEmpty
              ? _EmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _bookmarks.length,
                  itemBuilder: (context, index) {
                    final bookmark = _bookmarks[index];
                    final type = bookmark['type'] ?? 'note';
                    final title = bookmark['contentId'] ?? '';
                    final createdAt = bookmark['createdAt'] ?? '';

                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          child: Icon(
                            type == 'note'
                                ? Icons.menu_book_rounded
                                : type == 'question'
                                    ? Icons.quiz_rounded
                                    : Icons.folder_rounded,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        title: Text(
                          _formatTitle(title),
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          type.toUpperCase(),
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline_rounded),
                          onPressed: () async {
                            await _offline.removeBookmark(title);
                            _loadBookmarks();
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  String _formatTitle(String id) {
    final parts = id.split('_');
    if (parts.length >= 2) {
      return 'Content ${parts.last}';
    }
    return id;
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmark_border_rounded,
              size: 80, color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text('No bookmarks yet',
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('Save notes and questions you want to review later',
              style: GoogleFonts.poppins(color: Colors.grey)),
        ],
      ),
    );
  }
}
