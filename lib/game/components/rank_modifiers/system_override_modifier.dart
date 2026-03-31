import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

import 'package:dont_tap_rogue_op/game/components/anomaly_base.dart';
import 'package:dont_tap_rogue_op/game/protocol_game.dart';

/// Rank 7 modifier: spawns fake system overlays as tappable anomalies.
class SystemOverrideModifier extends Component
    with HasGameReference<ProtocolGame> {
  final Random _rng = Random();
  double _timer = 0;
  double _nextOverlay = 6.0;

  @override
  void update(double dt) {
    super.update(dt);
    if (game.state != GameState.active) return;

    _timer += dt;
    if (_timer >= _nextOverlay) {
      _timer = 0;
      _nextOverlay = 7.0 + _rng.nextDouble() * 6.0;
      _spawnFakeOverlay();
    }
  }

  void _spawnFakeOverlay() {
    final gameSize = game.size;
    final variant = _rng.nextInt(3);

    String label;
    Color bgColor;
    Color textColor;
    Color borderColor;
    Vector2 overlaySize;

    switch (variant) {
      case 0:
        label = 'SEQUENCE SURVIVED!';
        bgColor = const Color(0xFF050505);
        textColor = const Color(0xFF00F0FF);
        borderColor = const Color(0xFF00F0FF);
        overlaySize = Vector2(260, 56);
      case 1:
        label = 'TAP TO CLAIM REWARD';
        bgColor = const Color(0xFF050505);
        textColor = const Color(0xFFFFF500);
        borderColor = const Color(0xFFFFF500);
        overlaySize = Vector2(250, 52);
      default:
        label = 'SYSTEM OVERRIDE -- ACCEPT?';
        bgColor = const Color(0xFF121212);
        textColor = const Color(0xFFFF003C);
        borderColor = const Color(0xFFFF003C);
        overlaySize = Vector2(280, 56);
    }

    final x = (gameSize.x - overlaySize.x) / 2 +
        (_rng.nextDouble() - 0.5) * 60;
    final y = 120 + _rng.nextDouble() * (gameSize.y * 0.4);

    final overlay = _FakeOverlayAnomaly(
      startPosition: Vector2(x, y),
      overlaySize: overlaySize,
      label: label,
      bgColor: bgColor,
      textColor: textColor,
      borderColor: borderColor,
    );

    game.add(overlay);
  }
}

class _FakeOverlayAnomaly extends AnomalyBase {
  _FakeOverlayAnomaly({
    required Vector2 startPosition,
    required Vector2 overlaySize,
    required this.label,
    required this.bgColor,
    required this.textColor,
    required this.borderColor,
  }) {
    position = startPosition;
    size = overlaySize;
  }

  final String label;
  final Color bgColor;
  final Color textColor;
  final Color borderColor;

  double _lifetime = 0;
  static const double _maxLifetime = 3.0;

  @override
  void update(double dt) {
    _lifetime += dt;
    if (_lifetime >= _maxLifetime) {
      removeFromParent();
      return;
    }
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    final alpha = _lifetime < 0.2
        ? _lifetime / 0.2
        : _lifetime > _maxLifetime - 0.3
            ? (_maxLifetime - _lifetime) / 0.3
            : 1.0;

    final rect = size.toRect();

    canvas.drawRect(
      rect,
      Paint()
        ..color = bgColor.withValues(alpha: 0.95 * alpha)
        ..style = PaintingStyle.fill,
    );

    canvas.drawRect(
      rect,
      Paint()
        ..color = borderColor.withValues(alpha: alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    final builder = ParagraphBuilder(ParagraphStyle(
      textAlign: TextAlign.center,
      maxLines: 1,
    ))
      ..pushStyle(TextStyle(
        color: textColor.withValues(alpha: alpha),
        fontSize: 15,
        fontWeight: FontWeight.w700,
        fontFamily: 'SpaceMono',
      ))
      ..addText(label);

    final paragraph = builder.build();
    paragraph.layout(ParagraphConstraints(width: size.x));
    final textOffset = Offset(
      (size.x - paragraph.width) / 2,
      (size.y - paragraph.height) / 2,
    );
    canvas.drawParagraph(paragraph, textOffset);
  }
}
