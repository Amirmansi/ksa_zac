import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/colors.dart';
import '../../core/strings.dart';
import '../../core/typography.dart';
import '../../data/models/character.dart';
import '../../data/repositories/profile_repo.dart';
import '../../utils/audio_manager.dart';
import '../../utils/haptic.dart';
import '../home/widgets/coins_badge.dart';

class StoreScreen extends ConsumerWidget {
  const StoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileRepoProvider);
    final repo = ref.read(profileRepoProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.store),
        actions: const [Padding(padding: EdgeInsets.only(left: 12), child: CoinsBadge())],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _CategoryHeader(AppStrings.storeCharacters),
          for (final c in GameCharacter.all)
            _CharacterStoreCard(
              character: c,
              isUnlocked: profile.unlockedChars.contains(c.id),
              isSelected: profile.selectedChar == c.id,
              canAfford: profile.coins >= c.price,
              onUnlock: () async {
                final ok = await repo.unlockCharacter(c.id, c.price);
                if (!ok && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(AppStrings.notEnoughCoins),
                    backgroundColor: AppColors.error,
                  ));
                  Haptic.error();
                  return;
                }
                AudioManager.instance.playSfx('tile_gold');
                Haptic.success();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('${AppStrings.purchased} ${c.name}'),
                    backgroundColor: AppColors.success,
                  ));
                }
              },
              onSelect: () => repo.selectCharacter(c.id),
            ),
          const SizedBox(height: 16),
          _CategoryHeader(AppStrings.storeThemes),
          _ComingSoonCard(label: 'الفرعوني، الصعيدي، الإسكندراني — قريباً 👷'),
          const SizedBox(height: 16),
          _CategoryHeader(AppStrings.storeSounds),
          _ComingSoonCard(label: 'حزم أصوات بديلة — قريباً'),
        ],
      ),
    );
  }
}

class _CategoryHeader extends StatelessWidget {
  final String text;
  const _CategoryHeader(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Text(text,
          style: AppText.body14.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w800,
          )),
    );
  }
}

class _CharacterStoreCard extends StatelessWidget {
  final GameCharacter character;
  final bool isUnlocked;
  final bool isSelected;
  final bool canAfford;
  final VoidCallback onUnlock;
  final VoidCallback onSelect;
  const _CharacterStoreCard({
    required this.character,
    required this.isUnlocked,
    required this.isSelected,
    required this.canAfford,
    required this.onUnlock,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.bgAccent : AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppColors.brand : AppColors.border,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(color: character.color, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(character.emoji, style: const TextStyle(fontSize: 28)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(character.name,
                    style: AppText.body18.copyWith(fontWeight: FontWeight.w800)),
                Text(character.description, style: AppText.body14),
                Text(character.ability,
                    style: AppText.caption12.copyWith(color: AppColors.brand)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (!isUnlocked)
            ElevatedButton.icon(
              icon: const Icon(Icons.lock_open, size: 16),
              label: Text('${character.price} 💰', style: AppText.caption12),
              onPressed: canAfford ? onUnlock : null,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(0, 40),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            )
          else if (!isSelected)
            OutlinedButton(
              onPressed: onSelect,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 40),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text('اختار', style: AppText.caption12.copyWith(color: AppColors.brand)),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.success,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('مختارة',
                  style: AppText.caption12.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  )),
            ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9)),
        ],
      ),
    );
  }
}

class _ComingSoonCard extends StatelessWidget {
  final String label;
  const _ComingSoonCard({required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, style: BorderStyle.solid),
      ),
      child: Row(
        children: [
          const Icon(Icons.hourglass_top, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: AppText.body14)),
        ],
      ),
    );
  }
}
