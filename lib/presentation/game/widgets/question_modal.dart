import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/colors.dart';
import '../../../core/constants.dart';
import '../../../core/strings.dart';
import '../../../core/typography.dart';
import '../../../data/models/math_question.dart';
import '../../../utils/audio_manager.dart';
import '../../../utils/haptic.dart';
import '../controllers/game_controller.dart';

class QuestionModal extends ConsumerStatefulWidget {
  final MathQuestion question;
  final int extraSeconds;
  final bool isAiTurn;
  const QuestionModal({
    super.key,
    required this.question,
    this.extraSeconds = 0,
    this.isAiTurn = false,
  });

  @override
  ConsumerState<QuestionModal> createState() => _QuestionModalState();
}

class _QuestionModalState extends ConsumerState<QuestionModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _timer;
  Timer? _ticker;
  int? _selected;
  bool _resolved = false;
  late int _totalSeconds;
  late int _remainingSeconds;

  @override
  void initState() {
    super.initState();
    _totalSeconds = GameConstants.questionTimeSeconds + widget.extraSeconds;
    _remainingSeconds = _totalSeconds;
    _timer = AnimationController(
      vsync: this,
      duration: Duration(seconds: _totalSeconds),
    )..forward();
    _timer.addStatusListener((s) {
      if (s == AnimationStatus.completed && !_resolved) {
        _submit(-1);
      }
    });
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _remainingSeconds = (_totalSeconds * (1 - _timer.value)).ceil();
        if (_remainingSeconds <= 5 && _remainingSeconds > 0) {
          AudioManager.instance.playSfx('timer_tick');
        }
      });
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _timer.dispose();
    super.dispose();
  }

  Future<void> _submit(int idx) async {
    if (_resolved) return;
    setState(() {
      _resolved = true;
      _selected = idx;
    });
    _timer.stop();
    _ticker?.cancel();

    if (idx == widget.question.correctIndex) {
      Haptic.success();
    } else {
      Haptic.error();
    }

    await Future<void>.delayed(const Duration(milliseconds: 750));
    if (!mounted) return;
    ref.read(gameControllerProvider.notifier).submitQuestionAnswer(idx);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.question;
    return PopScope(
      canPop: false,
      child: Dialog(
        insetPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('👹', style: TextStyle(fontSize: 56))
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scaleXY(end: 1.1, duration: 600.ms, curve: Curves.easeInOut),
              const SizedBox(height: 8),
              Text(AppStrings.monsterAttack, style: AppText.header20),
              Text(AppStrings.answerOrDie, style: AppText.body14),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.bgAccent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  q.text,
                  style: AppText.header28.copyWith(fontSize: 32),
                  textDirection: TextDirection.ltr,
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 2.4,
                children: [
                  for (int i = 0; i < q.options.length; i++)
                    _OptionButton(
                      value: q.options[i],
                      onTap: () => _submit(i),
                      revealed: _resolved,
                      isCorrect: i == q.correctIndex,
                      isSelected: _selected == i,
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.timer_outlined,
                      size: 18, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Text('$_remainingSeconds ث', style: AppText.body14),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AnimatedBuilder(
                      animation: _timer,
                      builder: (_, __) {
                        final progress = 1 - _timer.value;
                        final color = progress > 0.4
                            ? AppColors.success
                            : progress > 0.2
                                ? AppColors.warning
                                : AppColors.error;
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 8,
                            backgroundColor: AppColors.border,
                            valueColor: AlwaysStoppedAnimation<Color>(color),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              if (widget.isAiTurn) ...[
                const SizedBox(height: 8),
                Text('الكمبيوتر بيفكر…', style: AppText.caption12),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  final int value;
  final VoidCallback onTap;
  final bool revealed;
  final bool isCorrect;
  final bool isSelected;

  const _OptionButton({
    required this.value,
    required this.onTap,
    required this.revealed,
    required this.isCorrect,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    Color bg = AppColors.bgSecondary;
    Color fg = AppColors.textPrimary;
    if (revealed) {
      if (isCorrect) {
        bg = AppColors.success;
        fg = Colors.white;
      } else if (isSelected) {
        bg = AppColors.error;
        fg = Colors.white;
      }
    }
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: revealed ? null : onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          alignment: Alignment.center,
          child: Text(
            '($value)',
            style: AppText.header20.copyWith(color: fg),
            textDirection: TextDirection.ltr,
          ),
        ),
      ),
    );
  }
}
