import 'package:flutter/material.dart';

import '../models/battle_reward.dart';
import '../theme/app_theme.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({
    super.key,
    required this.reward,
    required this.onReturnHome,
  });

  final BattleReward reward;
  final VoidCallback onReturnHome;

  @override
  Widget build(BuildContext context) {
    final isVictory = reward.isVictory;
    final accent = isVictory ? AppColors.mintDeep : AppColors.warning;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                    width: 112,
                    height: 112,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isVictory ? Icons.check_rounded : Icons.refresh_rounded,
                      size: 64,
                      color: accent,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    isVictory ? 'TRAINING COMPLETE' : 'TRAINING FAILED',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: accent,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isVictory ? '훈련 성공!' : '다시 도전해 보자!',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 26),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: Column(
                      children: <Widget>[
                        _RewardRow(
                          icon: Icons.trending_up_rounded,
                          label: '획득 경험치',
                          value: '+${reward.experience} EXP',
                          color: AppColors.cyanDeep,
                        ),
                        const Divider(height: 24),
                        _RewardRow(
                          icon: Icons.bolt_rounded,
                          label: '획득 크레딧',
                          value: '+${reward.credits} CR',
                          color: AppColors.warning,
                        ),
                        const Divider(height: 24),
                        _RewardRow(
                          icon: Icons.menu_book_rounded,
                          label: '학습 단어',
                          value: '${reward.studiedWordCount}개 학습',
                          color: AppColors.mintDeep,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  FilledButton(
                    onPressed: onReturnHome,
                    child: const Text('홈으로 돌아가기'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RewardRow extends StatelessWidget {
  const _RewardRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(icon, color: color),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700))),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.ink),
        ),
      ],
    );
  }
}
