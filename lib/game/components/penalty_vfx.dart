import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

class PenaltyVfx extends PositionComponent {
  PenaltyVfx({required Vector2 impactPosition})
      : super(anchor: Anchor.center) {
    position = impactPosition;
    size = Vector2.all(200);
    _initParticles();
  }

  static const int _particleCount = 10;
  static const double _maxLifetime = 0.5;

  final List<_Particle> _particles = [];
  double _shockwaveRadius = 0;
  double _shockwaveAlpha = 1.0;
  double _elapsed = 0;

  final Paint _shockwavePaint = Paint()
    ..color = const Color(0xFFFF003C)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3.0;

  void _initParticles() {
    final rng = Random();
    for (int i = 0; i < _particleCount; i++) {
      final angle = (i / _particleCount) * 2 * pi + rng.nextDouble() * 0.4;
      final speed = 100.0 + rng.nextDouble() * 150;
      _particles.add(_Particle(
        vx: cos(angle) * speed,
        vy: sin(angle) * speed,
        radius: 2.0 + rng.nextDouble() * 3,
        lifetime: _maxLifetime * (0.6 + rng.nextDouble() * 0.4),
      ));
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;

    _shockwaveRadius += 350 * dt;
    _shockwaveAlpha = (1.0 - _elapsed / _maxLifetime).clamp(0.0, 1.0);

    for (final p in _particles) {
      p.age += dt;
      p.x += p.vx * dt;
      p.y += p.vy * dt;
      p.vx *= 0.96;
      p.vy *= 0.96;
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
      255, 0, 60,
    );
    _shockwavePaint.strokeWidth = 3.0 * _shockwaveAlpha;
    canvas.drawCircle(center, _shockwaveRadius, _shockwavePaint);

    for (final p in _particles) {
      if (p.age >= p.lifetime) continue;
      final alpha = (1.0 - p.age / p.lifetime).clamp(0.0, 1.0);
      final paint = Paint()
        ..color = Color.fromARGB(
          (255 * alpha).toInt(),
          255, 0, 60,
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
    required this.vx,
    required this.vy,
    required this.radius,
    required this.lifetime,
  });

  double vx;
  double vy;
  final double radius;
  final double lifetime;
  double age = 0;
  double x = 0;
  double y = 0;
}
