import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SubjectModel {
  final String id;
  final String name;
  final String nameHindi;
  final String icon;
  final String color;
  final int order;
  final int totalChapters;
  final bool isFeatured;
  final String description;
  final String descriptionHindi;

  SubjectModel({
    required this.id,
    required this.name,
    required this.nameHindi,
    this.icon = 'book',
    this.color = '#4CAF50',
    this.order = 0,
    this.totalChapters = 0,
    this.isFeatured = false,
    this.description = '',
    this.descriptionHindi = '',
  });

  factory SubjectModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return SubjectModel(
      id: doc.id,
      name: data['name'] ?? '',
      nameHindi: data['nameHindi'] ?? '',
      icon: data['icon'] ?? 'book',
      color: data['color'] ?? '#4CAF50',
      order: data['order'] ?? 0,
      totalChapters: data['totalChapters'] ?? 0,
      isFeatured: data['isFeatured'] ?? false,
      description: data['description'] ?? '',
      descriptionHindi: data['descriptionHindi'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'nameHindi': nameHindi,
        'icon': icon,
        'color': color,
        'order': order,
        'totalChapters': totalChapters,
        'isFeatured': isFeatured,
        'description': description,
        'descriptionHindi': descriptionHindi,
      };

  Color get themeColor {
    final hex = color.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }
}

class ChapterModel {
  final String id;
  final String subjectId;
  final int chapterNumber;
  final String title;
  final String titleHindi;
  final String description;
  final int totalNotesPages;
  final int totalMcqs;
  final String difficulty;
  final List<String> tags;

  ChapterModel({
    required this.id,
    required this.subjectId,
    required this.chapterNumber,
    required this.title,
    this.titleHindi = '',
    this.description = '',
    this.totalNotesPages = 0,
    this.totalMcqs = 0,
    this.difficulty = 'medium',
    this.tags = const [],
  });

  factory ChapterModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ChapterModel(
      id: doc.id,
      subjectId: data['subjectId'] ?? '',
      chapterNumber: data['chapterNumber'] ?? 0,
      title: data['title'] ?? '',
      titleHindi: data['titleHindi'] ?? '',
      description: data['description'] ?? '',
      totalNotesPages: data['totalNotesPages'] ?? 0,
      totalMcqs: data['totalMcqs'] ?? 0,
      difficulty: data['difficulty'] ?? 'medium',
      tags: List<String>.from(data['tags'] ?? []),
    );
  }

  Map<String, dynamic> toMap() => {
        'subjectId': subjectId,
        'chapterNumber': chapterNumber,
        'title': title,
        'titleHindi': titleHindi,
        'description': description,
        'totalNotesPages': totalNotesPages,
        'totalMcqs': totalMcqs,
        'difficulty': difficulty,
        'tags': tags,
      };

  Color get difficultyColor {
    switch (difficulty) {
      case 'easy':
        return const Color(0xFF4CAF50);
      case 'hard':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFFFF9800);
    }
  }
}

class NoteModel {
  final String id;
  final String chapterId;
  final String subjectId;
  final int pageNumber;
  final String title;
  final String content;
  final String contentHindi;
  final String imageUrl;
  final String audioUrl;
  final List<String> keyPoints;

  NoteModel({
    required this.id,
    required this.chapterId,
    required this.subjectId,
    required this.pageNumber,
    required this.title,
    this.content = '',
    this.contentHindi = '',
    this.imageUrl = '',
    this.audioUrl = '',
    this.keyPoints = const [],
  });

  factory NoteModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return NoteModel(
      id: doc.id,
      chapterId: data['chapterId'] ?? '',
      subjectId: data['subjectId'] ?? '',
      pageNumber: data['pageNumber'] ?? 0,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      contentHindi: data['contentHindi'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      audioUrl: data['audioUrl'] ?? '',
      keyPoints: List<String>.from(data['keyPoints'] ?? []),
    );
  }

  Map<String, dynamic> toMap() => {
        'chapterId': chapterId,
        'subjectId': subjectId,
        'pageNumber': pageNumber,
        'title': title,
        'content': content,
        'contentHindi': contentHindi,
        'imageUrl': imageUrl,
        'audioUrl': audioUrl,
        'keyPoints': keyPoints,
      };
}

class QuestionModel {
  final String id;
  final String subjectId;
  final String chapterId;
  final String type;
  final String questionText;
  final String questionTextHindi;
  final String questionImageUrl;
  final List<OptionModel> options;
  final String correctOption;
  final String explanation;
  final String explanationHindi;
  final String explanationImageUrl;
  final String difficulty;
  final List<String> tags;
  final String source;
  final int? year;
  final int marks;
  final double negativeMarks;

  QuestionModel({
    required this.id,
    required this.subjectId,
    required this.chapterId,
    this.type = 'mcq',
    required this.questionText,
    this.questionTextHindi = '',
    this.questionImageUrl = '',
    required this.options,
    required this.correctOption,
    this.explanation = '',
    this.explanationHindi = '',
    this.explanationImageUrl = '',
    this.difficulty = 'medium',
    this.tags = const [],
    this.source = 'Custom',
    this.year,
    this.marks = 1,
    this.negativeMarks = 0.25,
  });

  factory QuestionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final optionsList = (data['options'] as List<dynamic>? ?? [])
        .map((o) => OptionModel.fromMap(o as Map<String, dynamic>))
        .toList();

    return QuestionModel(
      id: doc.id,
      subjectId: data['subjectId'] ?? '',
      chapterId: data['chapterId'] ?? '',
      type: data['type'] ?? 'mcq',
      questionText: data['questionText'] ?? '',
      questionTextHindi: data['questionTextHindi'] ?? '',
      questionImageUrl: data['questionImageUrl'] ?? '',
      options: optionsList,
      correctOption: data['correctOption'] ?? '',
      explanation: data['explanation'] ?? '',
      explanationHindi: data['explanationHindi'] ?? '',
      explanationImageUrl: data['explanationImageUrl'] ?? '',
      difficulty: data['difficulty'] ?? 'medium',
      tags: List<String>.from(data['tags'] ?? []),
      source: data['source'] ?? 'Custom',
      year: data['year'],
      marks: data['marks'] ?? 1,
      negativeMarks: (data['negativeMarks'] ?? 0.25).toDouble(),
    );
  }

  Map<String, dynamic> toMap() => {
        'subjectId': subjectId,
        'chapterId': chapterId,
        'type': type,
        'questionText': questionText,
        'questionTextHindi': questionTextHindi,
        'questionImageUrl': questionImageUrl,
        'options': options.map((o) => o.toMap()).toList(),
        'correctOption': correctOption,
        'explanation': explanation,
        'explanationHindi': explanationHindi,
        'explanationImageUrl': explanationImageUrl,
        'difficulty': difficulty,
        'tags': tags,
        'source': source,
        'year': year,
        'marks': marks,
        'negativeMarks': negativeMarks,
      };
}

class OptionModel {
  final String id;
  final String text;
  final String imageUrl;

  OptionModel({required this.id, required this.text, this.imageUrl = ''});

  factory OptionModel.fromMap(Map<String, dynamic> map) => OptionModel(
        id: map['id'] ?? '',
        text: map['text'] ?? '',
        imageUrl: map['imageUrl'] ?? '',
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'text': text,
        'imageUrl': imageUrl,
      };
}

class QuizModel {
  final String id;
  final String title;
  final String type;
  final String subjectId;
  final List<String> chapterIds;
  final List<String> questionIds;
  final int totalQuestions;
  final int timeLimit;
  final bool negativeMarking;
  final double negativeMarksPerWrong;
  final bool isLive;
  final DateTime? scheduledDate;
  final DateTime? expiresAt;

  QuizModel({
    required this.id,
    required this.title,
    this.type = 'chapter',
    this.subjectId = '',
    this.chapterIds = const [],
    this.questionIds = const [],
    this.totalQuestions = 10,
    this.timeLimit = 15,
    this.negativeMarking = true,
    this.negativeMarksPerWrong = 0.25,
    this.isLive = false,
    this.scheduledDate,
    this.expiresAt,
  });

  factory QuizModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return QuizModel(
      id: doc.id,
      title: data['title'] ?? '',
      type: data['type'] ?? 'chapter',
      subjectId: data['subjectId'] ?? '',
      chapterIds: List<String>.from(data['chapterIds'] ?? []),
      questionIds: List<String>.from(data['questionIds'] ?? []),
      totalQuestions: data['totalQuestions'] ?? 10,
      timeLimit: data['timeLimit'] ?? 15,
      negativeMarking: data['negativeMarking'] ?? true,
      negativeMarksPerWrong: (data['negativeMarksPerWrong'] ?? 0.25).toDouble(),
      isLive: data['isLive'] ?? false,
      scheduledDate: (data['scheduledDate'] as Timestamp?)?.toDate(),
      expiresAt: (data['expiresAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'type': type,
        'subjectId': subjectId,
        'chapterIds': chapterIds,
        'questionIds': questionIds,
        'totalQuestions': totalQuestions,
        'timeLimit': timeLimit,
        'negativeMarking': negativeMarking,
        'negativeMarksPerWrong': negativeMarksPerWrong,
        'isLive': isLive,
        'scheduledDate':
            scheduledDate != null ? Timestamp.fromDate(scheduledDate!) : null,
        'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
      };
}

class ExamDateModel {
  final String name;
  final DateTime date;
  final List<SubjectExamDate> subjects;

  ExamDateModel({
    required this.name,
    required this.date,
    this.subjects = const [],
  });

  int get daysRemaining => date.difference(DateTime.now()).inDays;
  bool get isUpcoming => date.isAfter(DateTime.now());
}

class SubjectExamDate {
  final String name;
  final DateTime date;

  SubjectExamDate({required this.name, required this.date});
}

class ForumPost {
  final String id;
  final String authorId;
  final String authorName;
  final String authorPhoto;
  final String subjectId;
  final String? chapterId;
  final String title;
  final String body;
  final List<String> imageUrls;
  final List<String> tags;
  final bool isResolved;
  final int upvotes;
  final List<String> upvotedBy;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  ForumPost({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorPhoto = '',
    required this.subjectId,
    this.chapterId,
    required this.title,
    required this.body,
    this.imageUrls = const [],
    this.tags = const ['doubt'],
    this.isResolved = false,
    this.upvotes = 0,
    this.upvotedBy = const [],
    this.isDeleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ForumPost.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ForumPost(
      id: doc.id,
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? '',
      authorPhoto: data['authorPhoto'] ?? '',
      subjectId: data['subjectId'] ?? '',
      chapterId: data['chapterId'],
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      tags: List<String>.from(data['tags'] ?? ['doubt']),
      isResolved: data['isResolved'] ?? false,
      upvotes: data['upvotes'] ?? 0,
      upvotedBy: List<String>.from(data['upvotedBy'] ?? []),
      isDeleted: data['isDeleted'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class DictionaryEntry {
  final String id;
  final String term;
  final String termHindi;
  final String definition;
  final String definitionHindi;
  final String subjectId;
  final String example;
  final List<String> relatedTerms;

  DictionaryEntry({
    required this.id,
    required this.term,
    this.termHindi = '',
    required this.definition,
    this.definitionHindi = '',
    this.subjectId = '',
    this.example = '',
    this.relatedTerms = const [],
  });

  factory DictionaryEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return DictionaryEntry(
      id: doc.id,
      term: data['term'] ?? '',
      termHindi: data['termHindi'] ?? '',
      definition: data['definition'] ?? '',
      definitionHindi: data['definitionHindi'] ?? '',
      subjectId: data['subjectId'] ?? '',
      example: data['example'] ?? '',
      relatedTerms: List<String>.from(data['relatedTerms'] ?? []),
    );
  }
}

class BadgeModel {
  final String id;
  final String name;
  final String nameHindi;
  final String description;
  final String iconUrl;
  final String category;
  final int requiredValue;

  BadgeModel({
    required this.id,
    required this.name,
    this.nameHindi = '',
    required this.description,
    this.iconUrl = '',
    required this.category,
    required this.requiredValue,
  });

  factory BadgeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return BadgeModel(
      id: doc.id,
      name: data['name'] ?? '',
      nameHindi: data['nameHindi'] ?? '',
      description: data['description'] ?? '',
      iconUrl: data['iconUrl'] ?? '',
      category: data['category'] ?? 'quiz',
      requiredValue: data['requiredValue'] ?? 0,
    );
  }
}

class NoticeModel {
  final String id;
  final String title;
  final String body;
  final String type;
  final bool isPopup;
  final bool isActive;
  final DateTime? expiresAt;
  final DateTime createdAt;

  NoticeModel({
    required this.id,
    required this.title,
    required this.body,
    this.type = 'info',
    this.isPopup = false,
    this.isActive = true,
    this.expiresAt,
    required this.createdAt,
  });

  factory NoticeModel.fromMap(String id, Map<String, dynamic> data) {
    return NoticeModel(
      id: id,
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      type: data['type'] ?? 'info',
      isPopup: data['isPopup'] ?? false,
      isActive: data['isActive'] ?? true,
      expiresAt: (data['expiresAt'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
