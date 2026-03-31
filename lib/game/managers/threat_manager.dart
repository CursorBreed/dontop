import 'dart:math';

import 'package:flame/components.dart';

import 'package:dont_tap_rogue_op/game/components/decoy_threat.dart';
import 'package:dont_tap_rogue_op/game/components/threat.dart';
import 'package:dont_tap_rogue_op/game/managers/level_config.dart';
import 'package:dont_tap_rogue_op/game/protocol_game.dart';

class ThreatManager extends Component with HasGameReference<ProtocolGame> {
  ThreatManager({required this.config});

  final LevelConfig config;
  final Random _rng = Random();

  double _spawnTimer = 0;
  bool _spawning = false;

  void startSpawning() {
    _spawning = true;
    _spawnTimer = 0;
  }

  void stopSpawning() {
    _spawning = false;
  }

  int get _activeThreats =>
      game.children.whereType<Threat>().length +
      game.children.whereType<DecoyThreat>().length;

  @override
  void update(double dt) {
    super.update(dt);
    if (!_spawning || !config.threatEnabled) return;

    _spawnTimer += dt;
    if (_spawnTimer >= config.threatSpawnInterval) {
      _spawnTimer -= config.threatSpawnInterval;
      if (_activeThreats < config.maxSimultaneousThreats) {
        _spawnThreat();
      }
    }
  }

  void _spawnThreat() {
    final gameSize = game.size;
    final focusNodeCenter = Vector2(gameSize.x / 2, gameSize.y * 0.75);

    final edge = _rng.nextInt(4);
    Vector2 startPos;
    ThreatDirection direction;
    Vector2 velocity;

    switch (edge) {
      case 0:
        startPos = Vector2(focusNodeCenter.x + (_rng.nextDouble() - 0.5) * 80, -40);
        direction = ThreatDirection.down;
        final toTarget = focusNodeCenter - startPos;
        velocity = toTarget.normalized() * config.threatSpeed;
      case 1:
        startPos = Vector2(gameSize.x + 40, focusNodeCenter.y + (_rng.nextDouble() - 0.5) * 80);
        direction = ThreatDirection.left;
        final toTarget = focusNodeCenter - startPos;
        velocity = toTarget.normalized() * config.threatSpeed;
      case 2:
        startPos = Vector2(focusNodeCenter.x + (_rng.nextDouble() - 0.5) * 80, gameSize.y + 40);
        direction = ThreatDirection.up;
        final toTarget = focusNodeCenter - startPos;
        velocity = toTarget.normalized() * config.threatSpeed;
      default:
        startPos = Vector2(-40, focusNodeCenter.y + (_rng.nextDouble() - 0.5) * 80);
        direction = ThreatDirection.right;
        final toTarget = focusNodeCenter - startPos;
        velocity = toTarget.normalized() * config.threatSpeed;
    }

    final isDecoy = config.decoyChance > 0 && _rng.nextDouble() < config.decoyChance;

    if (isDecoy) {
      final decoySpeed = config.threatSpeed * 0.85;
      final toTarget = focusNodeCenter - startPos;
      final decoyVelocity = toTarget.normalized() * decoySpeed;

      game.add(DecoyThreat(
        startPosition: startPos,
        velocity: decoyVelocity,
        direction: direction,
      ));
    } else {
      game.add(Threat(
        startPosition: startPos,
        velocity: velocity,
        direction: direction,
      ));
    }
  }
}
