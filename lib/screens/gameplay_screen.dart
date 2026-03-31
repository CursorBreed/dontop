import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'package:dont_tap_rogue_op/game/protocol_game.dart';
import 'package:dont_tap_rogue_op/overlays/game_over_overlay.dart';
import 'package:dont_tap_rogue_op/overlays/level_complete_overlay.dart';
import 'package:dont_tap_rogue_op/overlays/pause_overlay.dart';
import 'package:dont_tap_rogue_op/overlays/rank_up_overlay.dart';
import 'package:dont_tap_rogue_op/theme/app_theme.dart';

class GameplayScreen extends StatefulWidget {
  const GameplayScreen({super.key});

  @override
  State<GameplayScreen> createState() => _GameplayScreenState();
}

class _GameplayScreenState extends State<GameplayScreen> {
  late final ProtocolGame _game;

  @override
  void initState() {
    super.initState();
    _game = ProtocolGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.systemVoid,
      body: GameWidget<ProtocolGame>(
        game: _game,
        overlayBuilderMap: {
          'PauseMenu': (context, game) => PauseOverlay(game: game),
          'GameOver': (context, game) => GameOverOverlay(game: game),
          'LevelComplete': (context, game) => LevelCompleteOverlay(game: game),
          'RankUp': (context, game) => RankUpOverlay(
                game: game,
                newRank: game.currentRankDef,
              ),
        },
      ),
    );
  }
}
