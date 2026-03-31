import 'dart:math';

import 'package:flame/components.dart';

import 'package:dont_tap_rogue_op/game/components/anomaly_base.dart';
import 'package:dont_tap_rogue_op/game/components/static_noise_anomaly.dart';
import 'package:dont_tap_rogue_op/game/components/urgency_trap_anomaly.dart';
import 'package:dont_tap_rogue_op/game/managers/level_config.dart';
import 'package:dont_tap_rogue_op/game/protocol_game.dart';

class LevelManager extends Component with HasGameReference<ProtocolGame> {
  LevelManager({required this.config});

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

  @override
  void update(double dt) {
    super.update(dt);
    if (!_spawning) return;

    _spawnTimer += dt;
    if (_spawnTimer >= config.spawnInterval) {
      _spawnTimer -= config.spawnInterval;
      _spawnAnomaly();
    }
  }

  void _spawnAnomaly() {
    final type = config.allowedAnomalies[
        _rng.nextInt(config.allowedAnomalies.length)];

    final spawnData = _generateSpawnData();

    AnomalyBase anomaly;
    switch (type) {
      case AnomalyType.staticNoise:
        anomaly = StaticNoiseAnomaly(
          startPosition: spawnData.position,
          velocity: spawnData.velocity,
        );
      case AnomalyType.urgencyTrap:
        anomaly = UrgencyTrapAnomaly(
          startPosition: spawnData.position,
          velocity: spawnData.velocity,
        );
    }

    game.add(anomaly);
    game.onAnomalySpawned();
  }

  _SpawnData _generateSpawnData() {
    final gameSize = game.size;
    final focusNodeCenter = Vector2(gameSize.x / 2, gameSize.y * 0.75);
    const focusNodeBuffer = 160.0;
    const edgePadding = 32.0;

    // Pick a random edge: 0=top, 1=right, 2=bottom, 3=left
    final edge = _rng.nextInt(4);
    Vector2 startPos;
    Vector2 velocity;
    final speed = config.anomalySpeed;

    switch (edge) {
      case 0: // from top
        startPos = Vector2(
          edgePadding + _rng.nextDouble() * (gameSize.x - edgePadding * 2),
          -60,
        );
        velocity = Vector2(
          (_rng.nextDouble() - 0.5) * speed * 0.3,
          speed,
        );
      case 1: // from right
        startPos = Vector2(
          gameSize.x + 60,
          edgePadding + _rng.nextDouble() * (gameSize.y - edgePadding * 2),
        );
        velocity = Vector2(-speed, (_rng.nextDouble() - 0.5) * speed * 0.3);
      case 2: // from bottom
        startPos = Vector2(
          edgePadding + _rng.nextDouble() * (gameSize.x - edgePadding * 2),
          gameSize.y + 60,
        );
        velocity = Vector2(
          (_rng.nextDouble() - 0.5) * speed * 0.3,
          -speed,
        );
      default: // from left
        startPos = Vector2(
          -60,
          edgePadding + _rng.nextDouble() * (gameSize.y - edgePadding * 2),
        );
        velocity = Vector2(speed, (_rng.nextDouble() - 0.5) * speed * 0.3);
    }

    // Deflect away from focus node if spawning too close to it
    final distToNode = startPos.distanceTo(focusNodeCenter);
    if (distToNode < focusNodeBuffer) {
      final away = (startPos - focusNodeCenter).normalized();
      startPos += away * (focusNodeBuffer - distToNode);
    }

    return _SpawnData(position: startPos, velocity: velocity);
  }
}

class _SpawnData {
  const _SpawnData({required this.position, required this.velocity});
  final Vector2 position;
  final Vector2 velocity;
}
