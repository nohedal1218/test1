import 'package:flutter/material.dart';

import '../data/major_data.dart';
import '../models/player_profile.dart';
import '../theme/app_theme.dart';
import '../widgets/ai_companion.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key, required this.onCompleted});

  final Future<void> Function(PlayerProfile profile) onCompleted;

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final TextEditingController _nameController = TextEditingController();
  String? _selectedMajorId;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    final name = _nameController.text.trim();
    if (name.isEmpty || _selectedMajorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이름과 전공을 모두 입력해 주세요.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await widget.onCompleted(
        PlayerProfile(name: name, majorId: _selectedMajorId!),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('정보 저장에 실패했어요: $error')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const SizedBox(height: 12),
                  const AiCompanion(size: 104),
                  const SizedBox(height: 20),
                  Text(
                    'TECH QUEST',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          letterSpacing: 2.4,
                          fontSize: 27,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '안녕! 함께 훈련을 시작해 볼까?',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '시작하기 전에 이름과 전공을 알려줘.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.muted),
                  ),
                  const SizedBox(height: 30),
                  const _SectionTitle(number: '01', title: '이름을 알려줘'),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _nameController,
                    maxLength: 12,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      hintText: '사용할 이름 또는 닉네임',
                      prefixIcon: Icon(Icons.person_outline_rounded),
                      counterText: '',
                    ),
                    onSubmitted: (_) => _start(),
                  ),
                  const SizedBox(height: 24),
                  const _SectionTitle(number: '02', title: '전공을 선택해 줘'),
                  const SizedBox(height: 10),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final tileWidth = (constraints.maxWidth - 10) / 2;
                      return Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: majorOptions.map((major) {
                          final selected = _selectedMajorId == major.id;
                          return SizedBox(
                            width: tileWidth,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(18),
                              onTap: () => setState(
                                () => _selectedMajorId = major.id,
                              ),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 160),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 17,
                                ),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? AppColors.cyan.withValues(alpha: 0.18)
                                      : AppColors.surface,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: selected
                                        ? AppColors.cyanDeep
                                        : AppColors.line,
                                    width: selected ? 1.8 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: <Widget>[
                                    Icon(
                                      major.icon,
                                      color: selected
                                          ? AppColors.cyanDeep
                                          : AppColors.muted,
                                    ),
                                    const SizedBox(width: 9),
                                    Expanded(
                                      child: Text(
                                        major.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.ink,
                                        ),
                                      ),
                                    ),
                                    if (selected)
                                      const Icon(
                                        Icons.check_circle_rounded,
                                        color: AppColors.cyanDeep,
                                        size: 19,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 28),
                  FilledButton(
                    onPressed: _isSaving ? null : _start,
                    child: _isSaving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('시작하기'),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '선택한 정보는 이 기기에 저장돼.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: AppColors.muted),
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.number, required this.title});

  final String number;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.cyan.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Text(
            number,
            style: const TextStyle(
              color: AppColors.cyanDeep,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 9),
        Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      ],
    );
  }
}
