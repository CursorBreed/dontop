import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dont_tap_rogue_op/theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const _keySoundEnabled = 'sound_enabled';
  static const _keyHapticsEnabled = 'haptics_enabled';

  bool _soundEnabled = true;
  bool _hapticsEnabled = true;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _soundEnabled = prefs.getBool(_keySoundEnabled) ?? true;
      _hapticsEnabled = prefs.getBool(_keyHapticsEnabled) ?? true;
      _loaded = true;
    });
  }

  Future<void> _setSoundEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySoundEnabled, value);
    setState(() => _soundEnabled = value);
  }

  Future<void> _setHapticsEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHapticsEnabled, value);
    setState(() => _hapticsEnabled = value);
  }

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
                'SYSTEM CALIBRATION',
                style: AppTextStyles.screenHeader,
              ),
              const SizedBox(height: AppSpacing.xl),
              if (_loaded) ...[
                _SettingsToggle(
                  label: 'SOUND EFFECTS',
                  value: _soundEnabled,
                  onChanged: _setSoundEnabled,
                ),
                const SizedBox(height: AppSpacing.md),
                _SettingsToggle(
                  label: 'HAPTIC FEEDBACK',
                  value: _hapticsEnabled,
                  onChanged: _setHapticsEnabled,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsToggle extends StatelessWidget {
  const _SettingsToggle({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.dimmedText, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.button),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.containmentCyan,
            activeTrackColor: AppColors.mutedTeal,
            inactiveThumbColor: AppColors.dimmedText,
            inactiveTrackColor: AppColors.terminalSurface,
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
