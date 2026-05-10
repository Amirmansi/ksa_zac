import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/colors.dart';
import '../../core/routes.dart';
import '../../core/strings.dart';
import '../../core/typography.dart';
import '../../data/repositories/profile_repo.dart';
import 'widgets/coins_badge.dart';
import 'widgets/daily_reward_dialog.dart';
import 'widgets/menu_button.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileRepoProvider);
    final canClaim = profile.canClaimDailyReward;

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.settings_outlined, size: 28),
                    onPressed: () => context.push(AppRoutes.settings),
                    tooltip: AppStrings.settings,
                  ),
                  const Spacer(),
                  const CoinsBadge(),
                ],
              ),
              const SizedBox(height: 32),
              Center(
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: AppColors.brand,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.brand.withOpacity(0.25),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('🐫', style: TextStyle(fontSize: 60)),
                  ),
                ).animate().scale(curve: Curves.easeOutBack, duration: 500.ms),
              ),
              const SizedBox(height: 16),
              Text(
                AppStrings.appName,
                style: AppText.header28,
                textAlign: TextAlign.center,
              ),
              Text(
                AppStrings.tagline,
                style: AppText.body14,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              MenuButton(
                label: AppStrings.playNow,
                icon: Icons.play_arrow_rounded,
                primary: true,
                onTap: () => context.push(AppRoutes.setup),
              ),
              const SizedBox(height: 12),
              MenuButton(
                label: AppStrings.tutorial,
                icon: Icons.school_outlined,
                onTap: () => context.push(AppRoutes.tutorial),
              ),
              const SizedBox(height: 12),
              MenuButton(
                label: AppStrings.store,
                icon: Icons.storefront_outlined,
                onTap: () => context.push(AppRoutes.store),
              ),
              const SizedBox(height: 12),
              MenuButton(
                label: AppStrings.myAchievements,
                icon: Icons.emoji_events_outlined,
                onTap: () => context.push(AppRoutes.achievements),
              ),
              const Spacer(),
              if (canClaim)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _DailyRewardChip(onTap: () => _openDaily(context)),
                ),
              Text(
                AppStrings.credits,
                style: AppText.caption12,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openDaily(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => const DailyRewardDialog(),
    );
  }
}

class _DailyRewardChip extends StatelessWidget {
  final VoidCallback onTap;

  const _DailyRewardChip({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.tileGold,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🎁', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 10),
              Text(
                AppStrings.dailyReward,
                style: AppText.body18.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scaleXY(end: 1.04, duration: 800.ms, curve: Curves.easeInOut);
  }
}
