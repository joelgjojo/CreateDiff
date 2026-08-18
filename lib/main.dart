import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'services/app_state.dart';
import 'services/session_token_store.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Global Flutter Error Boundary (Prevents Red Screen Crashes)
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('[CreateDiff Global Error] ${details.exceptionAsString()}');
  };

  // Async Platform Error Handler
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    debugPrint('[CreateDiff Platform Error] $error\n$stack');
    return true; // Handled
  };

  // Custom UI Error Boundary Widget
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      color: const Color(0xFF080A0F),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF131722),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF4F43F9).withValues(alpha: 0.4), width: 1.2),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.auto_awesome_motion_rounded, size: 36, color: Color(0xFF7066FF)),
                  const SizedBox(height: 12),
                  const Text(
                    'Something unexpected occurred',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'CreateDiff recovered safely. Please navigate back or retry your action.',
                    style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.7)),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  };

  // Initialize persistent App State (SharedPreferences)
  await SessionTokenStore.init();
  await AppState.instance.init();

  runApp(const CreateDiffApp());
}

class CreateDiffApp extends StatelessWidget {
  const CreateDiffApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppState.instance;

    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final platformBrightness = View.of(context).platformDispatcher.platformBrightness;
        final isDark = appState.themeMode == ThemeMode.dark ||
            (appState.themeMode == ThemeMode.system && platformBrightness == Brightness.dark);

        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
            statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          ),
        );

        return MaterialApp(
          title: 'CreateDiff',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: appState.themeMode,
          home: const SplashScreen(),
        );
      },
    );
  }
}
