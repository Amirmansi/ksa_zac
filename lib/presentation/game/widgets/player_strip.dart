import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/colors.dart';
import '../../../core/typography.dart';
import '../../../data/models/character.dart';
import '../../../data/models/player.dart';

class PlayerStrip extends StatelessWidget {
  final List<Player> players;
  final int currentIndex;
  final void Function(int index)? onTap;

  const PlayerStrip({
    super.key,
    required this.players,
    required this.currentIndex,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 78,
      child: Row(
        children: [
          for (int i = 0; i < players.length; i++)
            Expanded(child: _PlayerSlot(
              player: players[i],
              isCurrent: i == currentIndex,
              onTap: onTap == null ? null : () => onTap!(i),
            )),
        ],
      ),
    );
  }
}

class _PlayerSlot extends StatelessWidget {
  final Player player;
  final bool isCurrent;
  final VoidCallback? onTap;

  const _PlayerSlot({
    required this.player,
    required this.isCurrent,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final character = GameCharacter.byId(player.characterId);
    final base = Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCurrent ? player.color : AppColors.border,
          width: isCurrent ? 2.5 : 1,
        ),
        boxShadow: isCurrent
            ? [
                BoxShadow(
                  color: player.color.withOpacity(0.35),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.bottomLeft,
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: player.color,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    character.emoji,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              if (player.shieldActive && !player.hasUsedShield)
                const Positioned(
                  bottom: -2,
                  left: -2,
                  child: Text('🛡️', style: TextStyle(fontSize: 12)),
                ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            player.name,
            style: AppText.caption12.copyWith(
              fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            player.isFinished ? '🏁' : 'خانة ${player.position}',
            style: AppText.caption12.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );

    return GestureDetector(
      onTap: onTap,
      child: isCurrent
          ? base.animate(onPlay: (c) => c.repeat(reverse: true)).scaleXY(
                end: 1.03,
                duration: 800.ms,
                curve: Curves.easeInOut,
              )
          : base,
    );
  }
}
