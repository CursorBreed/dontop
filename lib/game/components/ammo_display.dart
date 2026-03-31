import 'dart:ui';

import 'package:flame/components.dart';

import 'package:dont_tap_rogue_op/game/protocol_game.dart';

class AmmoDisplay extends PositionComponent
    with HasGameReference<ProtocolGame> {
  AmmoDisplay() : super(anchor: Anchor.topLeft);

  int _charges = 0;
  int _maxCharges = 0;

  static const double _dotRadius = 5.0;
  static const double _dotSpacing = 16.0;
  static const double _padding = 16.0;

  final Paint _activePaint = Paint()
    ..color = const Color(0xFF00F0FF)
    ..style = PaintingStyle.fill;

  final Paint _emptyPaint = Paint()
    ..color = const Color(0xFF00F0FF).withValues(alpha: 0.15)
    ..style = PaintingStyle.fill;

  final Paint _emptyBorderPaint = Paint()
    ..color = const Color(0xFF00F0FF).withValues(alpha: 0.3)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0;

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    position = Vector2(_padding, size.y * 0.75 + 80);
    this.size = Vector2(_maxCharges * _dotSpacing + _padding, _dotRadius * 2 + 8);
  }

  void updateCharges(int charges, int maxCharges) {
    _charges = charges;
    _maxCharges = maxCharges;
  }

  @override
  void render(Canvas canvas) {
    if (_maxCharges <= 0) return;

    final totalWidth = (_maxCharges - 1) * _dotSpacing;
    final startX = (game.size.x - totalWidth) / 2 - position.x;
    const y = _dotRadius + 4;

    for (int i = 0; i < _maxCharges; i++) {
      final cx = startX + i * _dotSpacing;
      if (i < _charges) {
        canvas.drawCircle(Offset(cx, y), _dotRadius, _activePaint);
      } else {
        canvas.drawCircle(Offset(cx, y), _dotRadius, _emptyPaint);
        canvas.drawCircle(Offset(cx, y), _dotRadius, _emptyBorderPaint);
      }
    }
  }
}
