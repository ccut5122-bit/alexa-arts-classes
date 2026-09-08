import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/forum_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/subject_provider.dart';
import '../../models/models.dart';

class ForumScreen extends StatefulWidget {
  const ForumScreen({super.key});

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  String? _selectedSubject;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ForumProvider>().loadPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final forum = context.watch<ForumProvider>();
    final subjects = context.watch<SubjectProvider>().subjects;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doubts Forum'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => _showNewPostDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Subject filter
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: const Text('All'),
                    selected: _selectedSubject == null,
                    onSelected: (_) {
                      setState(() => _selectedSubject = null);
                      forum.loadPosts();
                    },
                  ),
                ),
                for (final subject in subjects)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(subject.name),
                      selected: _selectedSubject == subject.name,
                      onSelected: (_) {
                        setState(() => _selectedSubject = subject.name);
                        forum.loadPosts(subjectId: subject.name);
                      },
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Posts
          Expanded(
            child: forum.isLoading
                ? const Center(child: CircularProgressIndicator())
                : forum.posts.isEmpty
                    ? _EmptyForum()
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: forum.posts.length,
                        itemBuilder: (context, index) {
                          final post = forum.posts[index];
                          return _ForumPostCard(post: post);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showNewPostDialog,
        icon: const Icon(Icons.chat_bubble_outline_rounded),
        label: const Text('Ask Doubt'),
      ),
    );
  }

  void _showNewPostDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _NewPostSheet(
        onPosted: () {
          Navigator.pop(ctx);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Your doubt has been posted!')),
          );
        },
      ),
    );
  }
}

class _NewPostSheet extends StatefulWidget {
  final VoidCallback onPosted;
  const _NewPostSheet({required this.onPosted});

  @override
  State<_NewPostSheet> createState() => _NewPostSheetState();
}

class _NewPostSheetState extends State<_NewPostSheet> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  String? _selectedSubject;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final subjects = context.watch<SubjectProvider>().subjects;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Post Your Doubt',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedSubject,
              decoration: const InputDecoration(labelText: 'Subject *'),
              items: subjects
                  .map((s) =>
                      DropdownMenuItem(value: s.name, child: Text(s.name)))
                  .toList(),
              onChanged: (value) => setState(() => _selectedSubject = value),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Question Title *',
                hintText: 'e.g., Difference between Federalism and Unitary State',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _bodyController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Describe your doubt *',
                alignLabelWithHint: true,
                hintText: 'Explain your doubt in detail...',
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submit,
                icon: const Icon(Icons.send_rounded),
                label: Text(_isSubmitting ? 'Posting...' : 'Post Doubt'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_titleController.text.isEmpty ||
        _bodyController.text.isEmpty ||
        _selectedSubject == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all the required fields')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final auth = context.read<AuthProvider>();
    final forum = context.read<ForumProvider>();

    await forum.createPost(
      authorId: auth.user?.uid ?? '',
      authorName: auth.userModel?.displayName ?? 'Student',
      subjectId: _selectedSubject!,
      title: _titleController.text,
      body: _bodyController.text,
    );

    widget.onPosted();
  }
}

class _ForumPostCard extends StatefulWidget {
  final ForumPost post;
  const _ForumPostCard({required this.post});

  @override
  State<_ForumPostCard> createState() => _ForumPostCardState();
}

class _ForumPostCardState extends State<_ForumPostCard> {
  bool _showReplies = false;

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final forum = context.watch<ForumProvider>();
    final auth = context.watch<AuthProvider>();

    return Card(
      child: InkWell(
        onTap: () => setState(() => _showReplies = !_showReplies),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: post.authorPhoto.isNotEmpty == true
                        ? NetworkImage(post.authorPhoto)
                        : null,
                    child: post.authorPhoto.isEmpty == true
                        ? Text(post.authorName[0].toUpperCase())
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.authorName,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _timeAgo(post.createdAt),
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      post.subjectId,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                post.title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                post.body,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  height: 1.6,
                  color: Colors.grey.shade700,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  InkWell(
                    onTap: auth.user != null
                        ? () => forum.upvote(post.id, auth.user!.uid)
                        : null,
                    child: Row(
                      children: [
                        Icon(
                          Icons.thumb_up_alt_rounded,
                          size: 18,
                          color: post.upvotedBy.contains(auth.user?.uid)
                              ? Colors.blue
                              : Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text('${post.upvotes}',
                            style: GoogleFonts.poppins(fontSize: 12)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  InkWell(
                    onTap: () => setState(() => _showReplies = !_showReplies),
                    child: Row(
                      children: [
                        const Icon(Icons.chat_bubble_outline_rounded,
                            size: 18, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text('Replies',
                            style: GoogleFonts.poppins(
                                fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (post.isResolved)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded,
                              size: 14, color: Colors.green),
                          const SizedBox(width: 4),
                          Text('Resolved',
                              style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green)),
                        ],
                      ),
                    ),
                ],
              ),
              if (_showReplies) ...[
                const Divider(height: 24),
                _RepliesSection(postId: post.id),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${time.day}/${time.month}/${time.year}';
  }
}

class _RepliesSection extends StatefulWidget {
  final String postId;
  const _RepliesSection({required this.postId});

  @override
  State<_RepliesSection> createState() => _RepliesSectionState();
}

class _RepliesSectionState extends State<_RepliesSection> {
  final _replyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final forum = context.watch<ForumProvider>();
    final auth = context.watch<AuthProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StreamBuilder<QuerySnapshot>(
          stream: forum.streamReplies(widget.postId),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Error loading replies',
                  style: GoogleFonts.poppins(color: Colors.red));
            }
            if (!snapshot.hasData) {
              return const SizedBox(
                height: 50,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final replies = snapshot.data!.docs;
            if (replies.isEmpty) {
              return Text('No replies yet. Be the first to help!',
                  style: GoogleFonts.poppins(
                      fontSize: 12, color: Colors.grey));
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: replies.map((doc) {
                final reply = doc.data() as Map<String, dynamic>;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 14,
                        child: Text(
                          (reply['authorName'] ?? '?')[0].toUpperCase(),
                          style: GoogleFonts.poppins(fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    reply['authorName'] ?? '',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                if (reply['isAccepted'] == true)
                                  const Icon(Icons.check_circle_rounded,
                                      size: 14, color: Colors.green),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              reply['body'] ?? '',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _replyController,
                decoration: InputDecoration(
                  hintText: 'Write a reply...',
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: () async {
                if (_replyController.text.isEmpty) return;
                await forum.reply(
                  widget.postId,
                  auth.user?.uid ?? '',
                  auth.userModel?.displayName ?? 'Student',
                  _replyController.text,
                );
                _replyController.clear();
              },
              icon: const Icon(Icons.send_rounded, size: 18),
            ),
          ],
        ),
      ],
    );
  }
}

class _EmptyForum extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.forum_outlined,
              size: 80, color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text('No questions yet',
              style:
                  GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('Ask your first doubt!',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }
}
