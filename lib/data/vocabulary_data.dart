class VocabularyWord {
  const VocabularyWord({
    required this.id,
    required this.english,
    required this.meaning,
  });

  final String id;
  final String english;
  final String meaning;
}

class LearningPack {
  const LearningPack({
    required this.words,
    required this.sentenceMeaning,
    required this.correctWords,
    required this.shuffledWords,
  });

  final List<VocabularyWord> words;
  final String sentenceMeaning;
  final List<String> correctWords;
  final List<String> shuffledWords;
}

const Map<String, LearningPack> learningPacks = <String, LearningPack>{
  'electrical': LearningPack(
    words: <VocabularyWord>[
      VocabularyWord(id: 'electrical_voltage', english: 'Voltage', meaning: '전압'),
      VocabularyWord(id: 'electrical_current', english: 'Current', meaning: '전류'),
      VocabularyWord(id: 'electrical_circuit', english: 'Circuit', meaning: '회로'),
      VocabularyWord(id: 'electrical_resistance', english: 'Resistance', meaning: '저항'),
      VocabularyWord(id: 'electrical_power', english: 'Power', meaning: '전력'),
    ],
    sentenceMeaning: '나는 전기를 공부한다.',
    correctWords: <String>['I', 'study', 'electricity.'],
    shuffledWords: <String>['electricity.', 'I', 'study'],
  ),
  'information': LearningPack(
    words: <VocabularyWord>[
      VocabularyWord(id: 'information_network', english: 'Network', meaning: '네트워크'),
      VocabularyWord(id: 'information_signal', english: 'Signal', meaning: '신호'),
      VocabularyWord(id: 'information_server', english: 'Server', meaning: '서버'),
      VocabularyWord(id: 'information_data', english: 'Data', meaning: '데이터'),
      VocabularyWord(id: 'information_program', english: 'Program', meaning: '프로그램'),
    ],
    sentenceMeaning: '나는 컴퓨터를 사용한다.',
    correctWords: <String>['I', 'use', 'a', 'computer.'],
    shuffledWords: <String>['computer.', 'I', 'a', 'use'],
  ),
  'mechanical': LearningPack(
    words: <VocabularyWord>[
      VocabularyWord(id: 'mechanical_engine', english: 'Engine', meaning: '엔진'),
      VocabularyWord(id: 'mechanical_motor', english: 'Motor', meaning: '모터'),
      VocabularyWord(id: 'mechanical_gear', english: 'Gear', meaning: '기어'),
      VocabularyWord(id: 'mechanical_machine', english: 'Machine', meaning: '기계'),
      VocabularyWord(id: 'mechanical_bearing', english: 'Bearing', meaning: '베어링'),
    ],
    sentenceMeaning: '나는 엔진을 수리한다.',
    correctWords: <String>['I', 'repair', 'the', 'engine.'],
    shuffledWords: <String>['engine.', 'the', 'I', 'repair'],
  ),
  'cooking': LearningPack(
    words: <VocabularyWord>[
      VocabularyWord(id: 'cooking_recipe', english: 'Recipe', meaning: '조리법'),
      VocabularyWord(id: 'cooking_ingredient', english: 'Ingredient', meaning: '재료'),
      VocabularyWord(id: 'cooking_kitchen', english: 'Kitchen', meaning: '주방'),
      VocabularyWord(id: 'cooking_knife', english: 'Knife', meaning: '칼'),
      VocabularyWord(id: 'cooking_flavor', english: 'Flavor', meaning: '맛'),
    ],
    sentenceMeaning: '나는 식사를 준비한다.',
    correctWords: <String>['I', 'prepare', 'a', 'meal.'],
    shuffledWords: <String>['meal.', 'a', 'I', 'prepare'],
  ),
  'beauty': LearningPack(
    words: <VocabularyWord>[
      VocabularyWord(id: 'beauty_shampoo', english: 'Shampoo', meaning: '샴푸'),
      VocabularyWord(id: 'beauty_skin', english: 'Skin', meaning: '피부'),
      VocabularyWord(id: 'beauty_style', english: 'Style', meaning: '스타일'),
      VocabularyWord(id: 'beauty_hair', english: 'Hair', meaning: '머리카락'),
      VocabularyWord(id: 'beauty_brush', english: 'Brush', meaning: '브러시'),
    ],
    sentenceMeaning: '나는 머리를 손질한다.',
    correctWords: <String>['I', 'style', 'hair.'],
    shuffledWords: <String>['hair.', 'I', 'style'],
  ),
};

LearningPack learningPackForMajor(String majorId) {
  return learningPacks[majorId] ?? learningPacks['electrical']!;
}
