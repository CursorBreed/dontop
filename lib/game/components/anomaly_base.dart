import 'package:flame/components.dart';
import 'package:flame/events.dart';

import 'package:dont_tap_rogue_op/game/protocol_game.dart';

abstract class AnomalyBase extends PositionComponent
    with TapCallbacks, HasGameReference<ProtocolGame> {

  Vector2? get anomalyVelocity => null;

  @override
  void onTapDown(TapDownEvent event) {
    game.onAnomalyTapped();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_isOffScreen()) {
      removeFromParent();
    }
  }

  bool _isOffScreen() {
    final gameSize = game.size;
    return position.x + size.x < -50 ||
        position.x > gameSize.x + 50 ||
        position.y + size.y < -50 ||
        position.y > gameSize.y + 50;
  }
}
