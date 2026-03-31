import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';

import 'package:dont_tap_rogue_op/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _loadAndNavigate();
  }

  Future<void> _loadAndNavigate() async {
    final stopwatch = Stopwatch()..start();

    try {
      await FlameAudio.audioCache.loadAll([
        'bg.m4a',
        'bait.wav',
        'error.flac',
      ]);
    } catch (_) {
      // Audio files may not exist yet during development.
    }

    stopwatch.stop();
    final elapsed = stopwatch.elapsedMilliseconds;
    const minDelay = 2000;

    if (elapsed < minDelay) {
      await Future<void>.delayed(
        Duration(milliseconds: minDelay - elapsed),
      );
    }

    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/terminal');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.systemVoid,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 200,
              errorBuilder: (_, _, _) => Text(
                "DON'T TAP:\nROGUE OP",
                textAlign: TextAlign.center,
                style: AppTextStyles.screenHeader.copyWith(
                  color: AppColors.containmentCyan,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: AppColors.containmentCyan,
                strokeWidth: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
