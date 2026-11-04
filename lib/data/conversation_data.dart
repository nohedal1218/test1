class ConversationChoice {
  const ConversationChoice({
    required this.english,
    required this.korean,
    required this.reply,
  });

  final String english;
  final String korean;
  final String reply;
}

class ConversationTurn {
  const ConversationTurn({
    required this.englishQuestion,
    required this.koreanQuestion,
    required this.choices,
  });

  final String englishQuestion;
  final String koreanQuestion;
  final List<ConversationChoice> choices;
}

const Map<String, List<ConversationTurn>> conversationByMajor =
    <String, List<ConversationTurn>>{
  'electrical': <ConversationTurn>[
    ConversationTurn(
      englishQuestion: 'Have you studied circuits today?',
      koreanQuestion: '오늘 회로를 공부했어?',
      choices: <ConversationChoice>[
        ConversationChoice(
          english: 'Yes, I have.',
          korean: '응, 공부했어.',
          reply: '좋아! Circuit은 회로라는 뜻이야. 오늘도 하나 배웠네!',
        ),
        ConversationChoice(
          english: 'Not yet.',
          korean: '아직 안 했어.',
          reply: '괜찮아. 훈련에서 전기·전자 단어를 같이 익혀보자!',
        ),
      ],
    ),
    ConversationTurn(
      englishQuestion: 'Do you like electronics?',
      koreanQuestion: '전자 분야가 좋아?',
      choices: <ConversationChoice>[
        ConversationChoice(
          english: 'Yes, I do.',
          korean: '응, 좋아해.',
          reply: '멋져! 관심 있는 분야부터 배우면 더 재미있을 거야.',
        ),
        ConversationChoice(
          english: 'I am still learning.',
          korean: '아직 배우는 중이야.',
          reply: '천천히 해도 괜찮아. 내가 옆에서 도와줄게!',
        ),
      ],
    ),
  ],
  'information': <ConversationTurn>[
    ConversationTurn(
      englishQuestion: 'Did you use a computer today?',
      koreanQuestion: '오늘 컴퓨터를 사용했어?',
      choices: <ConversationChoice>[
        ConversationChoice(
          english: 'Yes, I did.',
          korean: '응, 사용했어.',
          reply: '좋아! Network는 네트워크라는 뜻이야. 정보통신 단어도 익혀보자!',
        ),
        ConversationChoice(
          english: 'Not today.',
          korean: '오늘은 아니야.',
          reply: '그렇구나. 다음 훈련에서 컴퓨터 관련 단어를 만나보자!',
        ),
      ],
    ),
    ConversationTurn(
      englishQuestion: 'Do you enjoy coding?',
      koreanQuestion: '코딩하는 게 재미있어?',
      choices: <ConversationChoice>[
        ConversationChoice(
          english: 'It is fun!',
          korean: '재미있어!',
          reply: '좋아! 작은 코드부터 하나씩 완성해 보자.',
        ),
        ConversationChoice(
          english: 'It is difficult.',
          korean: '어려워.',
          reply: '처음엔 어려울 수 있어. 반복하면 분명 익숙해질 거야.',
        ),
      ],
    ),
  ],
  'mechanical': <ConversationTurn>[
    ConversationTurn(
      englishQuestion: 'Did you work with a motor today?',
      koreanQuestion: '오늘 모터를 다뤄봤어?',
      choices: <ConversationChoice>[
        ConversationChoice(
          english: 'Yes, I did.',
          korean: '응, 해봤어.',
          reply: '좋아! Motor는 모터야. 오늘 기계 단어도 하나 익혔어!',
        ),
        ConversationChoice(
          english: 'Not yet.',
          korean: '아직 안 해봤어.',
          reply: '괜찮아. 훈련에서 기계 관련 단어를 만나보자!',
        ),
      ],
    ),
    ConversationTurn(
      englishQuestion: 'Do you like machines?',
      koreanQuestion: '기계를 좋아해?',
      choices: <ConversationChoice>[
        ConversationChoice(
          english: 'Yes, I do.',
          korean: '응, 좋아해.',
          reply: '멋져! 여러 기계의 이름을 영어로도 알아보자.',
        ),
        ConversationChoice(
          english: 'I am not sure.',
          korean: '아직 잘 모르겠어.',
          reply: '괜찮아. 여러 실습을 하다 보면 좋아하는 걸 찾을 수 있어.',
        ),
      ],
    ),
  ],
  'cooking': <ConversationTurn>[
    ConversationTurn(
      englishQuestion: 'What did you cook today?',
      koreanQuestion: '오늘은 어떤 요리를 했어?',
      choices: <ConversationChoice>[
        ConversationChoice(
          english: 'I made pasta.',
          korean: '파스타를 만들었어.',
          reply: '맛있겠다! Recipe는 조리법이라는 뜻이야. 요리 단어도 익혀보자!',
        ),
        ConversationChoice(
          english: 'I did not cook.',
          korean: '요리하지 않았어.',
          reply: '그렇구나. 다음에는 요리 재료를 영어로 배워보자!',
        ),
      ],
    ),
    ConversationTurn(
      englishQuestion: 'Do you enjoy cooking?',
      koreanQuestion: '요리하는 걸 좋아해?',
      choices: <ConversationChoice>[
        ConversationChoice(
          english: 'Yes, a lot.',
          korean: '응, 정말 좋아해.',
          reply: '좋아! 네가 좋아하는 요리부터 영어로 알아가자.',
        ),
        ConversationChoice(
          english: 'Sometimes.',
          korean: '가끔 좋아해.',
          reply: '좋아. 부담 없이 조금씩 배워보자!',
        ),
      ],
    ),
  ],
  'beauty': <ConversationTurn>[
    ConversationTurn(
      englishQuestion: 'Did you try a new style today?',
      koreanQuestion: '오늘 새로운 스타일을 시도해 봤어?',
      choices: <ConversationChoice>[
        ConversationChoice(
          english: 'Yes, I did.',
          korean: '응, 해봤어.',
          reply: '멋져! Style은 스타일이라는 뜻이야. 미용 단어도 익혀보자!',
        ),
        ConversationChoice(
          english: 'Not today.',
          korean: '오늘은 아니야.',
          reply: '괜찮아. 다음 훈련에서 미용 관련 단어를 배워보자!',
        ),
      ],
    ),
    ConversationTurn(
      englishQuestion: 'Do you like hair design?',
      koreanQuestion: '헤어 디자인을 좋아해?',
      choices: <ConversationChoice>[
        ConversationChoice(
          english: 'Yes, I love it.',
          korean: '응, 정말 좋아해.',
          reply: '좋아! 관심 있는 표현부터 하나씩 익히면 돼.',
        ),
        ConversationChoice(
          english: 'I want to learn.',
          korean: '배우고 싶어.',
          reply: '좋아. 내가 학습을 도와줄게!',
        ),
      ],
    ),
  ],
};

List<ConversationTurn> conversationForMajor(String majorId) {
  return conversationByMajor[majorId] ?? conversationByMajor['electrical']!;
}
