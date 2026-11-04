class BattleReward {
  const BattleReward({
    required this.isVictory,
    required this.experience,
    required this.credits,
    required this.studiedWordCount,
    required this.learnedWordIds,
  });

  final bool isVictory;
  final int experience;
  final int credits;
  final int studiedWordCount;
  final List<String> learnedWordIds;
}
