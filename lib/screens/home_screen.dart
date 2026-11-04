import 'package:flutter/material.dart';

import '../data/conversation_data.dart';
import '../data/major_data.dart';
import '../models/battle_reward.dart';
import '../models/player_profile.dart';
import '../theme/app_theme.dart';
import '../widgets/ai_companion.dart';
import 'battle_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.profile,
    required this.onProfileUpdated,
    required this.onResetProfile,
  });

  final PlayerProfile profile;
  final Future<void> Function(PlayerProfile profile) onProfileUpdated;
  final Future<void> Function() onResetProfile;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final List<ConversationTurn> _turns;
  int _turnIndex = 0;
  String? _lastReply;
  bool _isStartingBattle = false;

  @override
  void initState() {
    super.initState();
    _turns = conversationForMajor(widget.profile.majorId);
  }

  void _chooseReply(ConversationChoice choice) {
    setState(() {
      _lastReply = choice.reply;
      _turnIndex = (_turnIndex + 1) % _turns.length;
    });
  }

  Future<void> _startBattle() async {
    if (_isStartingBattle) return;
    setState(() => _isStartingBattle = true);

    try {
      final reward = await Navigator.of(context).push<BattleReward>(
        MaterialPageRoute<BattleReward>(
          builder: (_) => BattleScreen(profile: widget.profile),
        ),
      );

      if (reward == null || !mounted) return;

      final learnedIds = <String>{
        ...widget.profile.learnedWordIds,
        ...reward.learnedWordIds,
      }.toList();

      final updatedProfile = widget.profile.copyWith(
        experience: widget.profile.experience + reward.experience,
        credits: widget.profile.credits + reward.credits,
        totalStudiedWords: widget.profile.totalStudiedWords + reward.studiedWordCount,
        learnedWordIds: learnedIds,
      );

      await widget.onProfileUpdated(updatedProfile);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '훈련 결과 저장 완료! EXP +${reward.experience} · CR +${reward.credits}',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('훈련 결과를 저장하지 못했어요: $error')),
      );
    } finally {
      if (mounted) setState(() => _isStartingBattle = false);
    }
  }

  Future<void> _openSettings() async {
    final shouldReset = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 8, 22, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Text(
                  '내 프로필',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 12),
                Text('이름: ${widget.profile.name}'),
                Text('전공: ${majorById(widget.profile.majorId).name}'),
                Text('레벨: LV. ${widget.profile.level}'),
                const SizedBox(height: 18),
                OutlinedButton.icon(
                  onPressed: () => Navigator.pop(sheetContext, true),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('처음부터 다시 설정'),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (shouldReset != true || !mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('프로필을 초기화할까요?'),
          content: const Text('이름, 전공, 경험치, 크레딧, 학습 기록이 삭제돼요.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('초기화'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      await widget.onResetProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    final major = majorById(widget.profile.majorId);
    final currentTurn = _turns[_turnIndex];
    final progress = widget.profile.experienceInCurrentLevel / 100;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              children: <Widget>[
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            const Icon(
                              Icons.memory_rounded,
                              color: AppColors.cyanDeep,
                              size: 25,
                            ),
                            const SizedBox(width: 7),
                            const Expanded(
                              child: Text(
                                'TECH QUEST',
                                style: TextStyle(
                                  color: AppColors.ink,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                            _SmallPill(
                              icon: Icons.bolt_rounded,
                              label: '${widget.profile.credits} CR',
                            ),
                            const SizedBox(width: 7),
                            IconButton(
                              tooltip: '프로필 설정',
                              onPressed: _openSettings,
                              icon: const Icon(Icons.settings_outlined),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _PlayerStatusCard(
                          name: widget.profile.name,
                          major: major.name,
                          level: widget.profile.level,
                          experience: widget.profile.experienceInCurrentLevel,
                          progress: progress,
                        ),
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: <Color>[
                                Color(0xFF39D8EF),
                                Color(0xFF83F2CE),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(26),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: AppColors.cyanDeep.withValues(alpha: 0.13),
                                blurRadius: 20,
                                offset: const Offset(0, 9),
                              ),
                            ],
                          ),
                          child: Column(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Container(
                                    width: 31,
                                    height: 31,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.55),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.smart_toy_rounded,
                                      color: AppColors.ink,
                                      size: 19,
                                    ),
                                  ),
                                  const SizedBox(width: 9),
                                  const Text(
                                    'AI LEARNING PARTNER',
                                    style: TextStyle(
                                      color: AppColors.ink,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.1,
                                    ),
                                  ),
                                  const Spacer(),
                                  const _OnlineDot(),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          '안녕, 오늘도 왔네!',
                                          style: TextStyle(
                                            color: AppColors.ink,
                                            fontSize: 21,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                        SizedBox(height: 6),
                                        Text(
                                          '나랑 잠깐 이야기하고\n오늘의 훈련을 시작해 보자.',
                                          style: TextStyle(
                                            color: Color(0xFF28566A),
                                            height: 1.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const AiCompanion(size: 108),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.82),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      currentTurn.englishQuestion,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.ink,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      currentTurn.koreanQuestion,
                                      style: const TextStyle(
                                        color: AppColors.muted,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (_lastReply != null) ...<Widget>[
                                const SizedBox(height: 9),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.ink.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Text(
                                    _lastReply!,
                                    style: const TextStyle(
                                      color: AppColors.ink,
                                      fontSize: 13,
                                      height: 1.4,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 11),
                              ...currentTurn.choices.map(
                                (choice) => Padding(
                                  padding: const EdgeInsets.only(bottom: 7),
                                  child: _ConversationChoiceButton(
                                    choice: choice,
                                    onTap: () => _chooseReply(choice),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 17),
                        Row(
                          children: <Widget>[
                            const Icon(
                              Icons.bolt_rounded,
                              color: AppColors.mintDeep,
                              size: 19,
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              '오늘의 훈련',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                color: AppColors.ink,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '단어 방어 + 문장 공격',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(13),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.line),
                          ),
                          child: const Row(
                            children: <Widget>[
                              Icon(
                                Icons.biotech_rounded,
                                size: 23,
                                color: AppColors.cyanDeep,
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'ERROR SLIME 시뮬레이션',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.ink,
                                  ),
                                ),
                              ),
                              Icon(Icons.chevron_right_rounded),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
                  child: FilledButton.icon(
                    onPressed: _isStartingBattle ? null : _startBattle,
                    icon: _isStartingBattle
                        ? const SizedBox(
                            width: 19,
                            height: 19,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.play_arrow_rounded, size: 25),
                    label: Text(
                      _isStartingBattle ? '훈련 준비 중...' : '훈련 시작하기',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlayerStatusCard extends StatelessWidget {
  const _PlayerStatusCard({
    required this.name,
    required this.major,
    required this.level,
    required this.experience,
    required this.progress,
  });

  final String name;
  final String major;
  final int level;
  final int experience;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '$name  ·  $major',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'PLAYER LEVEL  $level',
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '$experience / 100 EXP',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.cyanDeep,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.line,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.mintDeep),
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallPill extends StatelessWidget {
  const _SmallPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cyan.withValues(alpha: 0.17),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, color: AppColors.cyanDeep, size: 16),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _OnlineDot extends StatelessWidget {
  const _OnlineDot();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        CircleAvatar(radius: 4, backgroundColor: AppColors.mintDeep),
        SizedBox(width: 5),
        Text(
          'ONLINE',
          style: TextStyle(
            color: AppColors.ink,
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.7,
          ),
        ),
      ],
    );
  }
}

class _ConversationChoiceButton extends StatelessWidget {
  const _ConversationChoiceButton({required this.choice, required this.onTap});

  final ConversationChoice choice;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: AppColors.cyanDeep.withValues(alpha: 0.35)),
          ),
          child: Row(
            children: <Widget>[
              const Icon(
                Icons.chat_bubble_outline_rounded,
                size: 16,
                color: AppColors.cyanDeep,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      choice.english,
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      choice.korean,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.muted,
                size: 13,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
