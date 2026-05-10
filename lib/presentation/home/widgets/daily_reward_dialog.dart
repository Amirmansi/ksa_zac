import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/colors.dart';
import '../../../core/constants.dart';
import '../../../core/strings.dart';
import '../../../core/typography.dart';
import '../../../data/repositories/profile_repo.dart';
import '../../../utils/audio_manager.dart';
import '../../../utils/haptic.dart';

class DailyRewardDialog extends ConsumerStatefulWidget {
  const DailyRewardDialog({super.key});

  @override
  ConsumerState<DailyRewardDialog> createState() => _DailyRewardDialogState();
}

class _DailyRewardDialogState extends ConsumerState<DailyRewardDialog> {
  int? _claimedAmount;

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileRepoProvider);
    final rewards = GameConstants.dailyRewards;
    final nextStreak = profile.streakStillValid ? profile.dailyStreak + 1 : 1;
    final highlightIdx = ((nextStreak - 1) % rewards.length).clamp(0, rewards.length - 1);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎁', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(AppStrings.dailyReward, style: AppText.header24),
            const SizedBox(height: 8),
            Text(
              'استمراريتك: $nextStreak يوم',
              style: AppText.body14,
            ),
            const SizedBox(height: 20),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: List.generate(rewards.length, (i) {
                final highlight = i == highlightIdx;
                return _RewardCard(
                  day: i + 1,
                  amount: rewards[i],
                  highlight: highlight,
                );
              }),
            ),
            const SizedBox(height: 24),
            if (_claimedAmount == null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _claim,
                  child: Text(AppStrings.claimReward, style: AppText.button18),
                ),
              )
            else
              Column(
                children: [
                  Text(
                    '+$_claimedAmount عملة! 🎉',
                    style: AppText.header20.copyWith(color: AppColors.success),
                  ).animate().scale(curve: Curves.elasticOut, duration: 500.ms),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(AppStrings.close,
                        style: AppText.button16.copyWith(color: AppColors.brand)),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _claim() async {
    final amount = await ref.read(profileRepoProvider.notifier).claimDailyReward();
    if (amount > 0) {
      Haptic.success();
      AudioManager.instance.playSfx('tile_gold');
    }
    if (mounted) setState(() => _claimedAmount = amount);
  }
}

class _RewardCard extends StatelessWidget {
  final int day;
  final int amount;
  final bool highlight;

  const _RewardCard({
    required this.day,
    required this.amount,
    required this.highlight,
  });

  @override
  Widget build(BuildContext context) {
    final bg = highlight ? AppColors.brand : AppColors.bgAccent;
    final fg = highlight ? AppColors.textOnDark : AppColors.textPrimary;
    return Container(
      width: 70,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: highlight ? AppColors.brandDark : AppColors.border,
          width: highlight ? 2 : 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('يوم $day',
              style: AppText.caption12.copyWith(color: fg.withOpacity(0.8))),
          const SizedBox(height: 4),
          Text('+$amount',
              style: AppText.body18.copyWith(color: fg, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
