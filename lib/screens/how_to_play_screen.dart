import 'package:flutter/material.dart';

import 'package:dont_tap_rogue_op/theme/app_theme.dart';

class HowToPlayScreen extends StatelessWidget {
  const HowToPlayScreen({super.key});

  static const _steps = <_Step>[
    _Step(
      number: '01',
      title: 'HOLD THE FOCUS NODE',
      description:
          'Press and hold the central node at the bottom of the screen. '
          'Hold move the node to dismiss the obstacles '
          'Do not release until the timer reaches zero.',
    ),
    _Step(
      number: '02',
      title: 'IGNORE ALL SYSTEM ANOMALIES',
      description:
          'The system will attempt to distract you with fake warnings, '
          'buttons, and alerts. Do not tap any of them.',
    ),
    _Step(
      number: '03',
      title: 'SURVIVE THE TIMER',
      description:
          'Keep holding the Focus Node until the countdown expires. '
          'Releasing early or tapping an anomaly is a containment breach.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.systemVoid,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.lg),
              _BackButton(onTap: () => Navigator.of(context).pop()),
              const SizedBox(height: AppSpacing.lg),
              const Text('OPERATOR MANUAL', style: AppTextStyles.screenHeader),
              const SizedBox(height: AppSpacing.xl),
              ..._steps.map((step) => _StepCard(step: step)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Step {
  const _Step({
    required this.number,
    required this.title,
    required this.description,
  });
  final String number;
  final String title;
  final String description;
}

class _StepCard extends StatelessWidget {
  const _StepCard({required this.step});
  final _Step step;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            step.number,
            style: AppTextStyles.screenHeader.copyWith(
              color: AppColors.containmentCyan,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: AppTextStyles.button.copyWith(
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(step.description, style: AppTextStyles.body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.arrow_back,
            color: AppColors.containmentCyan,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            'BACK',
            style: AppTextStyles.button.copyWith(
              color: AppColors.containmentCyan,
            ),
          ),
        ],
      ),
    );
  }
}
