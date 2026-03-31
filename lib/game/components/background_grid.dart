import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/painting.dart' show RadialGradient, Alignment;

import 'package:dont_tap_rogue_op/game/protocol_game.dart';

class BackgroundGrid extends PositionComponent
    with HasGameReference<ProtocolGame> {
  BackgroundGrid() : super(priority: -100);

  static const double _gridSpacing = 48.0;
  static const int _scanlineCount = 3;

  double _scanlinePhase = 0;
  double _pulsePhase = 0;

  final Random _rng = Random();
  final List<_GlitchLine> _glitches = [];
  double _glitchTimer = 0;

  final Paint _gridPaint = Paint()
    ..color = const Color(0xFF00F0FF).withValues(alpha: 0.04)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.5;

  final Paint _scanPaint = Paint()
    ..style = PaintingStyle.fill;

  final Paint _crossPaint = Paint()
    ..color = const Color(0xFF00F0FF).withValues(alpha: 0.06)
    ..style = PaintingStyle.fill;

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
    position = Vector2.zero();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _scanlinePhase += dt * 40;
    _pulsePhase += dt * 0.6;

    _glitchTimer -= dt;
    if (_glitchTimer <= 0) {
      _glitchTimer = 0.3 + _rng.nextDouble() * 1.5;
      if (_rng.nextDouble() < 0.4) {
        _glitches.add(_GlitchLine(
          y: _rng.nextDouble() * game.size.y,
          width: 30 + _rng.nextDouble() * 150,
          lifetime: 0.05 + _rng.nextDouble() * 0.15,
        ));
      }
    }

    _glitches.removeWhere((g) {
      g.age += dt;
      return g.age >= g.lifetime;
    });
  }

  @override
  void render(Canvas canvas) {
    final w = game.size.x;
    final h = game.size.y;

    _renderGrid(canvas, w, h);
    _renderScanlines(canvas, w, h);
    _renderCrosshairs(canvas, w, h);
    _renderGlitches(canvas, w);
    _renderVignette(canvas, w, h);
  }

  void _renderGrid(Canvas canvas, double w, double h) {
    final pulse = (sin(_pulsePhase) * 0.5 + 0.5);
    _gridPaint.color = Color.fromARGB(
      (6 + pulse * 4).toInt(),
      0, 240, 255,
    );

    for (double x = 0; x < w; x += _gridSpacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, h), _gridPaint);
    }
    for (double y = 0; y < h; y += _gridSpacing) {
      canvas.drawLine(Offset(0, y), Offset(w, y), _gridPaint);
    }
  }

  void _renderScanlines(Canvas canvas, double w, double h) {
    for (int i = 0; i < _scanlineCount; i++) {
      final y = (_scanlinePhase + i * (h / _scanlineCount)) % h;
      final alpha = (sin((y / h) * pi) * 0.08).clamp(0.0, 1.0);
      _scanPaint.color = Color.fromARGB(
        (alpha * 255).toInt(),
        0, 240, 255,
      );
      canvas.drawRect(
        Rect.fromLTWH(0, y, w, 1.5),
        _scanPaint,
      );
    }
  }

  void _renderCrosshairs(Canvas canvas, double w, double h) {
    for (double x = _gridSpacing; x < w; x += _gridSpacing) {
      for (double y = _gridSpacing; y < h; y += _gridSpacing) {
        canvas.drawRect(
          Rect.fromCenter(center: Offset(x, y), width: 2, height: 2),
          _crossPaint,
        );
      }
    }
  }

  void _renderGlitches(Canvas canvas, double w) {
    for (final g in _glitches) {
      final progress = g.age / g.lifetime;
      final alpha = (1.0 - progress) * 0.12;
      final x = _rng.nextDouble() * (w - g.width);
      canvas.drawRect(
        Rect.fromLTWH(x, g.y, g.width, 2),
        Paint()..color = Color.fromARGB((alpha * 255).toInt(), 0, 240, 255),
      );
    }
  }

  void _renderVignette(Canvas canvas, double w, double h) {
    final rect = Rect.fromLTWH(0, 0, w, h);
    final gradient = RadialGradient(
      center: Alignment.center,
      radius: 0.85,
      colors: const [
        Color(0x00000000),
        Color(0x40000000),
      ],
    );
    canvas.drawRect(
      rect,
      Paint()..shader = gradient.createShader(rect),
    );
  }
}

class _GlitchLine {
  _GlitchLine({required this.y, required this.width, required this.lifetime});

  final double y;
  final double width;
  final double lifetime;
  double age = 0;
}
