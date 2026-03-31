import 'dart:ui';

import 'package:flame/game.dart';
import 'package:flame/effects.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dont_tap_rogue_op/game/components/ammo_display.dart';
import 'package:dont_tap_rogue_op/game/components/anomaly_base.dart';
import 'package:dont_tap_rogue_op/game/components/attack_pulse.dart';
import 'package:dont_tap_rogue_op/game/components/background_grid.dart';
import 'package:dont_tap_rogue_op/game/components/countdown_display.dart';
import 'package:dont_tap_rogue_op/game/components/decoy_threat.dart';
import 'package:dont_tap_rogue_op/game/components/focus_node.dart';
import 'package:dont_tap_rogue_op/game/components/level_badge.dart';
import 'package:dont_tap_rogue_op/game/components/pause_button.dart';
import 'package:dont_tap_rogue_op/game/components/penalty_vfx.dart';
import 'package:dont_tap_rogue_op/game/components/reengage_prompt.dart';
import 'package:dont_tap_rogue_op/game/components/threat.dart';
import 'package:dont_tap_rogue_op/game/components/threat_impact_vfx.dart';
import 'package:dont_tap_rogue_op/game/components/rank_modifiers/signal_drift_modifier.dart';
import 'package:dont_tap_rogue_op/game/components/rank_modifiers/phantom_touch_modifier.dart';
import 'package:dont_tap_rogue_op/game/components/rank_modifiers/screen_corruption_modifier.dart';
import 'package:dont_tap_rogue_op/game/components/rank_modifiers/mimic_protocol_modifier.dart';
import 'package:dont_tap_rogue_op/game/components/rank_modifiers/countdown_glitch_modifier.dart';
import 'package:dont_tap_rogue_op/game/components/rank_modifiers/system_override_modifier.dart';
import 'package:dont_tap_rogue_op/game/managers/level_config.dart';
import 'package:dont_tap_rogue_op/game/managers/level_manager.dart';
import 'package:dont_tap_rogue_op/game/managers/rank_config.dart';
import 'package:dont_tap_rogue_op/game/managers/threat_manager.dart';

enum GameState { waiting, active, suspended, breached, survived }

class ProtocolGame extends FlameGame {
  int currentLevel;

  ProtocolGame({this.currentLevel = 1});

  GameState _state = GameState.waiting;
  GameState get state => _state;

  String _breachReason = '';
  String get breachReason => _breachReason;

  late LevelConfig _levelConfig;
  late FocusNode _focusNode;
  late CountdownDisplay _countdownDisplay;
  late PauseButton _pauseButton;
  late AmmoDisplay _ammoDisplay;
  late LevelBadge _levelBadge;
  late BackgroundGrid _backgroundGrid;
  LevelManager? _levelManager;
  ThreatManager? _threatManager;
  ReengagePrompt? _reengagePrompt;

  double _timeRemaining = 0;
  bool _soundEnabled = true;
  bool _hapticsEnabled = true;

  bool _awaitingReengage = false;
  double _reengageCountdown = 0;
  bool _reengageCounting = false;

  double _screenFlashAlpha = 0;
  Color _screenFlashColor = const Color(0xFF00F0FF);

  int _pulseCharges = 0;
  int get pulseCharges => _pulseCharges;

  int _missCount = 0;
  double get _corruptionMultiplier => 1.0 + _missCount * 0.3;

  // Rank system state
  int _playerRank = 1;
  int _highestSequence = 0;
  RankDefinition get currentRankDef => RankConfig.getRankForSequence(_highestSequence);

  // Rank modifier components
  SignalDriftModifier? _signalDrift;
  PhantomTouchModifier? _phantomTouch;
  ScreenCorruptionModifier? _screenCorruption;
  MimicProtocolModifier? _mimicProtocol;
  CountdownGlitchModifier? _countdownGlitch;
  SystemOverrideModifier? _systemOverride;

  PhantomTouchModifier? get phantomTouchModifier => _phantomTouch;
  CountdownGlitchModifier? get countdownGlitchModifier => _countdownGlitch;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await _loadSettings();

    _levelConfig = LevelConfig.forLevel(currentLevel);
    _timeRemaining = _levelConfig.duration;
    _pulseCharges = _levelConfig.maxPulseCharges;

    _backgroundGrid = BackgroundGrid();
    _focusNode = FocusNode();
    _countdownDisplay = CountdownDisplay();
    _pauseButton = PauseButton();
    _ammoDisplay = AmmoDisplay();
    _levelBadge = LevelBadge();

    add(_backgroundGrid);
    add(_focusNode);
    add(_countdownDisplay);
    add(_pauseButton);
    add(_ammoDisplay);
    add(_levelBadge);

    _countdownDisplay.updateTime(_timeRemaining);
    _ammoDisplay.updateCharges(_pulseCharges, _levelConfig.maxPulseCharges);
    _levelBadge.updateLevel(currentLevel);
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _soundEnabled = prefs.getBool('sound_enabled') ?? true;
    _hapticsEnabled = prefs.getBool('haptics_enabled') ?? true;
    _highestSequence = prefs.getInt('highest_sequence') ?? 0;
    _playerRank = RankConfig.getRankForSequence(_highestSequence).rank;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_screenFlashAlpha > 0) {
      _screenFlashAlpha = (_screenFlashAlpha - dt * 12).clamp(0.0, 1.0);
    }

    if (_reengageCounting) {
      _reengageCountdown -= dt;
      final secs = _reengageCountdown.ceil();
      _reengagePrompt?.showCountdown(secs);
      if (_reengageCountdown <= 0) {
        _reengageCounting = false;
        _awaitingReengage = false;
        _reengagePrompt?.removeFromParent();
        _reengagePrompt = null;
        _state = GameState.active;
        _levelManager?.startSpawning();
        _threatManager?.startSpawning();
      }
      return;
    }

    if (_state != GameState.active) return;

    _timeRemaining -= dt * _corruptionMultiplier;
    _countdownDisplay.updateTime(_timeRemaining);

    if (_timeRemaining <= 0) {
      _onSurvived();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (_screenFlashAlpha > 0) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.x, size.y),
        Paint()
          ..color = _screenFlashColor.withValues(
            alpha: 0.16 * _screenFlashAlpha,
          ),
      );
    }
  }

  // --- Focus Node Callbacks ---

  void onFocusNodeHeld() {
    if (_state == GameState.breached || _state == GameState.survived) return;

    if (_hapticsEnabled) {
      HapticFeedback.lightImpact();
    }

    if (_awaitingReengage) {
      _startReengageCountdown();
      return;
    }

    if (_state == GameState.waiting) {
      _startSequence();
    }
  }

  void onFocusNodeReleased() {
    if (_state == GameState.active) {
      _onBreach('PREMATURE NODE RELEASE');
    }

    if (_reengageCounting) {
      _reengageCounting = false;
      _reengagePrompt?.showPrompt();
      _awaitingReengage = true;
    }
  }

  // --- Swipe Attack ---

  void onSwipeAttack(ThreatDirection direction) {
    if (_state != GameState.active) return;
    if (_pulseCharges <= 0) return;

    _pulseCharges--;
    _ammoDisplay.updateCharges(_pulseCharges, _levelConfig.maxPulseCharges);

    final focusNodePos = Vector2(size.x / 2, size.y * 0.75);
    final pulse = AttackPulse(origin: focusNodePos, direction: direction);
    add(pulse);
  }

  // --- Threat Callbacks ---

  void onThreatReachedNode(Threat threat) {
    if (_state != GameState.active) return;

    threat.removeFromParent();

    _missCount++;

    _timeRemaining -= _levelConfig.threatTimePenalty;
    _countdownDisplay.updateTime(_timeRemaining);

    _screenFlashColor = const Color(0xFFFF003C);
    _screenFlashAlpha = 1.0;

    _shakeCamera();

    if (_hapticsEnabled) {
      HapticFeedback.mediumImpact();
    }

    if (_timeRemaining <= 0) {
      _onBreach('THREAT IMPACT -- SYSTEM DESTABILIZED');
    }
  }

  void onThreatDestroyed(Threat threat) {
    if (_state != GameState.active) return;

    final impactPos = threat.position.clone();
    threat.removeFromParent();

    add(ThreatImpactVfx(impactPosition: impactPos));

    _screenFlashColor = const Color(0xFF00F0FF);
    _screenFlashAlpha = 1.0;

    if (_pulseCharges < _levelConfig.maxPulseCharges) {
      _pulseCharges++;
      _ammoDisplay.updateCharges(_pulseCharges, _levelConfig.maxPulseCharges);
    }

    if (_hapticsEnabled) {
      HapticFeedback.lightImpact();
    }

    if (_soundEnabled) {
      FlameAudio.play('bait.wav');
    }
  }

  // --- Decoy Callback ---

  void onDecoyShot(DecoyThreat decoy) {
    if (_state != GameState.active) return;

    final impactPos = decoy.position.clone();
    decoy.removeFromParent();

    add(PenaltyVfx(impactPosition: impactPos));

    _missCount += 2;

    _timeRemaining -= _levelConfig.decoyPenalty;
    _countdownDisplay.updateTime(_timeRemaining);

    _screenFlashColor = const Color(0xFFFF003C);
    _screenFlashAlpha = 1.0;

    _shakeCamera();

    if (_hapticsEnabled) {
      HapticFeedback.heavyImpact();
    }

    if (_timeRemaining <= 0) {
      _onBreach('VIRUS DETONATED -- CRITICAL FAILURE');
    }
  }

  // --- Anomaly Callback ---

  void onAnomalyTapped() {
    if (_state == GameState.active || _state == GameState.waiting) {
      _onBreach('UNAUTHORIZED INPUT DETECTED');
    }
  }

  void onAnomalySpawned() {
    if (_soundEnabled) {
      FlameAudio.play('bait.wav');
    }
  }

  // --- Pause Callbacks ---

  void onPauseTapped() {
    if (_state != GameState.active && _state != GameState.waiting) return;
    _suspend();
  }

  void onResumeRequested() {
    overlays.remove('PauseMenu');
    _awaitingReengage = true;

    _reengagePrompt = ReengagePrompt();
    add(_reengagePrompt!);

    resumeEngine();
  }

  void onAbortRequested() {
    overlays.remove('PauseMenu');
    _stopBgAudio();
    resumeEngine();
  }

  // --- Overlay Callbacks ---

  void restartLevel() {
    overlays.remove('GameOver');
    _resetForLevel(currentLevel);
  }

  void nextLevel() {
    overlays.remove('LevelComplete');
    currentLevel++;
    _resetForLevel(currentLevel);
  }

  void dismissRankUp() {
    overlays.remove('RankUp');
    overlays.add('LevelComplete');
  }

  void returnToTerminal() {
    _stopBgAudio();
    overlays.remove('PauseMenu');
    overlays.remove('GameOver');
    overlays.remove('LevelComplete');
    overlays.remove('RankUp');
    resumeEngine();
  }

  // --- Private State Transitions ---

  void _startSequence() {
    _state = GameState.active;

    _levelManager = LevelManager(config: _levelConfig);
    add(_levelManager!);
    _levelManager!.startSpawning();

    if (_levelConfig.threatEnabled) {
      _threatManager = ThreatManager(config: _levelConfig);
      add(_threatManager!);
      _threatManager!.startSpawning();
    }

    _activateRankModifiers();
    _startBgAudio();
  }

  void _activateRankModifiers() {
    if (_playerRank >= 2) {
      _signalDrift = SignalDriftModifier();
      add(_signalDrift!);
    }
    if (_playerRank >= 3) {
      _phantomTouch = PhantomTouchModifier();
      add(_phantomTouch!);
    }
    if (_playerRank >= 4) {
      _screenCorruption = ScreenCorruptionModifier();
      add(_screenCorruption!);
    }
    if (_playerRank >= 5) {
      _mimicProtocol = MimicProtocolModifier();
      add(_mimicProtocol!);
    }
    if (_playerRank >= 6) {
      _countdownGlitch = CountdownGlitchModifier();
      add(_countdownGlitch!);
    }
    if (_playerRank >= 7) {
      _systemOverride = SystemOverrideModifier();
      add(_systemOverride!);
    }
  }

  void _deactivateRankModifiers() {
    _signalDrift?.removeFromParent();
    _signalDrift = null;
    _phantomTouch?.removeFromParent();
    _phantomTouch = null;
    _screenCorruption?.removeFromParent();
    _screenCorruption = null;
    _mimicProtocol?.removeFromParent();
    _mimicProtocol = null;
    _countdownGlitch?.removeFromParent();
    _countdownGlitch = null;
    _systemOverride?.removeFromParent();
    _systemOverride = null;
  }

  void _onBreach(String reason) {
    if (_state == GameState.breached) return;
    _state = GameState.breached;
    _breachReason = reason;

    _levelManager?.stopSpawning();
    _threatManager?.stopSpawning();
    _deactivateRankModifiers();
    _stopBgAudio();

    if (_soundEnabled) {
      FlameAudio.play('error.flac');
    }
    if (_hapticsEnabled) {
      HapticFeedback.heavyImpact();
    }

    _shakeCamera();

    pauseEngine();
    overlays.add('GameOver');
  }

  void _onSurvived() {
    _state = GameState.survived;

    _levelManager?.stopSpawning();
    _threatManager?.stopSpawning();
    _deactivateRankModifiers();
    _stopBgAudio();

    _persistScore();

    final oldRank = _playerRank;
    _highestSequence = _highestSequence < currentLevel ? currentLevel : _highestSequence;
    final newRankDef = RankConfig.getRankForSequence(_highestSequence);

    pauseEngine();

    if (newRankDef.rank > oldRank) {
      _playerRank = newRankDef.rank;
      overlays.add('RankUp');
    } else {
      overlays.add('LevelComplete');
    }
  }

  void _suspend() {
    _state = GameState.suspended;
    _levelManager?.stopSpawning();
    _threatManager?.stopSpawning();
    pauseEngine();
    overlays.add('PauseMenu');
  }

  void _startReengageCountdown() {
    _reengageCountdown = 3.0;
    _reengageCounting = true;
    _reengagePrompt?.showCountdown(3);
  }

  void _resetForLevel(int level) {
    children.whereType<AnomalyBase>().toList().forEach((a) => a.removeFromParent());
    children.whereType<Threat>().toList().forEach((t) => t.removeFromParent());
    children.whereType<DecoyThreat>().toList().forEach((d) => d.removeFromParent());
    children.whereType<AttackPulse>().toList().forEach((p) => p.removeFromParent());
    children.whereType<ThreatImpactVfx>().toList().forEach((v) => v.removeFromParent());
    children.whereType<PenaltyVfx>().toList().forEach((v) => v.removeFromParent());

    _levelManager?.removeFromParent();
    _levelManager = null;

    _threatManager?.removeFromParent();
    _threatManager = null;

    _deactivateRankModifiers();

    _reengagePrompt?.removeFromParent();
    _reengagePrompt = null;

    _levelConfig = LevelConfig.forLevel(level);
    _timeRemaining = _levelConfig.duration;
    _pulseCharges = _levelConfig.maxPulseCharges;
    _missCount = 0;
    _countdownDisplay.updateTime(_timeRemaining);
    _ammoDisplay.updateCharges(_pulseCharges, _levelConfig.maxPulseCharges);
    _levelBadge.updateLevel(level);
    _focusNode.resetState();

    _state = GameState.waiting;
    _breachReason = '';
    _awaitingReengage = false;
    _reengageCounting = false;
    _screenFlashAlpha = 0;

    resumeEngine();
  }

  // --- Camera Shake ---

  void _shakeCamera() {
    camera.viewfinder.add(
      MoveByEffect(
        Vector2(6, 3),
        EffectController(
          duration: 0.05,
          reverseDuration: 0.05,
          repeatCount: 3,
        ),
      ),
    );
  }

  // --- Audio ---

  void _startBgAudio() {
    if (_soundEnabled) {
      FlameAudio.bgm.play('bg.m4a');
    }
  }

  void _stopBgAudio() {
    FlameAudio.bgm.stop();
  }

  // --- Score Persistence ---

  Future<void> _persistScore() async {
    final prefs = await SharedPreferences.getInstance();
    final currentHighest = prefs.getInt('highest_sequence') ?? 0;
    if (currentLevel > currentHighest) {
      await prefs.setInt('highest_sequence', currentLevel);
    }

    final currentTotal = prefs.getInt('total_time_endured') ?? 0;
    await prefs.setInt(
      'total_time_endured',
      currentTotal + _levelConfig.duration.floor(),
    );
  }

  // --- Lifecycle ---

  @override
  void lifecycleStateChange(AppLifecycleState state) {
    super.lifecycleStateChange(state);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      if (_state == GameState.active) {
        _suspend();
      }
    }
  }
}
