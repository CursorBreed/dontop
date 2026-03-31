import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

import 'package:dont_tap_rogue_op/game/components/anomaly_base.dart';

enum _ShapeType { rectangle, circle }

class StaticNoiseAnomaly extends AnomalyBase {
  StaticNoiseAnomaly({
    required Vector2 startPosition,
    required this.velocity,
  }) {
    position = startPosition;
    final rng = Random();
    final w = 30.0 + rng.nextDouble() * 40;
    final h = 30.0 + rng.nextDouble() * 40;
    size = Vector2(w, h);
    _shapeType = _ShapeType.values[rng.nextInt(_ShapeType.values.length)];
    _color = _mutedColors[rng.nextInt(_mutedColors.length)];
  }

  final Vector2 velocity;
  late final _ShapeType _shapeType;
  late final Color _color;

  @override
  Vector2 get anomalyVelocity => velocity;

  static const List<Color> _mutedColors = [
    Color(0xFF333333),
    Color(0xFF444444),
    Color(0xFF2A2A2A),
    Color(0xFF3A3A3A),
    Color(0xFF1E1E2E),
  ];

  late final Paint _paint = Paint()
    ..color = _color
    ..style = PaintingStyle.fill;

  late final Paint _borderPaint = Paint()
    ..color = _color.withValues(alpha: 0.7)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5;

  @override
  void update(double dt) {
    position += velocity * dt;
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    switch (_shapeType) {
      case _ShapeType.rectangle:
        final rect = size.toRect();
        canvas.drawRect(rect, _paint);
        canvas.drawRect(rect, _borderPaint);
      case _ShapeType.circle:
        final radius = size.x / 2;
        final center = Offset(radius, size.y / 2);
        canvas.drawCircle(center, radius, _paint);
        canvas.drawCircle(center, radius, _borderPaint);
    }
  }
}
