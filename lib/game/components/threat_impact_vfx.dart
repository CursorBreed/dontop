import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

class ThreatImpactVfx extends PositionComponent {
  ThreatImpactVfx({required Vector2 impactPosition})
      : super(anchor: Anchor.center) {
    position = impactPosition;
    size = Vector2.all(200);
    _initParticles();
  }

  static const int _particleCount = 12;
  static const double _maxLifetime = 0.45;

  final List<_Particle> _particles = [];
  double _shockwaveRadius = 0;
  double _shockwaveAlpha = 1.0;
  double _elapsed = 0;

  final Paint _shockwavePaint = Paint()
    ..color = const Color(0xFF00F0FF)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3.0;

  void _initParticles() {
    final rng = Random();
    for (int i = 0; i < _particleCount; i++) {
      final angle = (i / _particleCount) * 2 * pi + rng.nextDouble() * 0.4;
      final speed = 150.0 + rng.nextDouble() * 200;
      _particles.add(_Particle(
        velocity: Vector2(cos(angle) * speed, sin(angle) * speed),
        radius: 2.0 + rng.nextDouble() * 3,
        lifetime: _maxLifetime * (0.6 + rng.nextDouble() * 0.4),
      ));
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;

    _shockwaveRadius += 400 * dt;
    _shockwaveAlpha = (1.0 - _elapsed / _maxLifetime).clamp(0.0, 1.0);

    for (final p in _particles) {
      p.age += dt;
      p.x += p.vx * dt;
      p.y += p.vy * dt;
      p.applyDamping(0.96);
    }

    if (_elapsed >= _maxLifetime) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final center = Offset(size.x / 2, size.y / 2);

    _shockwavePaint.color = Color.fromARGB(
      (180 * _shockwaveAlpha).toInt(),
      0, 240, 255,
    );
    _shockwavePaint.strokeWidth = 3.0 * _shockwaveAlpha;
    canvas.drawCircle(center, _shockwaveRadius, _shockwavePaint);

    for (final p in _particles) {
      if (p.age >= p.lifetime) continue;
      final alpha = (1.0 - p.age / p.lifetime).clamp(0.0, 1.0);
      final paint = Paint()
        ..color = Color.fromARGB(
          (255 * alpha).toInt(),
          0, 240, 255,
        )
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(center.dx + p.x, center.dy + p.y),
        p.radius * alpha,
        paint,
      );
    }
  }
}

class _Particle {
  _Particle({
    required Vector2 velocity,
    required this.radius,
    required this.lifetime,
  }) : _vx = velocity.x, _vy = velocity.y;

  double _vx;
  double _vy;
  final double radius;
  final double lifetime;
  double age = 0;
  double x = 0;
  double y = 0;

  double get vx => _vx;
  double get vy => _vy;

  void applyDamping(double factor) {
    _vx *= factor;
    _vy *= factor;
  }
}
