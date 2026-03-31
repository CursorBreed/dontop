import 'dart:ui';

import 'package:flame/components.dart';

import 'package:dont_tap_rogue_op/game/protocol_game.dart';

enum ThreatDirection { up, down, left, right }

class Threat extends PositionComponent with HasGameReference<ProtocolGame> {
  Threat({
    required Vector2 startPosition,
    required this.velocity,
    required this.direction,
  }) : super(size: Vector2.all(32), anchor: Anchor.center) {
    position = startPosition;
  }

  final Vector2 velocity;
  final ThreatDirection direction;

  static const double _dangerRadius = 70.0;

  final Paint _corePaint = Paint()
    ..color = const Color(0xFFFFF500)
    ..style = PaintingStyle.fill;

  final Paint _glowPaint = Paint()
    ..color = const Color(0xFFFFF500).withValues(alpha: 0.3)
    ..style = PaintingStyle.fill;

  final Paint _trailPaint = Paint()
    ..color = const Color(0xFFFFF500).withValues(alpha: 0.15)
    ..style = PaintingStyle.fill;

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;

    final focusNodePos = Vector2(game.size.x / 2, game.size.y * 0.75);
    final dist = position.distanceTo(focusNodePos);

    if (dist < _dangerRadius) {
      game.onThreatReachedNode(this);
    }
  }

  @override
  void render(Canvas canvas) {
    final center = Offset(size.x / 2, size.y / 2);
    final radius = size.x / 2;

    canvas.drawCircle(center, radius + 6, _glowPaint);

    _drawTrail(canvas, center, radius);

    canvas.drawCircle(center, radius, _corePaint);

    _drawDirectionIndicator(canvas, center, radius);
  }

  void _drawTrail(Canvas canvas, Offset center, double radius) {
    final trailDir = Offset(-velocity.x, -velocity.y);
    final trailNorm = trailDir / trailDir.distance;

    for (int i = 1; i <= 3; i++) {
      final trailCenter = center + trailNorm * (i * 12.0);
      final trailRadius = radius * (1.0 - i * 0.2);
      canvas.drawCircle(trailCenter, trailRadius.clamp(2, radius), _trailPaint);
    }
  }

  void _drawDirectionIndicator(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = const Color(0xFF050505)
      ..style = PaintingStyle.fill;

    final path = Path();
    const arrowSize = 8.0;

    switch (direction) {
      case ThreatDirection.down:
        path.moveTo(center.dx, center.dy + arrowSize);
        path.lineTo(center.dx - arrowSize, center.dy - arrowSize / 2);
        path.lineTo(center.dx + arrowSize, center.dy - arrowSize / 2);
      case ThreatDirection.up:
        path.moveTo(center.dx, center.dy - arrowSize);
        path.lineTo(center.dx - arrowSize, center.dy + arrowSize / 2);
        path.lineTo(center.dx + arrowSize, center.dy + arrowSize / 2);
      case ThreatDirection.right:
        path.moveTo(center.dx + arrowSize, center.dy);
        path.lineTo(center.dx - arrowSize / 2, center.dy - arrowSize);
        path.lineTo(center.dx - arrowSize / 2, center.dy + arrowSize);
      case ThreatDirection.left:
        path.moveTo(center.dx - arrowSize, center.dy);
        path.lineTo(center.dx + arrowSize / 2, center.dy - arrowSize);
        path.lineTo(center.dx + arrowSize / 2, center.dy + arrowSize);
    }

    path.close();
    canvas.drawPath(path, paint);
  }
}
