class RankDefinition {
  const RankDefinition({
    required this.rank,
    required this.title,
    required this.requiredSequence,
    required this.modifierName,
    required this.modifierDescription,
  });

  final int rank;
  final String title;
  final int requiredSequence;
  final String modifierName;
  final String modifierDescription;
}

abstract final class RankConfig {
  static const List<RankDefinition> ranks = [
    RankDefinition(
      rank: 1,
      title: 'TRAINEE OPERATOR',
      requiredSequence: 0,
      modifierName: '',
      modifierDescription: 'Basic system access granted.',
    ),
    RankDefinition(
      rank: 2,
      title: 'SIGNAL TECH',
      requiredSequence: 5,
      modifierName: 'SIGNAL DRIFT',
      modifierDescription: 'Anomalies change direction mid-flight.',
    ),
    RankDefinition(
      rank: 3,
      title: 'NODE WARDEN',
      requiredSequence: 10,
      modifierName: 'PHANTOM TOUCH',
      modifierDescription: 'Focus Node border flickers erratically.',
    ),
    RankDefinition(
      rank: 4,
      title: 'STATIC ANALYST',
      requiredSequence: 15,
      modifierName: 'SCREEN CORRUPTION',
      modifierDescription: 'Brief visual static obscures the display.',
    ),
    RankDefinition(
      rank: 5,
      title: 'BREACH HANDLER',
      requiredSequence: 20,
      modifierName: 'MIMIC PROTOCOL',
      modifierDescription: 'A decoy mimics the Focus Node.',
    ),
    RankDefinition(
      rank: 6,
      title: 'SYSTEMS ENGINEER',
      requiredSequence: 25,
      modifierName: 'COUNTDOWN GLITCH',
      modifierDescription: 'Timer display briefly shows false data.',
    ),
    RankDefinition(
      rank: 7,
      title: 'PROTOCOL OVERSEER',
      requiredSequence: 30,
      modifierName: 'SYSTEM OVERRIDE',
      modifierDescription: 'Fake system overlays attempt to deceive.',
    ),
    RankDefinition(
      rank: 8,
      title: 'SYSTEM ARCHITECT',
      requiredSequence: 40,
      modifierName: 'FULL SPECTRUM',
      modifierDescription: 'All modifiers active. Maximum deception.',
    ),
  ];

  static RankDefinition getRankForSequence(int highestSequence) {
    RankDefinition current = ranks.first;
    for (final r in ranks) {
      if (highestSequence >= r.requiredSequence) {
        current = r;
      } else {
        break;
      }
    }
    return current;
  }

  static RankDefinition? getNextRank(int highestSequence) {
    for (final r in ranks) {
      if (highestSequence < r.requiredSequence) {
        return r;
      }
    }
    return null;
  }

  static double getProgressToNextRank(int highestSequence) {
    final current = getRankForSequence(highestSequence);
    final next = getNextRank(highestSequence);
    if (next == null) return 1.0;

    final rangeStart = current.requiredSequence;
    final rangeEnd = next.requiredSequence;
    final range = rangeEnd - rangeStart;
    if (range <= 0) return 1.0;

    return ((highestSequence - rangeStart) / range).clamp(0.0, 1.0);
  }
}
