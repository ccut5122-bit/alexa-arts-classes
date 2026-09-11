import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String photoUrl;
  final String phone;
  final String role;
  final String className;
  final String stream;
  final String district;
  final String school;
  final bool isPremium;
  final bool isBanned;
  final bool onboarded;
  final DateTime? subscriptionExpiry;
  final DateTime createdAt;
  final DateTime lastActive;
  final GamificationData gamification;
  final List<String> badges;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl = '',
    this.phone = '',
    this.role = 'student',
    this.className = '11',
    this.stream = 'arts',
    this.district = '',
    this.school = '',
    this.isPremium = false,
    this.isBanned = false,
    this.onboarded = false,
    this.subscriptionExpiry,
    required this.createdAt,
    required this.lastActive,
    required this.gamification,
    this.badges = const [],
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final gamData = data['gamification'] as Map<String, dynamic>? ?? {};

    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      phone: data['phone'] ?? '',
      role: data['role'] ?? 'student',
      className: data['className'] ?? '11',
      stream: data['stream'] ?? 'arts',
      district: data['district'] ?? '',
      school: data['school'] ?? '',
      isPremium: data['isPremium'] ?? false,
      isBanned: data['isBanned'] ?? false,
      onboarded: data['onboarded'] ?? false,
      subscriptionExpiry: (data['subscriptionExpiry'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastActive: (data['lastActive'] as Timestamp?)?.toDate() ?? DateTime.now(),
      gamification: GamificationData.fromMap(gamData),
      badges: List<String>.from(data['badges'] ?? []),
    );
  }

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'email': email,
        'displayName': displayName,
        'photoUrl': photoUrl,
        'phone': phone,
        'role': role,
        'className': className,
        'stream': stream,
        'district': district,
        'school': school,
        'isPremium': isPremium,
        'isBanned': isBanned,
        'onboarded': onboarded,
        'subscriptionExpiry':
            subscriptionExpiry != null ? Timestamp.fromDate(subscriptionExpiry!) : null,
        'createdAt': Timestamp.fromDate(createdAt),
        'lastActive': Timestamp.fromDate(lastActive),
        'badges': badges,
      };

  bool get isSubscribed =>
      isPremium && subscriptionExpiry != null && subscriptionExpiry!.isAfter(DateTime.now());
}

class GamificationData {
  final int coins;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastStudyDate;
  final int totalQuizzesAttempted;
  final int totalCorrectAnswers;
  final int level;

  GamificationData({
    this.coins = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastStudyDate,
    this.totalQuizzesAttempted = 0,
    this.totalCorrectAnswers = 0,
    this.level = 1,
  });

  factory GamificationData.fromMap(Map<String, dynamic> map) {
    final streak = map['streak'] as Map<String, dynamic>? ?? {};
    return GamificationData(
      coins: map['coins'] ?? 0,
      currentStreak: streak['currentDays'] ?? 0,
      longestStreak: streak['longestStreak'] ?? 0,
      lastStudyDate: streak['lastStudyDate'] != null
          ? DateTime.tryParse(streak['lastStudyDate'])
          : null,
      totalQuizzesAttempted: map['totalQuizzesAttempted'] ?? 0,
      totalCorrectAnswers: map['totalCorrectAnswers'] ?? 0,
      level: map['level'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() => {
        'coins': coins,
        'streak': {
          'currentDays': currentStreak,
          'longestStreak': longestStreak,
          'lastStudyDate': lastStudyDate != null
              ? '${lastStudyDate!.year}-${lastStudyDate!.month.toString().padLeft(2, '0')}-${lastStudyDate!.day.toString().padLeft(2, '0')}'
              : null,
        },
        'totalQuizzesAttempted': totalQuizzesAttempted,
        'totalCorrectAnswers': totalCorrectAnswers,
        'level': level,
      };

  int get accuracyPercent =>
      totalQuizzesAttempted > 0 ? ((totalCorrectAnswers / (totalQuizzesAttempted * 10)) * 100).round() : 0;

  int get nextLevelThreshold => level * 500;
}
