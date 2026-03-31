import 'package:flutter/material.dart';

import 'package:dont_tap_rogue_op/theme/app_theme.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  static const _policyText = '''
DATA SILENCE AGREEMENT

This application ("Don't Tap: Rogue Op") operates entirely offline. No personal data is collected, transmitted, or shared with any third party.

All game data — including your Restraint Index (highest sequence reached and total time endured) and system calibration preferences (sound effects and haptic feedback toggles) — is stored locally on your device only using platform-native storage mechanisms.

No analytics, tracking, advertising frameworks, or network requests of any kind are included in this application.

No account creation is required. No personally identifiable information is processed.

You may clear all locally stored data at any time by clearing the application's data through your device settings or by uninstalling the application.

This policy applies to version 1.0 and all subsequent versions unless stated otherwise in an updated agreement.''';

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
              const Text(
                'DATA SILENCE\nAGREEMENT',
                style: AppTextStyles.screenHeader,
              ),
              const SizedBox(height: AppSpacing.lg),
              const Expanded(
                child: SingleChildScrollView(
                  child: Text(_policyText, style: AppTextStyles.body),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),
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
