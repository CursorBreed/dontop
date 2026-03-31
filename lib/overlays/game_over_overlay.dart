import 'package:flutter/material.dart';

import 'package:dont_tap_rogue_op/game/protocol_game.dart';
import 'package:dont_tap_rogue_op/theme/app_theme.dart';

class GameOverOverlay extends StatelessWidget {
  const GameOverOverlay({super.key, required this.game});

  final ProtocolGame game;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.terminalSurface.withValues(alpha: 0.85),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.systemVoid,
            border: Border.all(
              color: AppColors.systemErrorRed,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'CONTAINMENT\nBREACH',
                textAlign: TextAlign.center,
                style: AppTextStyles.screenHeader.copyWith(
                  color: AppColors.systemErrorRed,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                game.breachReason,
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.dimmedText,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _OverlayButton(
                label: 'REBOOT SEQUENCE',
                borderColor: AppColors.containmentCyan,
                onTap: () => game.restartLevel(),
              ),
              const SizedBox(height: AppSpacing.sm),
              _OverlayButton(
                label: 'RETURN TO TERMINAL',
                borderColor: AppColors.dimmedText,
                onTap: () {
                  game.returnToTerminal();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OverlayButton extends StatefulWidget {
  const _OverlayButton({
    required this.label,
    required this.borderColor,
    required this.onTap,
  });

  final String label;
  final Color borderColor;
  final VoidCallback onTap;

  @override
  State<_OverlayButton> createState() => _OverlayButtonState();
}

class _OverlayButtonState extends State<_OverlayButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 50),
        width: double.infinity,
        height: AppSpacing.xl,
        decoration: BoxDecoration(
          color: _pressed ? widget.borderColor : Colors.transparent,
          border: Border.all(color: widget.borderColor, width: 2),
        ),
        alignment: Alignment.center,
        child: Text(
          widget.label,
          style: AppTextStyles.button.copyWith(
            color: _pressed ? AppColors.systemVoid : widget.borderColor,
          ),
        ),
      ),
    );
  }
}
