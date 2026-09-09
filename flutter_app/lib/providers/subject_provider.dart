import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/firestore_service.dart';

class SubjectProvider extends ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();

  List<SubjectModel> _subjects = [];
  List<ChapterModel> _chapters = [];
  List<NoteModel> _notes = [];
  bool _isLoading = false;
  String? _selectedSubjectId;

  List<SubjectModel> get subjects => _subjects;
  List<ChapterModel> get chapters => _chapters;
  List<NoteModel> get notes => _notes;
  bool get isLoading => _isLoading;
  String? get selectedSubjectId => _selectedSubjectId;

  void loadSubjects() {
    _firestore.streamSubjects().listen((subjects) {
      _subjects = subjects;
      notifyListeners();
    }, onError: (e) {
      _isLoading = false;
      notifyListeners();
    });
  }

  void loadChapters(String subjectId) {
    _selectedSubjectId = subjectId;
    _isLoading = true;
    notifyListeners();

    _firestore.streamChapters(subjectId).listen((chapters) {
      _chapters = chapters;
      _isLoading = false;
      notifyListeners();
    }, onError: (e) {
      _isLoading = false;
      notifyListeners();
    });
  }

  void loadNotes(String chapterId) {
    _isLoading = true;
    notifyListeners();

    _firestore.streamNotes(chapterId).listen((notes) {
      _notes = notes;
      _isLoading = false;
      notifyListeners();
    }, onError: (e) {
      _isLoading = false;
      notifyListeners();
    });
  }

  List<SubjectModel> get featuredSubjects =>
      _subjects.where((s) => s.isFeatured).toList();

  SubjectModel? getSubjectById(String id) {
    try {
      return _subjects.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }
}
