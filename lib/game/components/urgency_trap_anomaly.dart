import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

import 'package:dont_tap_rogue_op/game/components/anomaly_base.dart';

enum _TrapVariant { warning, clearCache, notification, lowBattery, update }

class UrgencyTrapAnomaly extends AnomalyBase {
  UrgencyTrapAnomaly({
    required Vector2 startPosition,
    required this.velocity,
  }) {
    position = startPosition;
    final rng = Random();
    _variant = _TrapVariant.values[rng.nextInt(_TrapVariant.values.length)];

    switch (_variant) {
      case _TrapVariant.warning:
        size = Vector2(180, 48);
        _label = 'WARNING';
        _bgColor = const Color(0xFFFF003C);
        _textColor = const Color(0xFFFFFFFF);
      case _TrapVariant.clearCache:
        size = Vector2(160, 44);
        _label = 'CLEAR CACHE';
        _bgColor = const Color(0xFF050505);
        _textColor = const Color(0xFFFFF500);
        _borderColor = const Color(0xFFFFF500);
      case _TrapVariant.notification:
        size = Vector2(200, 52);
        _label = 'NEW NOTIFICATION';
        _bgColor = const Color(0xFF121212);
        _textColor = const Color(0xFFFFFFFF);
        _borderColor = const Color(0xFFFF003C);
      case _TrapVariant.lowBattery:
        size = Vector2(170, 48);
        _label = 'LOW BATTERY';
        _bgColor = const Color(0xFF050505);
        _textColor = const Color(0xFFFFF500);
        _borderColor = const Color(0xFFFFF500);
      case _TrapVariant.update:
        size = Vector2(180, 48);
        _label = 'TAP TO UPDATE';
        _bgColor = const Color(0xFF050505);
        _textColor = const Color(0xFF00F0FF);
        _borderColor = const Color(0xFF00F0FF);
    }
  }

  final Vector2 velocity;

  @override
  Vector2 get anomalyVelocity => velocity;

  late final _TrapVariant _variant;
  late final String _label;
  late final Color _bgColor;
  late final Color _textColor;
  Color? _borderColor;

  @override
  void update(double dt) {
    position += velocity * dt;
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    final rect = size.toRect();

    // Background
    canvas.drawRect(
      rect,
      Paint()
        ..color = _bgColor
        ..style = PaintingStyle.fill,
    );

    // Border
    canvas.drawRect(
      rect,
      Paint()
        ..color = _borderColor ?? _bgColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Text label
    final paragraph = _buildParagraph();
    final textOffset = Offset(
      (size.x - paragraph.width) / 2,
      (size.y - paragraph.height) / 2,
    );
    canvas.drawParagraph(paragraph, textOffset);
  }

  Paragraph _buildParagraph() {
    final builder = ParagraphBuilder(ParagraphStyle(
      textAlign: TextAlign.center,
      maxLines: 1,
    ))
      ..pushStyle(TextStyle(
        color: _textColor,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        fontFamily: 'SpaceMono',
      ))
      ..addText(_label);

    final paragraph = builder.build();
    paragraph.layout(ParagraphConstraints(width: size.x));
    return paragraph;
  }
}
