import 'dart:ui';

import 'package:flame/components.dart';

import 'package:dont_tap_rogue_op/game/components/anomaly_base.dart';

/// Rank 5 modifier: a decoy that mimics the Focus Node's appearance.
class MimicNodeAnomaly extends AnomalyBase {
  MimicNodeAnomaly({
    required Vector2 startPosition,
    required this.velocity,
  }) : super() {
    position = startPosition;
    size = Vector2.all(100);
    anchor = Anchor.center;
  }

  final Vector2 velocity;

  @override
  Vector2 get anomalyVelocity => velocity;

  static const double _borderWidth = 3.0;

  final Paint _borderPaint = Paint()
    ..color = const Color(0xFF00F0FF)
    ..style = PaintingStyle.stroke
    ..strokeWidth = _borderWidth;

  final Paint _innerGlow = Paint()
    ..color = const Color(0xFF00F0FF).withValues(alpha: 0.08)
    ..style = PaintingStyle.fill;

  double _pulseTimer = 0;

  @override
  void update(double dt) {
    position += velocity * dt;
    _pulseTimer += dt;
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    final radius = size.x / 2;
    final center = Offset(radius, radius);

    final pulseScale = 1.0 + 0.05 * _sinNorm(_pulseTimer * 3);
    final pulsedRadius = (radius - _borderWidth) * pulseScale;

    canvas.drawCircle(center, pulsedRadius + 4, _innerGlow);
    canvas.drawCircle(center, pulsedRadius, _borderPaint);
  }

  double _sinNorm(double t) {
    final v = t % (3.14159 * 2);
    return _sin(v);
  }

  static double _sin(double x) {
    // Taylor approximation good enough for visual pulsing
    final x2 = x * x;
    return x * (1 - x2 / 6 * (1 - x2 / 20 * (1 - x2 / 42)));
  }
}
