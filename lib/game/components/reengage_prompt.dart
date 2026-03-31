import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

class ReengagePrompt extends TextComponent {
  ReengagePrompt()
      : super(
          text: 'RE-ENGAGE FOCUS NODE',
          textRenderer: TextPaint(
            style: TextStyle(
              fontFamily: 'SpaceMono',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const ui.Color(0xFF00F0FF),
            ),
          ),
          anchor: Anchor.center,
        );

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    position = Vector2(size.x / 2, size.y * 0.55);
  }

  void showCountdown(int seconds) {
    text = seconds > 0 ? '$seconds' : 'GO';
  }

  void showPrompt() {
    text = 'RE-ENGAGE FOCUS NODE';
  }
}
