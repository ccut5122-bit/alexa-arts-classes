import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'providers/auth_provider.dart';
import 'providers/subject_provider.dart';
import 'providers/quiz_provider.dart';
import 'providers/gamification_provider.dart';
import 'providers/config_provider.dart';
import 'providers/forum_provider.dart';
import 'services/notification_service.dart';
import 'services/install_tracker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.initialize();
  await InstallTracker.trackOnLaunch();
  runApp(const AlexaArtsApp());
}

class AlexaArtsApp extends StatelessWidget {
  const AlexaArtsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..init()),
        ChangeNotifierProvider(create: (_) => ConfigProvider()..init()),
        ChangeNotifierProvider(create: (_) => SubjectProvider()),
        ChangeNotifierProvider(create: (_) => QuizProvider()),
        ChangeNotifierProvider(create: (_) => GamificationProvider()),
        ChangeNotifierProvider(create: (_) => ForumProvider()),
      ],
      child: Consumer<ConfigProvider>(
        builder: (context, config, _) {
          return MaterialApp(
            title: 'Alexa Arts Classes',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme(config.primaryColor),
            darkTheme: AppTheme.darkTheme(config.primaryColor),
            themeMode: config.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            onGenerateRoute: AppRouter.generateRoute,
            initialRoute: '/splash',
          );
        },
      ),
    );
  }
}
