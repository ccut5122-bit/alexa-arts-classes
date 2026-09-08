import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/models.dart';

class OfflineStorageService {
  static const _secureStorage = FlutterSecureStorage();
  static const _key = 'alexa_offline_key';

  Box? _notesBox;
  Box? _bookmarksBox;
  Box? _mcqBox;

  Future<void> init() async {
    await Hive.initFlutter();
    _notesBox = await Hive.openBox('cached_notes');
    _bookmarksBox = await Hive.openBox('bookmarks');
    _mcqBox = await Hive.openBox('cached_mcqs');
  }

  Future<String> _getKey() async {
    var keyValue = await _secureStorage.read(key: _key);
    if (keyValue == null) {
      keyValue = encrypt.Key.fromSecureRandom(32).base64;
      await _secureStorage.write(key: _key, value: keyValue);
    }
    return keyValue;
  }

  encrypt.Encrypter _getEncrypter(String keyValue) {
    final key = encrypt.Key.fromBase64(keyValue);
    final iv = encrypt.IV.fromLength(16);
    return encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
  }

  /// Encrypts and caches notes for offline access
  Future<void> cacheNoteEncrypted({
    required String userId,
    required NoteModel note,
  }) async {
    final keyValue = await _getKey();
    final encrypter = _getEncrypter(keyValue);

    final noteJson = jsonEncode(note.toMap());
    final encrypted = encrypter.encrypt(noteJson, iv: encrypt.IV.fromUtf8(userId.padRight(16).substring(0, 16)));

    await _notesBox!.put(
      '${userId}_${note.chapterId}_${note.id}',
      {
        'data': encrypted.base64,
        'cachedAt': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Retrieves decrypted cached notes
  Future<List<NoteModel>> getCachedNotes(String chapterId) async {
    final userId = await _secureStorage.read(key: 'last_user_id') ?? '';
    if (userId.isEmpty) return [];

    final keyValue = await _getKey();
    final encrypter = _getEncrypter(keyValue);

    final notes = <NoteModel>[];
    final entries = _notesBox!.values.where(
      (e) => e.containsKey('data'),
    );

    for (final entry in entries) {
      try {
        final decrypted = encrypter.decrypt(
          encrypt.Encrypted.fromBase64(entry['data'] as String),
          iv: encrypt.IV.fromUtf8(userId.padRight(16).substring(0, 16)),
        );
        final data = jsonDecode(decrypted) as Map<String, dynamic>;
        final note = NoteModel(
          id: data['id'] ?? '',
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
        if (note.chapterId == chapterId) {
          notes.add(note);
        }
      } catch (e) {
        // Corrupted entry, skip
      }
    }

    notes.sort((a, b) => a.pageNumber.compareTo(b.pageNumber));
    return notes;
  }

  /// Caches quiz questions for offline MCQ practice
  Future<void> cacheMCQs({
    required String userId,
    required List<QuestionModel> questions,
  }) async {
    final keyValue = await _getKey();
    final encrypter = _getEncrypter(keyValue);

    for (final q in questions) {
      final qJson = jsonEncode(q.toMap());
      final encrypted = encrypter.encrypt(
        qJson,
        iv: encrypt.IV.fromUtf8(userId.padRight(16).substring(0, 16)),
      );
      await _mcqBox!.put('${userId}_${q.subjectId}_${q.id}', {
        'data': encrypted.base64,
      });
    }
  }

  Future<List<QuestionModel>> getCachedMCQs(
      String userId, String subjectId) async {
    final keyValue = await _getKey();
    final encrypter = _getEncrypter(keyValue);
    final questions = <QuestionModel>[];

    final prefix = '${userId}_${subjectId}_';
    final keys = _mcqBox!.keys.where((k) => (k as String).startsWith(prefix));

    for (final key in keys) {
      try {
        final entry = _mcqBox!.get(key) as Map<String, dynamic>;
        final decrypted = encrypter.decrypt(
          encrypt.Encrypted.fromBase64(entry['data'] as String),
          iv: encrypt.IV.fromUtf8(userId.padRight(16).substring(0, 16)),
        );
        final data = jsonDecode(decrypted) as Map<String, dynamic>;
        questions.add(_questionFromMap(data));
      } catch (e) {
        // Skip corrupted
      }
    }

    questions.shuffle();
    return questions;
  }

  QuestionModel _questionFromMap(Map<String, dynamic> data) {
    final optionsList = (data['options'] as List<dynamic>? ?? [])
        .map((o) => OptionModel.fromMap(o as Map<String, dynamic>))
        .toList();
    return QuestionModel(
      id: data['id'] ?? '',
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

  /// Saves bookmarks locally
  Future<void> saveBookmark({
    required String userId,
    required String type,
    required String contentId,
    required String chapterId,
    required String subjectId,
  }) async {
    final bookmarkId = '${userId}_$contentId';
    await _bookmarksBox!.put(bookmarkId, {
      'type': type,
      'contentId': contentId,
      'chapterId': chapterId,
      'subjectId': subjectId,
      'userId': userId,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getBookmarks(String userId) async {
    final bookmarks = <Map<String, dynamic>>[];
    final entries = _bookmarksBox!.values;

    for (final entry in entries) {
      final data = entry as Map<String, dynamic>;
      if (data['userId'] == userId) {
        bookmarks.add(data);
      }
    }

    bookmarks.sort((a, b) =>
        (b['createdAt'] as String).compareTo(a['createdAt'] as String));
    return bookmarks;
  }

  Future<void> removeBookmark(String contentId) async {
    final userId = await _secureStorage.read(key: 'last_user_id') ?? '';
    await _bookmarksBox!.delete('${userId}_$contentId');
  }

  /// Downloads PDF to local storage
  Future<File> savePDF(Uint8List bytes, String fileName) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes);
    return file;
  }

  /// Clears all local cache for a user
  Future<void> clearUserCache(String userId) async {
    final notesKeys = _notesBox!.keys
        .where((k) => (k as String).startsWith(userId))
        .toList();
    for (final key in notesKeys) {
      await _notesBox!.delete(key);
    }
  }
}
