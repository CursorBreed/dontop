import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

import 'package:dont_tap_rogue_op/game/protocol_game.dart';

class LevelBadge extends TextComponent
    with HasGameReference<ProtocolGame> {
  LevelBadge()
      : super(
          text: 'SEQ 01',
          textRenderer: TextPaint(
            style: const TextStyle(
              fontFamily: 'SpaceMono',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: ui.Color(0xFF888888),
              letterSpacing: 3,
            ),
          ),
          anchor: Anchor.topLeft,
        );

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    position = Vector2(16, 20);
  }

  void updateLevel(int level) {
    text = 'SEQ ${level.toString().padLeft(2, '0')}';
  }
}
