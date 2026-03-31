import 'dart:math';

import 'package:flame/components.dart';

import 'package:dont_tap_rogue_op/game/protocol_game.dart';

/// Rank 6 modifier: timer display briefly shows false data.
class CountdownGlitchModifier extends Component
    with HasGameReference<ProtocolGame> {
  final Random _rng = Random();
  double _timer = 0;
  double _nextGlitch = 3.0;

  String? _glitchText;
  double _glitchDuration = 0;
  double _glitchElapsed = 0;
  bool _glitching = false;

  String? get activeGlitchText => _glitching ? _glitchText : null;

  @override
  void update(double dt) {
    super.update(dt);
    if (game.state != GameState.active) return;

    if (_glitching) {
      _glitchElapsed += dt;
      if (_glitchElapsed >= _glitchDuration) {
        _glitching = false;
        _glitchText = null;
        _nextGlitch = 3.0 + _rng.nextDouble() * 5.0;
        _timer = 0;
      }
      return;
    }

    _timer += dt;
    if (_timer >= _nextGlitch) {
      _startGlitch();
    }
  }

  void _startGlitch() {
    _glitching = true;
    _glitchDuration = 0.15 + _rng.nextDouble() * 0.2;
    _glitchElapsed = 0;

    final variant = _rng.nextInt(4);
    switch (variant) {
      case 0:
        _glitchText = '00.0';
      case 1:
        _glitchText = '${_rng.nextInt(60).toString().padLeft(2, '0')}.${_rng.nextInt(10)}';
      case 2:
        _glitchText = '--.-';
      default:
        _glitchText = '##.#';
    }
  }
}
