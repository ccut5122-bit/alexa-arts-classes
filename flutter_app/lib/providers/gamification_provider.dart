import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/models.dart';
import '../services/firestore_service.dart';

class GamificationProvider extends ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();

  GamificationData? _gamification;
  List<Map<String, dynamic>> _leaderboard = [];
  List<BadgeModel> _badges = [];
  List<String> _userBadges = [];
  bool _isLoading = false;

  GamificationData? get gamification => _gamification;
  List<Map<String, dynamic>> get leaderboard => _leaderboard;
  List<BadgeModel> get badges => _badges;
  List<String> get userBadges => _userBadges;
  bool get isLoading => _isLoading;

  void loadGamification(UserModel user) {
    _gamification = user.gamification;
    _userBadges = user.badges;
    notifyListeners();
    _checkAndAwardBadges(user);
  }

  void loadLeaderboard({String period = 'allTime'}) {
    _firestore.streamLeaderboard(period: period).listen((entries) {
      _leaderboard = entries;
      notifyListeners();
    }, onError: (e) {
      notifyListeners();
    });
  }

  void loadBadges() {
    _firestore.streamBadges().listen((badges) {
      _badges = badges;
      notifyListeners();
    }, onError: (e) {
      notifyListeners();
    });
  }

  void updateStreak(UserModel user) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final gam = user.gamification;
    final lastDate = gam.lastStudyDate;

    if (lastDate == null) {
      _gamification = GamificationData(
        coins: gam.coins,
        currentStreak: 1,
        longestStreak: 1,
        lastStudyDate: today,
        totalQuizzesAttempted: gam.totalQuizzesAttempted,
        totalCorrectAnswers: gam.totalCorrectAnswers,
        level: gam.level,
      );
    } else {
      final lastDay = DateTime(lastDate.year, lastDate.month, lastDate.day);
      final diff = today.difference(lastDay).inDays;

      if (diff == 0) {
        return;
      } else if (diff == 1) {
        final newStreak = gam.currentStreak + 1;
        final newLongest = newStreak > gam.longestStreak
            ? newStreak
            : gam.longestStreak;
        _gamification = GamificationData(
          coins: gam.coins,
          currentStreak: newStreak,
          longestStreak: newLongest,
          lastStudyDate: today,
          totalQuizzesAttempted: gam.totalQuizzesAttempted,
          totalCorrectAnswers: gam.totalCorrectAnswers,
          level: gam.level,
        );
      } else {
        _gamification = GamificationData(
          coins: gam.coins,
          currentStreak: 1,
          longestStreak: gam.longestStreak,
          lastStudyDate: today,
          totalQuizzesAttempted: gam.totalQuizzesAttempted,
          totalCorrectAnswers: gam.totalCorrectAnswers,
          level: gam.level,
        );
      }
    }

    _firestore.updateStreak(user.uid, _gamification!);
    notifyListeners();
  }

  Future<void> earnCoins(String uid, int amount, String reason) async {
    await _firestore.addCoins(uid, amount);
    _gamification = GamificationData(
      coins: (_gamification?.coins ?? 0) + amount,
      currentStreak: _gamification?.currentStreak ?? 0,
      longestStreak: _gamification?.longestStreak ?? 0,
      lastStudyDate: _gamification?.lastStudyDate,
      totalQuizzesAttempted: _gamification?.totalQuizzesAttempted ?? 0,
      totalCorrectAnswers: _gamification?.totalCorrectAnswers ?? 0,
      level: _gamification?.level ?? 1,
    );
    notifyListeners();
  }

  void _checkAndAwardBadges(UserModel user) {
    for (final badge in _badges) {
      if (_userBadges.contains(badge.id)) continue;

      bool earned = false;
      switch (badge.category) {
        case 'streak':
          earned = (user.gamification.currentStreak >= badge.requiredValue) ||
              (user.gamification.longestStreak >= badge.requiredValue);
          break;
        case 'quiz':
          earned =
              user.gamification.totalQuizzesAttempted >= badge.requiredValue;
          break;
        default:
          break;
      }

      if (earned) {
        _firestore.awardBadge(user.uid, badge.id);
      }
    }
  }

  int getRankInLeaderboard(String userId) {
    final index = _leaderboard.indexWhere((e) => e['id'] == userId);
    return index >= 0 ? index + 1 : -1;
  }

  Future<void> saveLeaderboardEntry(UserModel user, int score) async {
    final coins = _gamification?.coins ?? user.gamification.coins;
    final data = {
      'displayName': user.displayName,
      'photoUrl': user.photoUrl,
      'coins': coins,
      'level': _gamification?.level ?? user.gamification.level,
      'score': score,
    };
    await _firestore.updateLeaderboard(user.uid, data);
  }
}
