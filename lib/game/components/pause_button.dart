import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';

import 'package:dont_tap_rogue_op/game/protocol_game.dart';

class PauseButton extends PositionComponent
    with TapCallbacks, HasGameReference<ProtocolGame> {
  PauseButton() : super(size: Vector2.all(48), anchor: Anchor.topRight);

  static const double _barWidth = 6;
  static const double _barHeight = 22;
  static const double _barGap = 8;

  final Paint _paint = Paint()
    ..color = const Color(0xFF888888) // Dimmed Text
    ..style = PaintingStyle.fill;

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    position = Vector2(size.x - 16, 16);
  }

  @override
  void onTapUp(TapUpEvent event) {
    game.onPauseTapped();
  }

  @override
  void render(Canvas canvas) {
    final centerX = size.x / 2;
    final centerY = size.y / 2;

    // Left bar
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(centerX - _barGap / 2 - _barWidth / 2, centerY),
        width: _barWidth,
        height: _barHeight,
      ),
      _paint,
    );

    // Right bar
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(centerX + _barGap / 2 + _barWidth / 2, centerY),
        width: _barWidth,
        height: _barHeight,
      ),
      _paint,
    );
  }
}
