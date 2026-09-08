import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ==================== USERS ====================
  Future<UserModel?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) return UserModel.fromFirestore(doc);
    return null;
  }

  Future<void> createUser(UserModel user) async {
    await _db.collection('users').doc(user.uid).set(user.toMap());
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update(data);
  }

  Future<void> updateStreak(String uid, GamificationData gam) async {
    await _db.collection('users').doc(uid).update({
      'gamification.streak.currentDays': gam.currentStreak,
      'gamification.streak.longestStreak': gam.longestStreak,
      'gamification.streak.lastStudyDate': gam.lastStudyDate != null
          ? '${gam.lastStudyDate!.year}-${gam.lastStudyDate!.month.toString().padLeft(2, '0')}-${gam.lastStudyDate!.day.toString().padLeft(2, '0')}'
          : null,
      'lastActive': FieldValue.serverTimestamp(),
    });
  }

  Future<void> addCoins(String uid, int amount) async {
    await _db.collection('users').doc(uid).update({
      'gamification.coins': FieldValue.increment(amount),
    });
  }

  Future<void> banUser(String uid, bool isBanned) async {
    await _db.collection('users').doc(uid).update({'isBanned': isBanned});
  }

  Stream<List<UserModel>> streamAllUsers() {
    return _db
        .collection('users')
        .orderBy('lastActive', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => UserModel.fromFirestore(d)).toList());
  }

  // ==================== SUBJECTS ====================
  Stream<List<SubjectModel>> streamSubjects() {
    return _db
        .collection('subjects')
        .orderBy('order')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => SubjectModel.fromFirestore(d)).toList());
  }

  Future<List<SubjectModel>> getSubjects() async {
    final snap = await _db.collection('subjects').orderBy('order').get();
    return snap.docs.map((d) => SubjectModel.fromFirestore(d)).toList();
  }

  Future<void> createSubject(SubjectModel subject) async {
    await _db.collection('subjects').doc(subject.id).set(subject.toMap());
  }

  Future<void> updateSubject(String id, Map<String, dynamic> data) async {
    await _db.collection('subjects').doc(id).update(data);
  }

  Future<void> deleteSubject(String id) async {
    await _db.collection('subjects').doc(id).delete();
  }

  // ==================== CHAPTERS ====================
  Stream<List<ChapterModel>> streamChapters(String subjectId) {
    return _db
        .collection('chapters')
        .where('subjectId', isEqualTo: subjectId)
        .orderBy('chapterNumber')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => ChapterModel.fromFirestore(d)).toList());
  }

  Future<List<ChapterModel>> getChapters(String subjectId) async {
    final snap = await _db
        .collection('chapters')
        .where('subjectId', isEqualTo: subjectId)
        .orderBy('chapterNumber')
        .get();
    return snap.docs.map((d) => ChapterModel.fromFirestore(d)).toList();
  }

  Future<void> createChapter(ChapterModel chapter) async {
    await _db.collection('chapters').doc(chapter.id).set(chapter.toMap());
  }

  Future<void> updateChapter(String id, Map<String, dynamic> data) async {
    await _db.collection('chapters').doc(id).update(data);
  }

  Future<void> deleteChapter(String id) async {
    await _db.collection('chapters').doc(id).delete();
  }

  // ==================== NOTES ====================
  Stream<List<NoteModel>> streamNotes(String chapterId) {
    return _db
        .collection('notes')
        .where('chapterId', isEqualTo: chapterId)
        .orderBy('pageNumber')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => NoteModel.fromFirestore(d)).toList());
  }

  Future<void> createNote(NoteModel note) async {
    await _db.collection('notes').doc(note.id).set(note.toMap());
  }

  Future<void> updateNote(String id, Map<String, dynamic> data) async {
    await _db.collection('notes').doc(id).update(data);
  }

  Future<void> deleteNote(String id) async {
    await _db.collection('notes').doc(id).delete();
  }

  // ==================== QUESTIONS ====================
  Stream<List<QuestionModel>> streamQuestions({
    String? subjectId,
    String? chapterId,
    String? difficulty,
    String? type,
  }) {
    Query query = _db.collection('questions');
    if (subjectId != null) query = query.where('subjectId', isEqualTo: subjectId);
    if (chapterId != null) query = query.where('chapterId', isEqualTo: chapterId);
    if (difficulty != null) query = query.where('difficulty', isEqualTo: difficulty);
    if (type != null) query = query.where('type', isEqualTo: type);

    return query.snapshots().map((snap) =>
        snap.docs.map((d) => QuestionModel.fromFirestore(d)).toList());
  }

  Future<List<QuestionModel>> getQuestionsForQuiz({
    required String subjectId,
    List<String>? chapterIds,
    int limit = 10,
    String? difficulty,
  }) async {
    Query query = _db.collection('questions').where('subjectId', isEqualTo: subjectId);
    if (chapterIds != null && chapterIds.isNotEmpty) {
      query = query.where('chapterId', whereIn: chapterIds);
    }
    if (difficulty != null) query = query.where('difficulty', isEqualTo: difficulty);
    query = query.limit(limit);

    final snap = await query.get();
    final questions =
        snap.docs.map((d) => QuestionModel.fromFirestore(d)).toList();
    questions.shuffle();
    return questions.take(limit).toList();
  }

  Future<List<QuestionModel>> getWrongQuestionsForRevision(String userId) async {
    final historySnap = await _db
        .collection('users')
        .doc(userId)
        .collection('quizHistory')
        .orderBy('completedAt', descending: true)
        .limit(5)
        .get();

    final wrongIds = <String>[];
    for (final doc in historySnap.docs) {
      final wrong = List<String>.from(doc.data()['wrongQuestions'] ?? []);
      wrongIds.addAll(wrong);
    }

    if (wrongIds.isEmpty) return [];

    final uniqueWrong = wrongIds.toSet().toList();
    final questions = <QuestionModel>[];
    for (final id in uniqueWrong.take(20)) {
      final doc = await _db.collection('questions').doc(id).get();
      if (doc.exists) {
        questions.add(QuestionModel.fromFirestore(doc));
      }
    }
    questions.shuffle();
    return questions.take(15).toList();
  }

  Future<void> createQuestion(QuestionModel question) async {
    await _db.collection('questions').doc(question.id).set(question.toMap());
  }

  Future<void> updateQuestion(String id, Map<String, dynamic> data) async {
    await _db.collection('questions').doc(id).update(data);
  }

  Future<void> deleteQuestion(String id) async {
    await _db.collection('questions').doc(id).delete();
  }

  Future<void> bulkCreateQuestions(List<QuestionModel> questions) async {
    final batch = _db.batch();
    for (final q in questions) {
      final ref = _db.collection('questions').doc();
      batch.set(ref, q.toMap());
    }
    await batch.commit();
  }

  // ==================== QUIZZES ====================
  Stream<List<QuizModel>> streamQuizzes({String? type, bool? isLive}) {
    Query query = _db.collection('quizzes');
    if (type != null) query = query.where('type', isEqualTo: type);
    if (isLive != null) query = query.where('isLive', isEqualTo: isLive);
    return query
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
            (snap) => snap.docs.map((d) => QuizModel.fromFirestore(d)).toList());
  }

  Future<void> createQuiz(QuizModel quiz) async {
    await _db.collection('quizzes').doc(quiz.id).set(quiz.toMap());
  }

  Future<void> updateQuiz(String id, Map<String, dynamic> data) async {
    await _db.collection('quizzes').doc(id).update(data);
  }

  Future<void> deleteQuiz(String id) async {
    await _db.collection('quizzes').doc(id).delete();
  }

  Future<void> submitQuizResult(
      String userId, String quizId, Map<String, dynamic> result) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('quizHistory')
        .doc(quizId)
        .set(result);
    await _db.collection('users').doc(userId).update({
      'gamification.totalQuizzesAttempted': FieldValue.increment(1),
      'gamification.totalCorrectAnswers':
          FieldValue.increment(result['correctAnswers'] ?? 0),
    });
  }

  // ==================== LEADERBOARD ====================
  Stream<List<Map<String, dynamic>>> streamLeaderboard({String period = 'allTime'}) {
    return _db
        .collection('leaderboard')
        .doc(period)
        .collection('entries')
        .orderBy('coins', descending: true)
        .limit(100)
        .snapshots()
        .map((snap) => snap.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }

  Future<void> updateLeaderboard(String userId, Map<String, dynamic> data) async {
    for (final period in ['weekly', 'monthly', 'allTime']) {
      await _db
          .collection('leaderboard')
          .doc(period)
          .collection('entries')
          .doc(userId)
          .set(data, SetOptions(merge: true));
    }
  }

  // ==================== FORUM ====================
  Stream<List<ForumPost>> streamForumPosts({String? subjectId}) {
    Query query = _db
        .collection('forum')
        .where('isDeleted', isEqualTo: false);
    if (subjectId != null) {
      query = query.where('subjectId', isEqualTo: subjectId);
    }
    return query
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => ForumPost.fromFirestore(d))
            .toList());
  }

  Future<void> createForumPost(ForumPost post) async {
    await _db.collection('forum').doc(post.id).set({
      'authorId': post.authorId,
      'authorName': post.authorName,
      'authorPhoto': post.authorPhoto,
      'subjectId': post.subjectId,
      'chapterId': post.chapterId,
      'title': post.title,
      'body': post.body,
      'imageUrls': post.imageUrls,
      'tags': post.tags,
      'isResolved': false,
      'upvotes': 0,
      'upvotedBy': [],
      'isDeleted': false,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> replyToPost(
      String postId, String authorId, String authorName, String body) async {
    await _db
        .collection('forum')
        .doc(postId)
        .collection('replies')
        .add({
      'authorId': authorId,
      'authorName': authorName,
      'body': body,
      'isAccepted': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> streamReplies(String postId) {
    return _db
        .collection('forum')
        .doc(postId)
        .collection('replies')
        .orderBy('createdAt')
        .snapshots();
  }

  Future<void> upvotePost(String postId, String userId) async {
    await _db.collection('forum').doc(postId).update({
      'upvotes': FieldValue.increment(1),
      'upvotedBy': FieldValue.arrayUnion([userId]),
    });
  }

  Future<void> markPostResolved(String postId) async {
    await _db.collection('forum').doc(postId).update({'isResolved': true});
  }

  // ==================== DICTIONARY ====================
  Stream<List<DictionaryEntry>> streamDictionary({String? searchQuery}) {
    Query query = _db.collection('dictionary').orderBy('term');
    return query.snapshots().map((snap) =>
        snap.docs.map((d) => DictionaryEntry.fromFirestore(d)).toList());
  }

  // ==================== DYNAMIC CONFIG ====================
  Stream<DocumentSnapshot> streamConfig(String configKey) {
    return _db.collection('dynamicConfig').doc(configKey).snapshots();
  }

  Future<Map<String, dynamic>> getConfig(String configKey) async {
    final doc = await _db.collection('dynamicConfig').doc(configKey).get();
    return doc.data() ?? {};
  }

  Future<void> updateConfig(String configKey, Map<String, dynamic> data) async {
    await _db
        .collection('dynamicConfig')
        .doc(configKey)
        .set(data, SetOptions(merge: true));
  }

  // ==================== NOTICES ====================
  Stream<List<NoticeModel>> streamActiveNotices() {
    return _db
        .collection('dynamicConfig')
        .doc('noticeBoard')
        .snapshots()
        .map((doc) {
      final data = doc.data();
      if (data == null) return [];
      final notices = data['notices'] as List<dynamic>? ?? [];
      final now = DateTime.now();
      return notices
          .map((n) => NoticeModel.fromMap(n['id'] ?? '', n as Map<String, dynamic>))
          .where((n) =>
              n.isActive &&
              (n.expiresAt == null || n.expiresAt!.isAfter(now)))
          .toList();
    });
  }

  // ==================== BADGES ====================
  Stream<List<BadgeModel>> streamBadges() {
    return _db.collection('badges').snapshots().map(
        (snap) => snap.docs.map((d) => BadgeModel.fromFirestore(d)).toList());
  }

  Future<void> awardBadge(String userId, String badgeId) async {
    await _db.collection('users').doc(userId).update({
      'badges': FieldValue.arrayUnion([badgeId]),
    });
  }

  // ==================== ANALYTICS (Admin) ====================
  Future<Map<String, dynamic>> getAnalyticsData() async {
    final usersSnap = await _db.collection('users').count().get();
    final questionsSnap = await _db.collection('questions').count().get();
    final quizzesSnap = await _db.collection('quizzes').count().get();

    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    final activeUsersSnap = await _db
        .collection('users')
        .where('lastActive', isGreaterThan: Timestamp.fromDate(sevenDaysAgo))
        .count()
        .get();

    final premiumUsersSnap = await _db
        .collection('users')
        .where('isPremium', isEqualTo: true)
        .count()
        .get();

    return {
      'totalUsers': usersSnap.count,
      'totalQuestions': questionsSnap.count,
      'totalQuizzes': quizzesSnap.count,
      'activeUsers7Days': activeUsersSnap.count,
      'premiumUsers': premiumUsersSnap.count,
    };
  }

  Future<Map<String, int>> getSubjectPerformance() async {
    final snap = await _db.collection('questions').get();
    final Map<String, int> subjectCount = {};
    for (final doc in snap.docs) {
      final subjectId = doc.data()['subjectId'] ?? '';
      subjectCount[subjectId] = (subjectCount[subjectId] ?? 0) + 1;
    }
    return subjectCount;
  }
}
