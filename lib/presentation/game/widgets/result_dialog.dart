import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/colors.dart';
import '../../../core/constants.dart';
import '../../../core/routes.dart';
import '../../../core/strings.dart';
import '../../../core/typography.dart';
import '../../../data/models/character.dart';
import '../../../data/models/player.dart';
import '../controllers/game_controller.dart';

class ResultDialog extends ConsumerWidget {
  const ResultDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameControllerProvider);
    final ranked = [...state.players]
      ..sort((a, b) => (a.finalRank ?? 99).compareTo(b.finalRank ?? 99));
    final winner = ranked.isNotEmpty ? ranked.first : null;
    return PopScope(
      canPop: false,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        insetPadding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('🏆',
                      style: TextStyle(fontSize: 64), textAlign: TextAlign.center)
                  .animate()
                  .scale(curve: Curves.elasticOut, duration: 600.ms),
              const SizedBox(height: 8),
              Text(
                AppStrings.youWon,
                textAlign: TextAlign.center,
                style: AppText.header24,
              ).animate().fadeIn(delay: 200.ms),
              if (winner != null) ...[
                const SizedBox(height: 4),
                Text(
                  winner.name,
                  style: AppText.body18.copyWith(
                    color: winner.color,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 18),
              Text(AppStrings.finalStandings,
                  style: AppText.body14, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              for (int i = 0; i < ranked.length; i++)
                _RankRow(
                  player: ranked[i],
                  rank: ranked[i].finalRank ?? (i + 1),
                  reward: _rewardFor(ranked[i].finalRank ?? (i + 1)),
                ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        context.go(AppRoutes.home);
                      },
                      child: Text(AppStrings.goHome,
                          style: AppText.button18
                              .copyWith(color: AppColors.brand)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        context.go(AppRoutes.setup);
                      },
                      child: Text(AppStrings.playAgain, style: AppText.button18),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _rewardFor(int rank) {
    switch (rank) {
      case 1:
        return GameConstants.coinsPerWin;
      case 2:
        return GameConstants.coinsPerSecondPlace;
      case 3:
        return GameConstants.coinsPerThirdPlace;
      default:
        return GameConstants.coinsPerFourthPlace;
    }
  }
}

class _RankRow extends StatelessWidget {
  final Player player;
  final int rank;
  final int reward;

  const _RankRow({
    required this.player,
    required this.rank,
    required this.reward,
  });

  @override
  Widget build(BuildContext context) {
    final char = GameCharacter.byId(player.characterId);
    final medal = switch (rank) {
      1 => '🥇',
      2 => '🥈',
      3 => '🥉',
      _ => '$rank.',
    };
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: rank == 1 ? AppColors.bgAccent : AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          SizedBox(width: 28, child: Text(medal, style: AppText.body18, textAlign: TextAlign.center)),
          const SizedBox(width: 8),
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(color: player.color, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(char.emoji, style: const TextStyle(fontSize: 14)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              player.name,
              style: AppText.body16.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          if (!player.isAi)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.coinGold,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('+$reward',
                  style: AppText.caption12.copyWith(
                      color: Colors.white, fontWeight: FontWeight.w800)),
            ),
        ],
      ),
    );
  }
}
