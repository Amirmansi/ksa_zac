import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/colors.dart';
import '../../core/constants.dart';
import '../../core/routes.dart';
import '../../core/strings.dart';
import '../../core/typography.dart';
import '../../data/repositories/profile_repo.dart';
import '../../utils/audio_manager.dart';
import '../../utils/haptic.dart';

class _TutorialStep {
  final String emoji;
  final String title;
  final String body;
  final Color color;
  const _TutorialStep({
    required this.emoji,
    required this.title,
    required this.body,
    required this.color,
  });
}

class TutorialScreen extends ConsumerStatefulWidget {
  const TutorialScreen({super.key});

  @override
  ConsumerState<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends ConsumerState<TutorialScreen> {
  static const _steps = <_TutorialStep>[
    _TutorialStep(
      emoji: '🎲',
      title: 'لف النرد',
      body: AppStrings.tutorialStep1,
      color: AppColors.brand,
    ),
    _TutorialStep(
      emoji: '🟢',
      title: 'الخلية الخضراء',
      body: AppStrings.tutorialStep2,
      color: AppColors.tileGreen,
    ),
    _TutorialStep(
      emoji: '⭐',
      title: 'الخلية الذهبية',
      body: AppStrings.tutorialStep3,
      color: AppColors.tileGold,
    ),
    _TutorialStep(
      emoji: '🚫',
      title: 'الخلية الحمراء',
      body: AppStrings.tutorialStep4,
      color: AppColors.tileRed,
    ),
    _TutorialStep(
      emoji: '👹',
      title: 'الوحش',
      body: AppStrings.tutorialStep5,
      color: AppColors.tileMonster,
    ),
    _TutorialStep(
      emoji: '🛡️',
      title: 'القدرات الخاصة',
      body: AppStrings.tutorialStep6,
      color: AppColors.tilePurple,
    ),
    _TutorialStep(
      emoji: '🏁',
      title: 'بر الأمان',
      body: 'أول واحد يوصل خلية ٣٠ يكسب! يلا ابدأ.',
      color: AppColors.success,
    ),
  ];

  int _index = 0;
  bool _claimed = false;

  Future<void> _next() async {
    Haptic.light();
    AudioManager.instance.playSfx('button_tap');
    if (_index < _steps.length - 1) {
      setState(() => _index++);
    } else {
      if (!_claimed) {
        _claimed = true;
        await ref
            .read(profileRepoProvider.notifier)
            .addCoins(GameConstants.coinsTutorialReward);
        AudioManager.instance.playSfx('victory');
        Haptic.success();
      }
      if (mounted) context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_index];
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.tutorial)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (_index + 1) / _steps.length,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.brand),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Container(
                  key: ValueKey(_index),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: step.color.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: step.color, width: 2),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(step.emoji, style: const TextStyle(fontSize: 84))
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .scaleXY(end: 1.1, duration: 800.ms),
                      const SizedBox(height: 24),
                      Text(step.title, style: AppText.header24),
                      const SizedBox(height: 12),
                      Text(
                        step.body,
                        style: AppText.body18,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (_index > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _index--),
                      child: Text(AppStrings.back),
                    ),
                  ),
                if (_index > 0) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _next,
                    child: Text(
                      _index == _steps.length - 1 ? AppStrings.tutorialDone : AppStrings.next,
                      style: AppText.button18,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('${_index + 1} / ${_steps.length}', style: AppText.caption12),
          ],
        ),
      ),
    );
  }
}
