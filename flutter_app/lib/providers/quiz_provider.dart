import 'dart:async';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/firestore_service.dart';

class QuizProvider extends ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();

  List<QuestionModel> _questions = [];
  int _currentIndex = 0;
  String? _selectedAnswer;
  bool _answered = false;
  int _score = 0;
  int _correctCount = 0;
  List<String> _wrongQuestionIds = [];
  Timer? _timer;
  int _timeRemaining = 0;
  bool _isQuizActive = false;
  List<QuizModel> _availableQuizzes = [];

  List<QuestionModel> get questions => _questions;
  int get currentIndex => _currentIndex;
  String? get selectedAnswer => _selectedAnswer;
  bool get answered => _answered;
  int get score => _score;
  int get correctCount => _correctCount;
  List<String> get wrongQuestionIds => _wrongQuestionIds;
  int get timeRemaining => _timeRemaining;
  bool get isQuizActive => _isQuizActive;
  List<QuizModel> get availableQuizzes => _availableQuizzes;
  bool get isLastQuestion => _currentIndex >= _questions.length - 1;
  double get progress =>
      _questions.isEmpty ? 0 : (_currentIndex + 1) / _questions.length;
  QuestionModel? get currentQuestion =>
      _questions.isNotEmpty ? _questions[_currentIndex] : null;

  void loadAvailableQuizzes({String? type}) {
    _firestore.streamQuizzes(type: type).listen((quizzes) {
      _availableQuizzes = quizzes;
      notifyListeners();
    });
  }

  Future<void> startQuiz({
    required String subjectId,
    List<String>? chapterIds,
    int limit = 10,
    int timeMinutes = 15,
    bool negativeMarking = true,
  }) async {
    _questions = await _firestore.getQuestionsForQuiz(
      subjectId: subjectId,
      chapterIds: chapterIds,
      limit: limit,
    );

    _currentIndex = 0;
    _selectedAnswer = null;
    _answered = false;
    _score = 0;
    _correctCount = 0;
    _wrongQuestionIds = [];
    _timeRemaining = timeMinutes * 60;
    _isQuizActive = true;

    _startTimer();
    notifyListeners();
  }

  Future<void> startRevisionQuiz(String userId) async {
    _questions = await _firestore.getWrongQuestionsForRevision(userId);

    if (_questions.isEmpty) {
      _isQuizActive = false;
      notifyListeners();
      return;
    }

    _currentIndex = 0;
    _selectedAnswer = null;
    _answered = false;
    _score = 0;
    _correctCount = 0;
    _wrongQuestionIds = [];
    _timeRemaining = _questions.length * 60;
    _isQuizActive = true;

    _startTimer();
    notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemaining > 0) {
        _timeRemaining--;
        notifyListeners();
      } else {
        finishQuiz();
      }
    });
  }

  void selectAnswer(String answer) {
    if (_answered) return;
    _selectedAnswer = answer;
    notifyListeners();
  }

  void confirmAnswer({bool negativeMarking = true}) {
    if (_selectedAnswer == null || _answered) return;

    _answered = true;
    final correct = currentQuestion!.correctOption;

    if (_selectedAnswer == correct) {
      _score += currentQuestion!.marks;
      _correctCount++;
    } else if (negativeMarking) {
      _score = (_score - currentQuestion!.negativeMarks).round();
      _wrongQuestionIds.add(currentQuestion!.id);
    } else {
      _wrongQuestionIds.add(currentQuestion!.id);
    }

    notifyListeners();
  }

  void nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      _currentIndex++;
      _selectedAnswer = null;
      _answered = false;
      notifyListeners();
    }
  }

  void previousQuestion() {
    if (_currentIndex > 0) {
      _currentIndex--;
      _selectedAnswer = null;
      _answered = false;
      notifyListeners();
    }
  }

  void goToQuestion(int index) {
    if (index >= 0 && index < _questions.length) {
      _currentIndex = index;
      _selectedAnswer = null;
      _answered = false;
      notifyListeners();
    }
  }

  Map<String, dynamic> finishQuiz() {
    _timer?.cancel();
    _isQuizActive = false;

    final result = {
      'score': _score,
      'totalQuestions': _questions.length,
      'correctAnswers': _correctCount,
      'wrongQuestions': _wrongQuestionIds,
      'timeTaken': (_questions.length * 60) - _timeRemaining,
      'completedAt': DateTime.now().toIso8601String(),
    };

    notifyListeners();
    return result;
  }

  Future<void> saveQuizResult(
      String userId, String quizId, Map<String, dynamic> result) async {
    await _firestore.submitQuizResult(userId, quizId, result);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
