import 'dart:math';

import 'package:flame/components.dart';

import 'package:dont_tap_rogue_op/game/components/rank_modifiers/mimic_node_anomaly.dart';
import 'package:dont_tap_rogue_op/game/protocol_game.dart';

/// Rank 5 modifier: periodically spawns a decoy that mimics the Focus Node.
class MimicProtocolModifier extends Component
    with HasGameReference<ProtocolGame> {
  final Random _rng = Random();
  double _timer = 0;
  double _nextSpawn = 8.0;

  @override
  void update(double dt) {
    super.update(dt);
    if (game.state != GameState.active) return;

    _timer += dt;
    if (_timer >= _nextSpawn) {
      _timer = 0;
      _nextSpawn = 8.0 + _rng.nextDouble() * 6.0;
      _spawnMimic();
    }
  }

  void _spawnMimic() {
    final gameSize = game.size;
    final focusNodeCenter = Vector2(gameSize.x / 2, gameSize.y * 0.75);

    final edge = _rng.nextInt(4);
    Vector2 startPos;

    switch (edge) {
      case 0:
        startPos = Vector2(
          _rng.nextDouble() * gameSize.x,
          -100,
        );
      case 1:
        startPos = Vector2(
          gameSize.x + 100,
          _rng.nextDouble() * gameSize.y,
        );
      case 2:
        startPos = Vector2(
          _rng.nextDouble() * gameSize.x,
          gameSize.y + 100,
        );
      default:
        startPos = Vector2(
          -100,
          _rng.nextDouble() * gameSize.y,
        );
    }

    final toTarget = focusNodeCenter - startPos;
    final velocity = toTarget.normalized() * 35.0;

    game.add(MimicNodeAnomaly(
      startPosition: startPos,
      velocity: velocity,
    ));
  }
}
