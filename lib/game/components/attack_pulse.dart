import 'dart:ui';

import 'package:flame/components.dart';

import 'package:dont_tap_rogue_op/game/components/decoy_threat.dart';
import 'package:dont_tap_rogue_op/game/components/threat.dart';
import 'package:dont_tap_rogue_op/game/protocol_game.dart';

class AttackPulse extends PositionComponent
    with HasGameReference<ProtocolGame> {
  AttackPulse({
    required Vector2 origin,
    required this.direction,
  }) : super(size: Vector2.all(20), anchor: Anchor.center) {
    position = origin.clone();
    _velocity = _directionToVelocity(direction);
  }

  final ThreatDirection direction;
  late final Vector2 _velocity;

  static const double _speed = 800.0;
  static const double _hitRadius = 40.0;
  static const double _maxDistance = 1200.0;

  double _distanceTraveled = 0;
  double _fadeAlpha = 1.0;

  final Paint _corePaint = Paint()
    ..color = const Color(0xFF00F0FF)
    ..style = PaintingStyle.fill;

  final Paint _glowPaint = Paint()
    ..color = const Color(0xFF00F0FF).withValues(alpha: 0.4)
    ..style = PaintingStyle.fill;

  static Vector2 _directionToVelocity(ThreatDirection dir) {
    switch (dir) {
      case ThreatDirection.up:
        return Vector2(0, -_speed);
      case ThreatDirection.down:
        return Vector2(0, _speed);
      case ThreatDirection.left:
        return Vector2(-_speed, 0);
      case ThreatDirection.right:
        return Vector2(_speed, 0);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    final displacement = _velocity * dt;
    position += displacement;
    _distanceTraveled += displacement.length;

    _fadeAlpha = (1.0 - _distanceTraveled / _maxDistance).clamp(0.0, 1.0);

    if (_distanceTraveled >= _maxDistance || _isOffScreen()) {
      removeFromParent();
      return;
    }

    _checkCollisions();
  }

  void _checkCollisions() {
    for (final decoy in game.children.whereType<DecoyThreat>().toList()) {
      final dist = position.distanceTo(decoy.position);
      if (dist < _hitRadius) {
        game.onDecoyShot(decoy);
        removeFromParent();
        return;
      }
    }

    for (final threat in game.children.whereType<Threat>().toList()) {
      final dist = position.distanceTo(threat.position);
      if (dist < _hitRadius) {
        game.onThreatDestroyed(threat);
        removeFromParent();
        return;
      }
    }
  }

  bool _isOffScreen() {
    final gs = game.size;
    return position.x < -50 ||
        position.x > gs.x + 50 ||
        position.y < -50 ||
        position.y > gs.y + 50;
  }

  @override
  void render(Canvas canvas) {
    final center = Offset(size.x / 2, size.y / 2);
    final radius = size.x / 2;

    _glowPaint.color = Color.fromARGB(
      (100 * _fadeAlpha).toInt(),
      0,
      240,
      255,
    );
    canvas.drawCircle(center, radius + 4, _glowPaint);

    _corePaint.color = Color.fromARGB(
      (255 * _fadeAlpha).toInt(),
      0,
      240,
      255,
    );
    canvas.drawCircle(center, radius * 0.6, _corePaint);
  }
}
