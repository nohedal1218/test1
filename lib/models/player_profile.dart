class PlayerProfile {
  const PlayerProfile({
    required this.name,
    required this.majorId,
    this.experience = 0,
    this.credits = 0,
    this.totalStudiedWords = 0,
    this.learnedWordIds = const <String>[],
  });

  final String name;
  final String majorId;
  final int experience;
  final int credits;
  final int totalStudiedWords;
  final List<String> learnedWordIds;

  int get level => (experience ~/ 100) + 1;

  int get maxHp => 100 + ((level - 1) * 10);

  int get attack => 20 + ((level - 1) * 2);

  int get experienceInCurrentLevel => experience % 100;

  PlayerProfile copyWith({
    String? name,
    String? majorId,
    int? experience,
    int? credits,
    int? totalStudiedWords,
    List<String>? learnedWordIds,
  }) {
    return PlayerProfile(
      name: name ?? this.name,
      majorId: majorId ?? this.majorId,
      experience: experience ?? this.experience,
      credits: credits ?? this.credits,
      totalStudiedWords: totalStudiedWords ?? this.totalStudiedWords,
      learnedWordIds: learnedWordIds ?? this.learnedWordIds,
    );
  }

  Map<String, Object> toJson() {
    return <String, Object>{
      'name': name,
      'majorId': majorId,
      'experience': experience,
      'credits': credits,
      'totalStudiedWords': totalStudiedWords,
      'learnedWordIds': learnedWordIds,
    };
  }

  factory PlayerProfile.fromJson(Map<String, dynamic> json) {
    final name = json['name'];
    final majorId = json['majorId'];
    final experience = json['experience'];
    final credits = json['credits'];
    final learnedWordIds = json['learnedWordIds'];
    final totalStudiedWords = json['totalStudiedWords'];

    if (name is! String || majorId is! String) {
      throw const FormatException('저장된 사용자 정보가 올바르지 않습니다.');
    }

    return PlayerProfile(
      name: name,
      majorId: majorId,
      experience: experience is int ? experience : 0,
      credits: credits is int ? credits : 0,
      totalStudiedWords: totalStudiedWords is int ? totalStudiedWords : 0,
      learnedWordIds: learnedWordIds is List
          ? learnedWordIds.whereType<String>().toSet().toList()
          : const <String>[],
    );
  }
}
