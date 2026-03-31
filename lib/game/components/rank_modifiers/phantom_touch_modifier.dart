import 'dart:math';

import 'package:flame/components.dart';

import 'package:dont_tap_rogue_op/game/protocol_game.dart';

/// Rank 3 modifier: Focus Node border flickers/pulses erratically while held.
class PhantomTouchModifier extends Component
    with HasGameReference<ProtocolGame> {
  final Random _rng = Random();
  double _timer = 0;
  double _nextFlicker = 2.0;

  bool _flickering = false;
  bool get isFlickering => _flickering;

  double _flickerDuration = 0;
  double _flickerElapsed = 0;

  @override
  void update(double dt) {
    super.update(dt);
    if (game.state != GameState.active) return;

    if (_flickering) {
      _flickerElapsed += dt;
      if (_flickerElapsed >= _flickerDuration) {
        _flickering = false;
        _nextFlicker = 1.5 + _rng.nextDouble() * 3.0;
        _timer = 0;
      }
      return;
    }

    _timer += dt;
    if (_timer >= _nextFlicker) {
      _flickering = true;
      _flickerDuration = 0.3 + _rng.nextDouble() * 0.5;
      _flickerElapsed = 0;
    }
  }
}
