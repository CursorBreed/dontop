import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

import 'package:dont_tap_rogue_op/game/components/threat.dart';
import 'package:dont_tap_rogue_op/game/protocol_game.dart';

class DecoyThreat extends PositionComponent
    with HasGameReference<ProtocolGame> {
  DecoyThreat({
    required Vector2 startPosition,
    required this.velocity,
    required this.direction,
  }) : super(size: Vector2.all(32), anchor: Anchor.center) {
    position = startPosition;
  }

  final Vector2 velocity;
  final ThreatDirection direction;

  static const double _dangerRadius = 70.0;

  double _pulsePhase = 0;

  final Paint _corePaint = Paint()
    ..color = const Color(0xFFFF003C)
    ..style = PaintingStyle.fill;

  final Paint _glowPaint = Paint()
    ..color = const Color(0xFFFF003C).withValues(alpha: 0.3)
    ..style = PaintingStyle.fill;

  final Paint _trailPaint = Paint()
    ..color = const Color(0xFFFF003C).withValues(alpha: 0.15)
    ..style = PaintingStyle.fill;

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;
    _pulsePhase += dt * 8;

    final focusNodePos = Vector2(game.size.x / 2, game.size.y * 0.75);
    final dist = position.distanceTo(focusNodePos);

    if (dist < _dangerRadius) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final center = Offset(size.x / 2, size.y / 2);
    final radius = size.x / 2;
    final pulse = (sin(_pulsePhase) * 0.15 + 1.0);

    canvas.drawCircle(center, (radius + 6) * pulse, _glowPaint);
    _drawTrail(canvas, center, radius);
    canvas.drawCircle(center, radius, _corePaint);
    _drawXMark(canvas, center);
  }

  void _drawTrail(Canvas canvas, Offset center, double radius) {
    final trailDir = Offset(-velocity.x, -velocity.y);
    if (trailDir.distance == 0) return;
    final trailNorm = trailDir / trailDir.distance;

    for (int i = 1; i <= 3; i++) {
      final trailCenter = center + trailNorm * (i * 12.0);
      final trailRadius = radius * (1.0 - i * 0.2);
      canvas.drawCircle(trailCenter, trailRadius.clamp(2, radius), _trailPaint);
    }
  }

  void _drawXMark(Canvas canvas, Offset center) {
    final paint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    const s = 6.0;
    canvas.drawLine(
      Offset(center.dx - s, center.dy - s),
      Offset(center.dx + s, center.dy + s),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx + s, center.dy - s),
      Offset(center.dx - s, center.dy + s),
      paint,
    );
  }
}
