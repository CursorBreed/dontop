import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/effects.dart';

import 'package:dont_tap_rogue_op/game/components/threat.dart';
import 'package:dont_tap_rogue_op/game/protocol_game.dart';

class FocusNode extends PositionComponent
    with DragCallbacks, HasGameReference<ProtocolGame> {
  FocusNode() : super(size: Vector2.all(120), anchor: Anchor.center);

  static const double _borderWidth = 3.0;
  static const double _swipeThreshold = 20.0;

  final Paint _borderPaint = Paint()
    ..color = const Color(0xFF00F0FF)
    ..style = PaintingStyle.stroke
    ..strokeWidth = _borderWidth;

  final Paint _fillPaint = Paint()
    ..color = const Color(0xFF008B94)
    ..style = PaintingStyle.fill;

  bool _isHeld = false;
  bool get isHeld => _isHeld;

  Vector2 _dragAccumulator = Vector2.zero();
  bool _swipeReady = true;

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    position = Vector2(size.x / 2, size.y * 0.75);
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    if (game.state == GameState.breached || game.state == GameState.survived) {
      return;
    }
    _isHeld = true;
    _dragAccumulator = Vector2.zero();
    _swipeReady = true;
    _applyHeldScale();
    game.onFocusNodeHeld();
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    if (!_isHeld || !_swipeReady) return;

    _dragAccumulator += event.localDelta;

    final dx = _dragAccumulator.x;
    final dy = _dragAccumulator.y;

    if (dx.abs() > _swipeThreshold || dy.abs() > _swipeThreshold) {
      ThreatDirection direction;
      if (dx.abs() > dy.abs()) {
        direction = dx > 0 ? ThreatDirection.right : ThreatDirection.left;
      } else {
        direction = dy > 0 ? ThreatDirection.down : ThreatDirection.up;
      }

      game.onSwipeAttack(direction);
      _swipeReady = false;
      _dragAccumulator = Vector2.zero();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!_isHeld) return;

    if (!_swipeReady && _dragAccumulator.length < _swipeThreshold * 0.5) {
      _swipeReady = true;
    }
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    if (!_isHeld) return;
    _isHeld = false;
    _dragAccumulator = Vector2.zero();
    _applyIdleScale();
    game.onFocusNodeReleased();
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
    if (!_isHeld) return;
    _isHeld = false;
    _dragAccumulator = Vector2.zero();
    _applyIdleScale();
    game.onFocusNodeReleased();
  }

  void resetState() {
    _isHeld = false;
    _dragAccumulator = Vector2.zero();
    _swipeReady = true;
    scale = Vector2.all(1.0);
  }

  void _applyHeldScale() {
    children.whereType<ScaleEffect>().forEach((e) => e.removeFromParent());
    add(ScaleEffect.to(
      Vector2.all(0.9),
      EffectController(duration: 0.1),
    ));
  }

  void _applyIdleScale() {
    children.whereType<ScaleEffect>().forEach((e) => e.removeFromParent());
    add(ScaleEffect.to(
      Vector2.all(1.0),
      EffectController(duration: 0.1),
    ));
  }

  @override
  void render(Canvas canvas) {
    final radius = size.x / 2;
    final center = Offset(radius, radius);

    if (_isHeld) {
      canvas.drawCircle(center, radius - _borderWidth, _fillPaint);
    }

    final phantom = game.phantomTouchModifier;
    if (_isHeld && phantom != null && phantom.isFlickering) {
      final flickerPaint = Paint()
        ..color = const Color(0xFF00F0FF).withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = _borderWidth * 2;
      canvas.drawCircle(center, radius + 2, flickerPaint);
    } else {
      canvas.drawCircle(center, radius - _borderWidth / 2, _borderPaint);
    }
  }
}
