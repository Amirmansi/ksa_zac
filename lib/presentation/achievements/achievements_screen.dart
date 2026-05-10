import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/colors.dart';
import '../../core/strings.dart';
import '../../core/typography.dart';
import '../../data/models/achievement.dart';
import '../../data/repositories/profile_repo.dart';
import '../home/widgets/coins_badge.dart';

class AchievementsScreen extends ConsumerStatefulWidget {
  const AchievementsScreen({super.key});

  @override
  ConsumerState<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends ConsumerState<AchievementsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _autoClaim());
  }

  Future<void> _autoClaim() async {
    final repo = ref.read(profileRepoProvider.notifier);
    var profile = ref.read(profileRepoProvider);
    int totalGranted = 0;
    for (final a in AchievementCatalog.all) {
      if (a.isMet(profile) && !profile.hasAchievement(a.id)) {
        await repo.grantAchievement(a.id);
        await repo.addCoins(a.reward);
        profile = ref.read(profileRepoProvider);
        totalGranted += a.reward;
      }
    }
    if (totalGranted > 0 && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('+$totalGranted عملة من إنجازات جديدة! 🎉'),
        backgroundColor: AppColors.success,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileRepoProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.achievementsTitle),
        actions: const [Padding(padding: EdgeInsets.only(left: 12), child: CoinsBadge())],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _StatsRow(
            games: profile.totalGames,
            wins: profile.wins,
            correct: profile.correctAnswers,
            streak: profile.dailyStreak,
          ),
          const SizedBox(height: 16),
          for (final a in AchievementCatalog.all)
            _AchievementCard(
              achievement: a,
              unlocked: profile.hasAchievement(a.id),
            ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final int games;
  final int wins;
  final int correct;
  final int streak;
  const _StatsRow({
    required this.games,
    required this.wins,
    required this.correct,
    required this.streak,
  });
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2.5,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      children: [
        _StatBox(label: 'ألعاب', value: games, icon: '🎮'),
        _StatBox(label: 'فوز', value: wins, icon: '🏆'),
        _StatBox(label: 'إجابات صحيحة', value: correct, icon: '✅'),
        _StatBox(label: 'استمرارية', value: streak, icon: '🔥'),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final int value;
  final String icon;
  const _StatBox({required this.label, required this.value, required this.icon});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: AppText.caption12),
                Text('$value', style: AppText.header20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final bool unlocked;
  const _AchievementCard({required this.achievement, required this.unlocked});

  @override
  Widget build(BuildContext context) {
    final card = Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: unlocked ? AppColors.bgAccent : AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: unlocked ? AppColors.brand : AppColors.border,
          width: unlocked ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Text(unlocked ? '🏆' : '🔒', style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(achievement.title,
                    style: AppText.body16.copyWith(fontWeight: FontWeight.w800)),
                Text(achievement.description, style: AppText.body14),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.coinGold,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('+${achievement.reward}',
                style: AppText.caption12.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                )),
          ),
        ],
      ),
    );
    if (unlocked) {
      return card.animate().fadeIn(duration: 300.ms).scale(
            begin: const Offset(0.95, 0.95),
            end: const Offset(1, 1),
            duration: 300.ms,
          );
    }
    return card;
  }
}
