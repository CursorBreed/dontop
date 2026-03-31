import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dont_tap_rogue_op/game/managers/rank_config.dart';
import 'package:dont_tap_rogue_op/theme/app_theme.dart';

class ScoreScreen extends StatefulWidget {
  const ScoreScreen({super.key});

  @override
  State<ScoreScreen> createState() => _ScoreScreenState();
}

class _ScoreScreenState extends State<ScoreScreen> {
  static const _keyHighestSequence = 'highest_sequence';
  static const _keyTotalTimeEndured = 'total_time_endured';

  int _highestSequence = 0;
  int _totalTimeEndured = 0;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadScores();
  }

  Future<void> _loadScores() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _highestSequence = prefs.getInt(_keyHighestSequence) ?? 0;
      _totalTimeEndured = prefs.getInt(_keyTotalTimeEndured) ?? 0;
      _loaded = true;
    });
  }

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final rankDef = RankConfig.getRankForSequence(_highestSequence);
    final nextRank = RankConfig.getNextRank(_highestSequence);

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
                'RESTRAINT INDEX',
                style: AppTextStyles.screenHeader,
              ),
              const SizedBox(height: AppSpacing.xl),
              if (_loaded) ...[
                _ScoreTile(
                  label: 'OPERATOR RANK',
                  value: rankDef.title,
                  subtitle: nextRank != null
                      ? 'NEXT: ${nextRank.title} (SEQ ${nextRank.requiredSequence})'
                      : 'MAXIMUM CLEARANCE',
                  accentColor: AppColors.containmentCyan,
                ),
                const SizedBox(height: AppSpacing.md),
                _ScoreTile(
                  label: 'HIGHEST SEQUENCE REACHED',
                  value: _highestSequence.toString().padLeft(2, '0'),
                ),
                const SizedBox(height: AppSpacing.md),
                _ScoreTile(
                  label: 'TOTAL TIME ENDURED',
                  value: _formatTime(_totalTimeEndured),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ScoreTile extends StatelessWidget {
  const _ScoreTile({
    required this.label,
    required this.value,
    this.subtitle,
    this.accentColor,
  });

  final String label;
  final String value;
  final String? subtitle;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.containmentCyan, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.body.copyWith(color: AppColors.dimmedText),
          ),
          const SizedBox(height: AppSpacing.xs),
          if (accentColor != null)
            Text(
              value,
              style: AppTextStyles.button.copyWith(
                color: accentColor,
                fontSize: 22,
              ),
            )
          else
            Text(
              value,
              style: AppTextStyles.countdownTimer.copyWith(fontSize: 48),
            ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: AppTextStyles.body.copyWith(
                color: AppColors.dimmedText,
                fontSize: 11,
              ),
            ),
          ],
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
