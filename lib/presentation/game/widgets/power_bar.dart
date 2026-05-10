import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/colors.dart';
import '../../../core/constants.dart';
import '../../../core/typography.dart';
import '../../../data/models/player.dart';
import '../../../data/models/power_up.dart';
import '../controllers/game_controller.dart';

class PowerBar extends ConsumerWidget {
  final Player player;
  final bool isInteractable;

  const PowerBar({
    super.key,
    required this.player,
    required this.isInteractable,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slots = List<PowerUp?>.generate(
      GameConstants.maxPowersInBar,
      (i) => i < player.powers.length ? player.powers[i] : null,
    );
    return SizedBox(
      height: 64,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (int i = 0; i < slots.length; i++) ...[
            _PowerSlot(
              power: slots[i],
              onTap: slots[i] != null && isInteractable && slots[i]!.manual
                  ? () => ref.read(gameControllerProvider.notifier).usePower(player.id, slots[i]!)
                  : null,
            ),
            if (i < slots.length - 1) const SizedBox(width: 10),
          ],
        ],
      ),
    );
  }
}

class _PowerSlot extends StatelessWidget {
  final PowerUp? power;
  final VoidCallback? onTap;

  const _PowerSlot({required this.power, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (power == null) {
      return Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: AppColors.bgSecondary,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, style: BorderStyle.solid),
        ),
        child: const Center(
          child: Icon(Icons.add, size: 18, color: AppColors.border),
        ),
      );
    }
    final disabled = onTap == null;
    final w = Material(
      color: disabled
          ? AppColors.tileGold.withOpacity(0.6)
          : AppColors.tileGold,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: 50,
          height: 50,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(power!.icon, style: const TextStyle(fontSize: 22)),
              Text(
                power!.arabicName,
                style: AppText.caption12.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
                maxLines: 1,
                overflow: TextOverflow.fade,
              ),
            ],
          ),
        ),
      ),
    );
    if (disabled) return w;
    return w.animate(onPlay: (c) => c.repeat()).shimmer(
          duration: 1200.ms,
          color: Colors.white.withOpacity(0.4),
        );
  }
}
