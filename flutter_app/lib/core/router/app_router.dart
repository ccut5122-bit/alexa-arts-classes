import 'package:flutter/material.dart';
import '../screens/home/home_screen.dart';
import '../screens/chapters/chapter_list_screen.dart';
import '../screens/notes/notes_viewer_screen.dart';
import '../screens/quiz/quiz_screen.dart';
import '../screens/gamification/leaderboard_screen.dart';
import '../screens/gamification/badges_screen.dart';
import '../screens/forum/forum_screen.dart';
import '../screens/dictionary/dictionary_screen.dart';
import '../screens/exam_prep/exam_prep_screen.dart';
import '../screens/bookmarks/bookmarks_screen.dart';
import '../screens/home/splash_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/splash':
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case '/chapters':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ChapterListScreen(
            subjectId: args['subjectId'],
            subjectName: args['subjectName'],
          ),
        );
      case '/notes':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => NotesViewerScreen(
            chapterId: args['chapterId'],
            chapterTitle: args['chapterTitle'],
            subjectId: args['subjectId'],
          ),
        );
      case '/quiz':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => QuizScreen(
            subjectId: args['subjectId'],
            chapterIds: args['chapterIds'],
            quizTitle: args['quizTitle'],
            timeLimit: args['timeLimit'] ?? 15,
            negativeMarking: args['negativeMarking'] ?? true,
          ),
        );
      case '/leaderboard':
        return MaterialPageRoute(builder: (_) => const LeaderboardScreen());
      case '/badges':
        return MaterialPageRoute(builder: (_) => const BadgesScreen());
      case '/forum':
        return MaterialPageRoute(builder: (_) => const ForumScreen());
      case '/dictionary':
        return MaterialPageRoute(builder: (_) => const DictionaryScreen());
      case '/exam-prep':
        return MaterialPageRoute(builder: (_) => const ExamPrepScreen());
      case '/bookmarks':
        return MaterialPageRoute(builder: (_) => const BookmarksScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
