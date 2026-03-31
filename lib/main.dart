import 'package:flutter/material.dart';

import 'package:dont_tap_rogue_op/screens/gameplay_screen.dart';
import 'package:dont_tap_rogue_op/screens/how_to_play_screen.dart';
import 'package:dont_tap_rogue_op/screens/privacy_screen.dart';
import 'package:dont_tap_rogue_op/screens/score_screen.dart';
import 'package:dont_tap_rogue_op/screens/settings_screen.dart';
import 'package:dont_tap_rogue_op/screens/splash_screen.dart';
import 'package:dont_tap_rogue_op/screens/terminal_screen.dart';
import 'package:dont_tap_rogue_op/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DontTapRogueOpApp());
}

class DontTapRogueOpApp extends StatelessWidget {
  const DontTapRogueOpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Don't Tap: Rogue Op",
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      initialRoute: '/',
      routes: {
        '/': (_) => const SplashScreen(),
        '/terminal': (_) => const TerminalScreen(),
        '/gameplay': (_) => const GameplayScreen(),
        '/how-to-play': (_) => const HowToPlayScreen(),
        '/settings': (_) => const SettingsScreen(),
        '/score': (_) => const ScoreScreen(),
        '/privacy': (_) => const PrivacyScreen(),
      },
    );
  }
}
