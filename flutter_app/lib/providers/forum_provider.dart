import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';
import '../services/firestore_service.dart';

class ForumProvider extends ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();

  List<ForumPost> _posts = [];
  bool _isLoading = false;
  String? _selectedSubjectFilter;

  List<ForumPost> get posts => _posts;
  bool get isLoading => _isLoading;

  void loadPosts({String? subjectId}) {
    _selectedSubjectFilter = subjectId;
    _isLoading = true;
    notifyListeners();

    _firestore.streamForumPosts(subjectId: subjectId).listen((posts) {
      _posts = posts;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> createPost({
    required String authorId,
    required String authorName,
    required String subjectId,
    required String title,
    required String body,
    String? chapterId,
    List<String> tags = const ['doubt'],
  }) async {
    final post = ForumPost(
      id: '',
      authorId: authorId,
      authorName: authorName,
      subjectId: subjectId,
      chapterId: chapterId,
      title: title,
      body: body,
      tags: tags,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _firestore.createForumPost(post);
  }

  Future<void> reply(String postId, String authorId, String authorName,
      String body) async {
    await _firestore.replyToPost(postId, authorId, authorName, body);
  }

  Stream<QuerySnapshot> streamReplies(String postId) {
    return _firestore.streamReplies(postId);
  }

  Future<void> upvote(String postId, String userId) async {
    await _firestore.upvotePost(postId, userId);
  }

  Future<void> markResolved(String postId) async {
    await _firestore.markPostResolved(postId);
  }
}
