import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dont_tap_rogue_op/game/managers/rank_config.dart';
import 'package:dont_tap_rogue_op/theme/app_theme.dart';

class TerminalScreen extends StatefulWidget {
  const TerminalScreen({super.key});

  @override
  State<TerminalScreen> createState() => _TerminalScreenState();
}

class _TerminalScreenState extends State<TerminalScreen> {
  static const _menuItems = <_MenuItem>[
    _MenuItem(label: 'INITIATE SEQUENCE', route: '/gameplay'),
    _MenuItem(label: 'OPERATOR MANUAL', route: '/how-to-play'),
    _MenuItem(label: 'SYSTEM CALIBRATION', route: '/settings'),
    _MenuItem(label: 'RESTRAINT INDEX', route: '/score'),
    _MenuItem(label: 'DATA SILENCE AGREEMENT', route: '/privacy'),
  ];

  int _highestSequence = 0;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadRank();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadRank();
  }

  Future<void> _loadRank() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _highestSequence = prefs.getInt('highest_sequence') ?? 0;
      _loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final rankDef = RankConfig.getRankForSequence(_highestSequence);
    final nextRank = RankConfig.getNextRank(_highestSequence);
    final progress = RankConfig.getProgressToNextRank(_highestSequence);

    return Scaffold(
      backgroundColor: AppColors.systemVoid,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.xl),
              Image.asset(
                'assets/images/logo.png',
                width: 180,
                errorBuilder: (context, error, stack) => Text(
                  "DON'T TAP:\nROGUE OP",
                  textAlign: TextAlign.center,
                  style: AppTextStyles.screenHeader.copyWith(
                    color: AppColors.containmentCyan,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              if (_loaded) _RankBadge(
                rankDef: rankDef,
                nextRank: nextRank,
                progress: progress,
                highestSequence: _highestSequence,
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _menuItems.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final item = _menuItems[index];
                    return _TerminalButton(
                      label: item.label,
                      onTap: () async {
                        await Navigator.of(context).pushNamed(item.route);
                        _loadRank();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RankBadge extends StatelessWidget {
  const _RankBadge({
    required this.rankDef,
    required this.nextRank,
    required this.progress,
    required this.highestSequence,
  });

  final RankDefinition rankDef;
  final RankDefinition? nextRank;
  final double progress;
  final int highestSequence;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.containmentCyan.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            'RANK ${rankDef.rank}',
            style: AppTextStyles.body.copyWith(
              color: AppColors.dimmedText,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            rankDef.title,
            style: AppTextStyles.button.copyWith(
              color: AppColors.containmentCyan,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          if (nextRank != null) ...[
            ClipRRect(
              child: SizedBox(
                height: 4,
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppColors.gridline,
                  valueColor: const AlwaysStoppedAnimation(
                    AppColors.containmentCyan,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'SEQ $highestSequence / ${nextRank!.requiredSequence} TO ${nextRank!.title}',
              style: AppTextStyles.body.copyWith(
                color: AppColors.dimmedText,
                fontSize: 10,
              ),
            ),
          ] else
            Text(
              'MAX RANK ACHIEVED',
              style: AppTextStyles.body.copyWith(
                color: AppColors.containmentCyan,
                fontSize: 10,
              ),
            ),
        ],
      ),
    );
  }
}

class _MenuItem {
  const _MenuItem({required this.label, required this.route});
  final String label;
  final String route;
}

class _TerminalButton extends StatefulWidget {
  const _TerminalButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  State<_TerminalButton> createState() => _TerminalButtonState();
}

class _TerminalButtonState extends State<_TerminalButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final borderColor =
        widget.label == 'INITIATE SEQUENCE'
            ? AppColors.containmentCyan
            : AppColors.primaryText;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 50),
        height: AppSpacing.xl,
        decoration: BoxDecoration(
          color: _pressed ? borderColor : Colors.transparent,
          border: Border.all(color: borderColor, width: 2),
        ),
        alignment: Alignment.center,
        child: Text(
          widget.label,
          style: AppTextStyles.button.copyWith(
            color: _pressed ? AppColors.systemVoid : borderColor,
          ),
        ),
      ),
    );
  }
}
