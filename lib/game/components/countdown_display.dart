import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

import 'package:dont_tap_rogue_op/game/protocol_game.dart';

class CountdownDisplay extends TextComponent
    with HasGameReference<ProtocolGame> {
  CountdownDisplay()
      : super(
          text: '00.0',
          textRenderer: TextPaint(
            style: TextStyle(
              fontFamily: 'SpaceMono',
              fontSize: 64,
              fontWeight: FontWeight.w700,
              color: const ui.Color(0xFF00F0FF),
              fontFeatures: const [ui.FontFeature.tabularFigures()],
            ),
          ),
          anchor: Anchor.topCenter,
        );

  String _realText = '00.0';

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    position = Vector2(size.x / 2, 64);
  }

  void updateTime(double secondsRemaining) {
    final clamped = secondsRemaining.clamp(0.0, 999.0);
    final whole = clamped.floor();
    final decimal = ((clamped - whole) * 10).floor();
    _realText = '${whole.toString().padLeft(2, '0')}.$decimal';
    text = _realText;
  }

  @override
  void update(double dt) {
    super.update(dt);

    final glitch = game.countdownGlitchModifier;
    if (glitch != null) {
      final glitchText = glitch.activeGlitchText;
      if (glitchText != null) {
        text = glitchText;
        return;
      }
    }
    text = _realText;
  }
}
