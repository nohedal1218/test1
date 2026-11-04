import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../data/major_data.dart';
import '../data/vocabulary_data.dart';
import '../models/battle_reward.dart';
import '../models/player_profile.dart';
import '../theme/app_theme.dart';
import 'result_screen.dart';

enum BattlePhase { defense, attack }

class BattleScreen extends StatefulWidget {
  const BattleScreen({super.key, required this.profile});

  final PlayerProfile profile;

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> {
  final FlutterTts _tts = FlutterTts();

  late final LearningPack _pack;
  late final int _monsterLevel;
  late final int _monsterMaxHp;
  late final int _monsterAttack;
  late final List<VocabularyWord> _defenseWords;
  late final List<String?> _matches;

  late int _playerHp;
  late int _monsterHp;

  BattlePhase _phase = BattlePhase.defense;
  bool _ttsReady = false;
  bool _defenseResolved = false;
  bool _attackResolved = false;
  bool _isSpeaking = false;
  int _correctMatches = 0;
  int _attackAttempts = 0;
  int _pendingDamage = 0;
  int _round = 1;
  String _defenseFeedback = '';
  String _attackFeedback = '';
  List<String> _selectedWords = <String>[];
  BattleReward? _reward;

  int get _playerMaxHp => widget.profile.maxHp;
  int get _playerAttack => widget.profile.attack;

  @override
  void initState() {
    super.initState();
    _pack = learningPackForMajor(widget.profile.majorId);
    _monsterLevel = 1 + (widget.profile.totalStudiedWords ~/ 10);
    final wordsPerDefense = (3 + _monsterLevel - 1).clamp(3, 5).toInt();
    _defenseWords = _pack.words.take(wordsPerDefense).toList();
    _monsterMaxHp = 40 * _monsterLevel;
    _monsterAttack = 16 + ((_monsterLevel - 1) * 2);
    _playerHp = _playerMaxHp;
    _monsterHp = _monsterMaxHp;
    _matches = List<String?>.filled(_defenseWords.length, null);
    _prepareTts();
  }

  Future<void> _prepareTts() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.42);
      await _tts.awaitSpeakCompletion(true);
      if (mounted) setState(() => _ttsReady = true);
    } catch (_) {
      if (mounted) setState(() => _ttsReady = false);
    }
  }

  @override
  void dispose() {
    unawaited(_tts.stop().then<void>((_) {}));
    super.dispose();
  }

  Future<void> _speak(String word) async {
    if (!_ttsReady || _isSpeaking) {
      if (!_ttsReady && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('영어 발음을 준비하지 못했어요. 기기의 TTS 엔진을 확인해 주세요.'),
          ),
        );
      }
      return;
    }

    setState(() => _isSpeaking = true);
    try {
      await _tts.stop();
      await _tts.speak(word.replaceAll('.', ''));
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('발음 재생에 실패했어요: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSpeaking = false);
    }
  }

  void _submitDefense() {
    if (_matches.any((meaning) => meaning == null)) return;

    final correct = _defenseWords
        .asMap()
        .entries
        .where((entry) => _matches[entry.key] == entry.value.meaning)
        .length;

    setState(() {
      _correctMatches = correct;
      _defenseResolved = true;

      final matchRatio = correct / _defenseWords.length;
      if (correct == _defenseWords.length) {
        _monsterHp = (_monsterHp - _monsterAttack).clamp(0, _monsterMaxHp).toInt();
        _defenseFeedback =
            'COUNTER! 적의 공격을 되받아쳤어요. 적 HP -$_monsterAttack';
      } else if (matchRatio >= (2 / 3)) {
        _defenseFeedback = 'PARRY! 공격을 완벽하게 막았어요. 피해 0';
      } else if (matchRatio >= (1 / 3)) {
        final damage = (_monsterAttack / 2).ceil();
        _playerHp = (_playerHp - damage).clamp(0, _playerMaxHp).toInt();
        _defenseFeedback = 'BLOCK! 피해를 절반으로 줄였어요. 내 HP -$damage';
      } else {
        _playerHp = (_playerHp - _monsterAttack).clamp(0, _playerMaxHp).toInt();
        _defenseFeedback = 'DIRECT HIT! 공격을 그대로 맞았어요. 내 HP -$_monsterAttack';
      }
    });
  }

  void _continueAfterDefense() {
    if (_monsterHp <= 0) {
      _finishBattle(true);
      return;
    }
    if (_playerHp <= 0) {
      _finishBattle(false);
      return;
    }

    setState(() {
      _phase = BattlePhase.attack;
      _selectedWords = <String>[];
      _attackAttempts = 0;
      _attackResolved = false;
      _attackFeedback = '';
      _pendingDamage = 0;
    });
  }

  void _selectWord(String word) {
    if (_attackResolved || _selectedWords.contains(word)) return;
    setState(() => _selectedWords = <String>[..._selectedWords, word]);
    _speak(word);
  }

  void _removeSelectedWord(String word) {
    if (_attackResolved) return;
    setState(() => _selectedWords.remove(word));
  }

  void _submitAttack() {
    if (_selectedWords.length != _pack.correctWords.length) return;

    final isCorrect = _selectedWords.join(' ') == _pack.correctWords.join(' ');
    if (isCorrect) {
      setState(() {
        _pendingDamage = _playerAttack;
        _attackResolved = true;
        _attackFeedback = '정답! 정상 공격을 준비했어요. 공격력 $_pendingDamage';
      });
      return;
    }

    if (_attackAttempts == 0) {
      setState(() {
        _attackAttempts = 1;
        _selectedWords = <String>[];
        _attackFeedback = '문장 순서가 달라요. 한 번 더 도전해 보세요!';
      });
      return;
    }

    setState(() {
      _pendingDamage = (_playerAttack / 2).floor();
      _attackResolved = true;
      _attackFeedback = '두 번째 시도도 틀렸어요. 절반의 공격력으로 공격합니다.';
    });
  }

  void _applyPlayerAttack() {
    setState(() {
      _monsterHp = (_monsterHp - _pendingDamage).clamp(0, _monsterMaxHp).toInt();
    });

    if (_monsterHp <= 0) {
      _finishBattle(true);
      return;
    }

    setState(() {
      _round += 1;
      _phase = BattlePhase.defense;
      for (var index = 0; index < _matches.length; index++) {
        _matches[index] = null;
      }
      _defenseResolved = false;
      _defenseFeedback = '';
      _attackResolved = false;
      _attackFeedback = '';
      _selectedWords = <String>[];
      _attackAttempts = 0;
      _pendingDamage = 0;
    });
  }

  void _finishBattle(bool isVictory) {
    if (_reward != null) return;

    final newWordCount = _defenseWords
        .where((word) => !widget.profile.learnedWordIds.contains(word.id))
        .length;
    final gainedExperience = (isVictory ? 20 : 5) + (newWordCount * 5);
    final gainedCredits = isVictory ? 10 : 2;

    setState(() {
      _reward = BattleReward(
        isVictory: isVictory,
        experience: gainedExperience,
        credits: gainedCredits,
        studiedWordCount: _defenseWords.length,
        learnedWordIds: _defenseWords.map((word) => word.id).toList(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final reward = _reward;
    if (reward != null) {
      return ResultScreen(
        reward: reward,
        onReturnHome: () => Navigator.of(context).pop(reward),
      );
    }

    final major = majorById(widget.profile.majorId);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'TRAINING BATTLE',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
        ),
        leading: IconButton(
          tooltip: '훈련 나가기',
          icon: const Icon(Icons.close_rounded),
          onPressed: _confirmExit,
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 6, 18, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _BattleStatusPanel(
                    playerName: widget.profile.name,
                    playerLevel: widget.profile.level,
                    playerHp: _playerHp,
                    playerMaxHp: _playerMaxHp,
                    monsterLevel: _monsterLevel,
                    monsterHp: _monsterHp,
                    monsterMaxHp: _monsterMaxHp,
                  ),
                  const SizedBox(height: 14),
                  _ErrorSlimePanel(
                    round: _round,
                    phaseLabel: _phase == BattlePhase.defense
                        ? 'ENEMY TURN'
                        : 'PLAYER TURN',
                  ),
                  const SizedBox(height: 14),
                  if (_phase == BattlePhase.defense)
                    _buildDefensePanel(major.name)
                  else
                    _buildAttackPanel(major.name),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDefensePanel(String majorName) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const _PhaseLabel(
            label: 'DEFENSE PROTOCOL',
            color: AppColors.mintDeep,
          ),
          const SizedBox(height: 8),
          const Text(
            '영어 단어와 알맞은 뜻을 연결해 공격을 막아!',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            '$majorName 기초 단어 ${_defenseWords.length}개',
            style: const TextStyle(color: AppColors.muted, fontSize: 12),
          ),
          const SizedBox(height: 14),
          if (!_defenseResolved)
            ..._defenseWords.asMap().entries.map((entry) {
              final index = entry.key;
              final word = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          word.english,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 142,
                        child: DropdownButton<String>(
                          value: _matches[index],
                          isExpanded: true,
                          hint: const Text('뜻 선택', style: TextStyle(fontSize: 13)),
                          underline: const SizedBox.shrink(),
                          items: _defenseWords
                              .map(
                                (option) => DropdownMenuItem<String>(
                                  value: option.meaning,
                                  child: Text(
                                    option.meaning,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() => _matches[index] = value);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            })
          else
            _BattleFeedback(
              title: _correctMatches == _defenseWords.length
                  ? 'COUNTER!'
                  : (_correctMatches / _defenseWords.length) >= (2 / 3)
                      ? 'PARRY!'
                      : (_correctMatches / _defenseWords.length) >= (1 / 3)
                          ? 'BLOCK!'
                          : 'DIRECT HIT!',
              message: _defenseFeedback,
              accent: (_correctMatches / _defenseWords.length) >= (2 / 3)
                  ? AppColors.mintDeep
                  : (_correctMatches / _defenseWords.length) >= (1 / 3)
                      ? AppColors.warning
                      : AppColors.danger,
            ),
          const SizedBox(height: 10),
          if (!_defenseResolved)
            FilledButton(
              onPressed: _matches.every((meaning) => meaning != null)
                  ? _submitDefense
                  : null,
              child: const Text('방어 결과 확인'),
            )
          else
            FilledButton(
              onPressed: _continueAfterDefense,
              child: Text(
                _monsterHp <= 0
                    ? '전투 결과 확인'
                    : _playerHp <= 0
                        ? '전투 결과 확인'
                        : '내 차례로',
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAttackPanel(String majorName) {
    final availableWords = _pack.shuffledWords
        .where((word) => !_selectedWords.contains(word))
        .toList();

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const _PhaseLabel(label: 'COMMAND ASSEMBLY', color: AppColors.cyanDeep),
          const SizedBox(height: 8),
          const Text(
            '단어를 올바른 순서로 배열해 공격해!',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            '$majorName 표현을 완성해 봐. 단어의 스피커 버튼을 누르면 발음을 들을 수 있어.',
            style: const TextStyle(color: AppColors.muted, fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 13),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: AppColors.cyan.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  '한국어 뜻',
                  style: TextStyle(
                    color: AppColors.cyanDeep,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _pack.sentenceMeaning,
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            '완성할 문장',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
          ),
          const SizedBox(height: 7),
          Container(
            constraints: const BoxConstraints(minHeight: 58),
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.line),
            ),
            child: Wrap(
              spacing: 7,
              runSpacing: 7,
              children: _selectedWords.isEmpty
                  ? <Widget>[
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 9),
                        child: Text(
                          '아래 단어를 순서대로 선택해 줘.',
                          style: TextStyle(color: AppColors.muted, fontSize: 12),
                        ),
                      ),
                    ]
                  : _selectedWords
                      .map(
                        (word) => InputChip(
                          label: Text(word),
                          onDeleted: _attackResolved
                              ? null
                              : () => _removeSelectedWord(word),
                          backgroundColor: AppColors.cyan.withValues(alpha: 0.22),
                          side: BorderSide.none,
                        ),
                      )
                      .toList(),
            ),
          ),
          const SizedBox(height: 13),
          const Text(
            '선택할 단어',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
          ),
          const SizedBox(height: 7),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: availableWords
                .map(
                  (word) => ActionChip(
                    onPressed: _attackResolved ? null : () => _selectWord(word),
                    avatar: Icon(
                      Icons.volume_up_rounded,
                      size: 16,
                      color: AppColors.cyanDeep,
                    ),
                    label: Text(word),
                    backgroundColor: AppColors.surface,
                    side: const BorderSide(color: AppColors.line),
                    labelStyle: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 10),
          Text(
            '남은 기회: ${_attackResolved ? 0 : 2 - _attackAttempts}회',
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (_attackFeedback.isNotEmpty) ...<Widget>[
            const SizedBox(height: 10),
            _BattleFeedback(
              title: _attackResolved ? 'ATTACK RESULT' : 'TRY AGAIN',
              message: _attackFeedback,
              accent: _attackResolved ? AppColors.mintDeep : AppColors.warning,
            ),
          ],
          const SizedBox(height: 12),
          if (!_attackResolved)
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton(
                    onPressed: _selectedWords.isEmpty
                        ? null
                        : () => setState(() => _selectedWords = <String>[]),
                    child: const Text('초기화'),
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: _selectedWords.length == _pack.correctWords.length
                        ? _submitAttack
                        : null,
                    child: const Text('문장 제출'),
                  ),
                ),
              ],
            )
          else
            FilledButton(
              onPressed: _applyPlayerAttack,
              child: Text('공격 적용  ·  $_pendingDamage DAMAGE'),
            ),
        ],
      ),
    );
  }

  Future<void> _confirmExit() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('훈련을 종료할까요?'),
          content: const Text('이번 전투의 보상은 저장되지 않아요.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('계속하기'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('종료하기'),
            ),
          ],
        );
      },
    );

    if (!mounted || shouldExit != true) return;

    Navigator.of(context).pop();
  }
}

class _BattleStatusPanel extends StatelessWidget {
  const _BattleStatusPanel({
    required this.playerName,
    required this.playerLevel,
    required this.playerHp,
    required this.playerMaxHp,
    required this.monsterLevel,
    required this.monsterHp,
    required this.monsterMaxHp,
  });

  final String playerName;
  final int playerLevel;
  final int playerHp;
  final int playerMaxHp;
  final int monsterLevel;
  final int monsterHp;
  final int monsterMaxHp;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _HpCard(
            title: '$playerName  LV.$playerLevel',
            hp: playerHp,
            maxHp: playerMaxHp,
            color: AppColors.mintDeep,
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: _HpCard(
            title: 'ERROR SLIME  LV.$monsterLevel',
            hp: monsterHp,
            maxHp: monsterMaxHp,
            color: AppColors.danger,
          ),
        ),
      ],
    );
  }
}

class _HpCard extends StatelessWidget {
  const _HpCard({
    required this.title,
    required this.hp,
    required this.maxHp,
    required this.color,
  });

  final String title;
  final int hp;
  final int maxHp;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final ratio = maxHp == 0 ? 0.0 : (hp / maxHp).clamp(0.0, 1.0).toDouble();
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 7),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              backgroundColor: AppColors.line,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'HP  $hp / $maxHp',
            style: const TextStyle(fontSize: 10, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

class _ErrorSlimePanel extends StatelessWidget {
  const _ErrorSlimePanel({required this.round, required this.phaseLabel});

  final int round;
  final String phaseLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 17),
      decoration: BoxDecoration(
        color: const Color(0xFF172B40),
        borderRadius: BorderRadius.circular(23),
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                'ROUND $round',
                style: const TextStyle(
                  color: AppColors.mint,
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                  letterSpacing: 1,
                ),
              ),
              const Spacer(),
              Text(
                phaseLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: 116,
            height: 94,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: <Color>[Color(0xFF8AF4D1), Color(0xFF35D5EE)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(42),
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AppColors.mint.withValues(alpha: 0.22),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                const Icon(
                  Icons.bug_report_rounded,
                  size: 58,
                  color: Color(0xFF174358),
                ),
                Positioned(
                  top: 12,
                  right: 16,
                  child: Transform.rotate(
                    angle: 0.35,
                    child: Container(
                      width: 19,
                      height: 4,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 17,
                  left: 13,
                  child: Container(
                    width: 12,
                    height: 4,
                    color: AppColors.cyanDeep,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'ERROR SLIME',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.3,
            ),
          ),
          const SizedBox(height: 3),
          const Text(
            'UNKNOWN DATA DETECTED',
            style: TextStyle(color: Color(0xFFA9C3D1), fontSize: 9),
          ),
        ],
      ),
    );
  }
}

class _PhaseLabel extends StatelessWidget {
  const _PhaseLabel({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 7),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}

class _BattleFeedback extends StatelessWidget {
  const _BattleFeedback({
    required this.title,
    required this.message,
    required this.accent,
  });

  final String title;
  final String message;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
              color: accent,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 5),
          Text(message, style: const TextStyle(fontSize: 13, height: 1.4)),
        ],
      ),
    );
  }
}
