import 'dart:math';

import 'package:flame/components.dart';

import 'package:dont_tap_rogue_op/game/components/anomaly_base.dart';
import 'package:dont_tap_rogue_op/game/protocol_game.dart';

/// Rank 2 modifier: anomalies randomly change direction mid-flight.
class SignalDriftModifier extends Component
    with HasGameReference<ProtocolGame> {
  final Random _rng = Random();
  double _timer = 0;
  static const double _interval = 2.5;

  @override
  void update(double dt) {
    super.update(dt);
    if (game.state != GameState.active) return;

    _timer += dt;
    if (_timer >= _interval) {
      _timer -= _interval;
      _applyDrift();
    }
  }

  void _applyDrift() {
    final anomalies = game.children.whereType<AnomalyBase>().toList();
    if (anomalies.isEmpty) return;

    final target = anomalies[_rng.nextInt(anomalies.length)];
    final v = target.anomalyVelocity;
    if (v == null) return;

    final angle = (_rng.nextDouble() - 0.5) * pi * 0.6;
    final c = cos(angle);
    final s = sin(angle);
    final nx = v.x * c - v.y * s;
    final ny = v.x * s + v.y * c;
    v.setValues(nx, ny);
  }
}
