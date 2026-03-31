enum AnomalyType { staticNoise, urgencyTrap }

class LevelConfig {
  const LevelConfig({
    required this.level,
    required this.duration,
    required this.spawnInterval,
    required this.anomalySpeed,
    required this.allowedAnomalies,
    this.threatEnabled = false,
    this.threatSpeed = 0,
    this.threatSpawnInterval = 0,
    this.maxSimultaneousThreats = 0,
    this.threatTimePenalty = 2.0,
    this.maxPulseCharges = 5,
    this.decoyChance = 0.0,
    this.decoyPenalty = 3.0,
  });

  final int level;
  final double duration;
  final double spawnInterval;
  final double anomalySpeed;
  final List<AnomalyType> allowedAnomalies;

  final bool threatEnabled;
  final double threatSpeed;
  final double threatSpawnInterval;
  final int maxSimultaneousThreats;
  final double threatTimePenalty;
  final int maxPulseCharges;

  final double decoyChance;
  final double decoyPenalty;

  static LevelConfig forLevel(int level) {
    if (level <= 5) return _tier1(level);
    if (level <= 15) return _tier2(level);
    if (level <= 25) return _tier3(level);
    return _tier4(level);
  }

  static LevelConfig _tier1(int level) {
    final urgency = level >= 3;
    return LevelConfig(
      level: level,
      duration: 18.0 + (level - 1) * 2,
      spawnInterval: 2.5 - (level - 1) * 0.2,
      anomalySpeed: 45.0 + (level - 1) * 8,
      allowedAnomalies: urgency
          ? const [AnomalyType.staticNoise, AnomalyType.urgencyTrap]
          : const [AnomalyType.staticNoise],
      threatEnabled: true,
      threatSpeed: 65.0 + (level - 1) * 12,
      threatSpawnInterval: 6.0 - (level - 1) * 0.4,
      maxSimultaneousThreats: level >= 3 ? 2 : 1,
      threatTimePenalty: 2.0,
      maxPulseCharges: 6,
      decoyChance: level >= 4 ? 0.15 : 0.0,
      decoyPenalty: 3.0,
    );
  }

  static LevelConfig _tier2(int level) {
    final progress = (level - 6) / 9;
    return LevelConfig(
      level: level,
      duration: 25.0 + progress * 10,
      spawnInterval: 2.0 - progress * 0.6,
      anomalySpeed: 65.0 + progress * 45,
      allowedAnomalies: const [AnomalyType.staticNoise, AnomalyType.urgencyTrap],
      threatEnabled: true,
      threatSpeed: 130.0 + progress * 70,
      threatSpawnInterval: 4.5 - progress * 1.5,
      maxSimultaneousThreats: 2,
      threatTimePenalty: 2.5,
      maxPulseCharges: 5,
      decoyChance: 0.2 + progress * 0.1,
      decoyPenalty: 3.5,
    );
  }

  static LevelConfig _tier3(int level) {
    final progress = ((level - 16) / 9).clamp(0.0, 1.0);
    return LevelConfig(
      level: level,
      duration: 30.0 + progress * 15,
      spawnInterval: (1.4 - progress * 0.4).clamp(0.8, 1.4),
      anomalySpeed: 110.0 + progress * 60,
      allowedAnomalies: const [AnomalyType.staticNoise, AnomalyType.urgencyTrap],
      threatEnabled: true,
      threatSpeed: 200.0 + progress * 80,
      threatSpawnInterval: (3.0 - progress * 0.8).clamp(2.0, 3.0),
      maxSimultaneousThreats: 3,
      threatTimePenalty: 3.0,
      maxPulseCharges: 4,
      decoyChance: 0.25 + progress * 0.05,
      decoyPenalty: 4.0,
    );
  }

  static LevelConfig _tier4(int level) {
    final progress = ((level - 26) / 9).clamp(0.0, 1.0);
    return LevelConfig(
      level: level,
      duration: 40.0 + progress * 10,
      spawnInterval: (0.7 - progress * 0.15).clamp(0.5, 0.7),
      anomalySpeed: 150.0 + progress * 60,
      allowedAnomalies: const [AnomalyType.staticNoise, AnomalyType.urgencyTrap],
      threatEnabled: true,
      threatSpeed: 260.0 + progress * 80,
      threatSpawnInterval: (1.8 - progress * 0.4).clamp(1.2, 1.8),
      maxSimultaneousThreats: 4,
      threatTimePenalty: 3.5,
      maxPulseCharges: 3,
      decoyChance: 0.3,
      decoyPenalty: 5.0,
    );
  }
}
