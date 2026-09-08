import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class ConfigProvider extends ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();

  Color _primaryColor = const Color(0xFF6C63FF);
  Color _secondaryColor = const Color(0xFF00C9A7);
  Color _accentColor = const Color(0xFFFF6B35);
  bool _isDarkMode = false;
  String _appName = 'Alexa Arts Classes';
  String _logoUrl = '';
  List<Map<String, dynamic>> _banners = [];
  List<Map<String, dynamic>> _notices = [];
  List<Map<String, dynamic>> _examDates = [];
  List<String> _featuredSubjectIds = [];
  Map<String, dynamic> _coinsConfig = {};

  Color get primaryColor => _primaryColor;
  Color get secondaryColor => _secondaryColor;
  Color get accentColor => _accentColor;
  bool get isDarkMode => _isDarkMode;
  String get appName => _appName;
  String get logoUrl => _logoUrl;
  List<Map<String, dynamic>> get banners => _banners;
  List<Map<String, dynamic>> get notices => _notices;
  List<Map<String, dynamic>> get examDates => _examDates;
  List<String> get featuredSubjectIds => _featuredSubjectIds;
  Map<String, dynamic> get coinsConfig => _coinsConfig;

  void init() {
    _listenToThemeConfig();
    _listenToBanners();
    _listenToNotices();
    _listenToExamDates();
    _listenToFeaturedSubjects();
    _listenToCoinsConfig();
  }

  void _listenToThemeConfig() {
    _firestore.streamConfig('themeConfig').listen((doc) {
      final data = doc.data() as Map<String, dynamic>?;
      if (data != null) {
        if (data['primaryColor'] != null) {
          final hex = (data['primaryColor'] as String).replaceFirst('#', '');
          _primaryColor = Color(int.parse('FF$hex', radix: 16));
        }
        if (data['secondaryColor'] != null) {
          final hex = (data['secondaryColor'] as String).replaceFirst('#', '');
          _secondaryColor = Color(int.parse('FF$hex', radix: 16));
        }
        if (data['accentColor'] != null) {
          final hex = (data['accentColor'] as String).replaceFirst('#', '');
          _accentColor = Color(int.parse('FF$hex', radix: 16));
        }
        _isDarkMode = data['darkMode'] ?? false;
        _appName = data['appName'] ?? 'Alexa Arts Classes';
        _logoUrl = data['logoUrl'] ?? '';
        notifyListeners();
      }
    });
  }

  void _listenToBanners() {
    _firestore.streamConfig('bannerConfig').listen((doc) {
      final data = doc.data() as Map<String, dynamic>?;
      if (data != null) {
        _banners = List<Map<String, dynamic>>.from(data['banners'] ?? [])
            .where((b) => b['isActive'] == true)
            .toList()
          ..sort((a, b) => (a['order'] ?? 0).compareTo(b['order'] ?? 0));
        notifyListeners();
      }
    });
  }

  void _listenToNotices() {
    _firestore.streamActiveNotices().listen((notices) {
      _notices = notices
          .map((n) => {
                'id': n.id,
                'title': n.title,
                'body': n.body,
                'type': n.type,
                'isPopup': n.isPopup,
              })
          .toList();
      notifyListeners();
    });
  }

  void _listenToExamDates() {
    _firestore.streamConfig('examDates').listen((doc) {
      final data = doc.data() as Map<String, dynamic>?;
      if (data != null) {
        _examDates = List<Map<String, dynamic>>.from(data['exams'] ?? []);
        notifyListeners();
      }
    });
  }

  void _listenToFeaturedSubjects() {
    _firestore.streamConfig('featuredSubjects').listen((doc) {
      final data = doc.data() as Map<String, dynamic>?;
      if (data != null) {
        _featuredSubjectIds =
            List<String>.from(data['subjectIds'] ?? []);
        notifyListeners();
      }
    });
  }

  void _listenToCoinsConfig() {
    _firestore.streamConfig('coinsConfig').listen((doc) {
      final data = doc.data() as Map<String, dynamic>?;
      if (data != null) {
        _coinsConfig = Map<String, dynamic>.from(data);
        notifyListeners();
      }
    });
  }

  int get coinForQuizAttempt => _coinsConfig['quizAttemptCoins'] ?? 10;
  int get coinForCorrectAnswer => _coinsConfig['correctAnswerCoins'] ?? 5;
  int get coinForStreakBonus => _coinsConfig['streakBonusCoins'] ?? 20;
  int get coinForNoteRead => _coinsConfig['noteReadCoins'] ?? 3;
  int get coinForMonthlyPrize => _coinsConfig['monthlyQuizPrizeCoins'] ?? 500;
  int get coinForSpecialTest => _coinsConfig['specialTestUnlockCoins'] ?? 100;
}
