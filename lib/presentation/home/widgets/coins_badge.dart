import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/colors.dart';
import '../../../core/strings.dart';
import '../../../core/typography.dart';
import '../../../data/repositories/profile_repo.dart';

class CoinsBadge extends ConsumerWidget {
  const CoinsBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coins = ref.watch(profileRepoProvider).coins;
    return GestureDetector(
      onTap: () => _showHowToEarn(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.bgSecondary,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: const BoxDecoration(
                color: AppColors.coinGold,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  '\$',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text('$coins', style: AppText.header20)
                .animate(key: ValueKey('coins-$coins'))
                .scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1.0, 1.0),
                  duration: 280.ms,
                  curve: Curves.easeOutBack,
                ),
          ],
        ),
      ),
    );
  }

  void _showHowToEarn(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppStrings.coins, style: AppText.header20),
        content: Text(AppStrings.earnCoinsHowTo, style: AppText.body16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.ok, style: AppText.button16.copyWith(color: AppColors.brand)),
          ),
        ],
      ),
    );
  }
}
