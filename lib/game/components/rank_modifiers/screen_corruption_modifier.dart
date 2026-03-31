import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

import 'package:dont_tap_rogue_op/game/protocol_game.dart';

/// Rank 4 modifier: brief full-screen color flash/static that obscures the display.
class ScreenCorruptionModifier extends Component
    with HasGameReference<ProtocolGame> {
  final Random _rng = Random();
  double _timer = 0;
  double _nextCorruption = 5.0;

  double _corruptionAlpha = 0;
  double _corruptionDuration = 0;
  double _corruptionElapsed = 0;
  bool _corrupting = false;

  final List<_StaticBar> _staticBars = [];

  @override
  void update(double dt) {
    super.update(dt);
    if (game.state != GameState.active) return;

    if (_corrupting) {
      _corruptionElapsed += dt;
      final progress = _corruptionElapsed / _corruptionDuration;
      if (progress < 0.3) {
        _corruptionAlpha = (progress / 0.3).clamp(0.0, 1.0) * 0.7;
      } else if (progress > 0.7) {
        _corruptionAlpha = ((1.0 - progress) / 0.3).clamp(0.0, 1.0) * 0.7;
      } else {
        _corruptionAlpha = 0.7;
      }

      if (_corruptionElapsed >= _corruptionDuration) {
        _corrupting = false;
        _corruptionAlpha = 0;
        _staticBars.clear();
        _nextCorruption = 4.0 + _rng.nextDouble() * 5.0;
        _timer = 0;
      }
      return;
    }

    _timer += dt;
    if (_timer >= _nextCorruption) {
      _startCorruption();
    }
  }

  void _startCorruption() {
    _corrupting = true;
    _corruptionDuration = 0.4 + _rng.nextDouble() * 0.3;
    _corruptionElapsed = 0;

    _staticBars.clear();
    final gameSize = game.size;
    final barCount = 5 + _rng.nextInt(8);
    for (int i = 0; i < barCount; i++) {
      _staticBars.add(_StaticBar(
        y: _rng.nextDouble() * gameSize.y,
        height: 2.0 + _rng.nextDouble() * 6,
        alpha: 0.2 + _rng.nextDouble() * 0.5,
      ));
    }
  }

  @override
  void render(Canvas canvas) {
    if (!_corrupting || _corruptionAlpha <= 0) return;

    final gameSize = game.size;
    final screenRect = Rect.fromLTWH(0, 0, gameSize.x, gameSize.y);

    canvas.drawRect(
      screenRect,
      Paint()..color = Color.fromARGB(
        (30 * _corruptionAlpha).toInt(),
        255, 0, 60,
      ),
    );

    for (final bar in _staticBars) {
      canvas.drawRect(
        Rect.fromLTWH(0, bar.y, gameSize.x, bar.height),
        Paint()..color = Color.fromARGB(
          (255 * bar.alpha * _corruptionAlpha).toInt(),
          255, 255, 255,
        ),
      );
    }
  }
}

class _StaticBar {
  const _StaticBar({
    required this.y,
    required this.height,
    required this.alpha,
  });
  final double y;
  final double height;
  final double alpha;
}
