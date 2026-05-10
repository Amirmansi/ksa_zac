import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../../core/strings.dart';
import '../../core/typography.dart';
import '../../data/models/character.dart';

class CharacterPicker extends StatelessWidget {
  final String selectedId;
  final List<String> unlockedIds;
  final ValueChanged<String> onSelected;
  final Set<String> usedByOthers;

  const CharacterPicker({
    super.key,
    required this.selectedId,
    required this.unlockedIds,
    required this.onSelected,
    this.usedByOthers = const {},
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: GameCharacter.all.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final c = GameCharacter.all[i];
          final unlocked = unlockedIds.contains(c.id);
          final used = usedByOthers.contains(c.id) && c.id != selectedId;
          final selected = c.id == selectedId;
          return _CharacterCard(
            character: c,
            unlocked: unlocked,
            used: used,
            selected: selected,
            onTap: unlocked && !used ? () => onSelected(c.id) : null,
          );
        },
      ),
    );
  }
}

class _CharacterCard extends StatelessWidget {
  final GameCharacter character;
  final bool unlocked;
  final bool used;
  final bool selected;
  final VoidCallback? onTap;

  const _CharacterCard({
    required this.character,
    required this.unlocked,
    required this.used,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return SizedBox(
      width: 120,
      child: Material(
        color: selected ? character.color : AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Opacity(
            opacity: disabled ? 0.5 : 1,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected ? AppColors.brandDark : AppColors.border,
                  width: selected ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.bottomLeft,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: selected ? Colors.white : character.color,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(character.emoji,
                            style: const TextStyle(fontSize: 28)),
                      ),
                      if (!unlocked)
                        const Positioned(
                          bottom: -4,
                          left: -4,
                          child: Text('🔒', style: TextStyle(fontSize: 16)),
                        ),
                      if (used && unlocked)
                        const Positioned(
                          bottom: -4,
                          left: -4,
                          child: Text('🚫', style: TextStyle(fontSize: 16)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    character.name,
                    style: AppText.body14.copyWith(
                      color: selected ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    !unlocked
                        ? '${character.price} 💰'
                        : (used ? 'مستخدمة' : character.description),
                    style: AppText.caption12.copyWith(
                      color: selected ? Colors.white.withOpacity(0.85) : AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
