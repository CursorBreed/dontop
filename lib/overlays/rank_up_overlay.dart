import 'package:flutter/material.dart';

import 'package:dont_tap_rogue_op/game/managers/rank_config.dart';
import 'package:dont_tap_rogue_op/game/protocol_game.dart';
import 'package:dont_tap_rogue_op/theme/app_theme.dart';

class RankUpOverlay extends StatelessWidget {
  const RankUpOverlay({
    super.key,
    required this.game,
    required this.newRank,
  });

  final ProtocolGame game;
  final RankDefinition newRank;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.terminalSurface.withValues(alpha: 0.9),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.systemVoid,
            border: Border.all(
              color: AppColors.containmentCyan,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'CLEARANCE\nUPGRADED',
                textAlign: TextAlign.center,
                style: AppTextStyles.screenHeader.copyWith(
                  color: AppColors.containmentCyan,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.sm,
                  horizontal: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.containmentCyan.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'RANK ${newRank.rank}',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.dimmedText,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      newRank.title,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.button.copyWith(
                        color: AppColors.containmentCyan,
                        fontSize: 22,
                      ),
                    ),
                  ],
                ),
              ),
              if (newRank.modifierName.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.hazardYellow.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'NEW MODIFIER UNLOCKED',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.hazardYellow,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        newRank.modifierName,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.button.copyWith(
                          color: AppColors.primaryText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        newRank.modifierDescription,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.dimmedText,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              _OverlayButton(
                label: 'CONTINUE',
                borderColor: AppColors.containmentCyan,
                onTap: () => game.dismissRankUp(),
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
