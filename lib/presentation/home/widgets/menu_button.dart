import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/colors.dart';
import '../../../core/typography.dart';
import '../../../utils/audio_manager.dart';
import '../../../utils/haptic.dart';

class MenuButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  final bool primary;

  const MenuButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.color,
    this.primary = false,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = color ?? (primary ? AppColors.brand : AppColors.bgSecondary);
    final fgColor = primary ? AppColors.textOnDark : AppColors.textPrimary;
    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Haptic.light();
          AudioManager.instance.playSfx('button_tap');
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: primary ? null : Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(icon, color: fgColor, size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: (primary ? AppText.button18 : AppText.body18)
                      .copyWith(color: fgColor, fontWeight: FontWeight.w700),
                ),
              ),
              Icon(Icons.chevron_left_rounded, color: fgColor.withOpacity(0.6)),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
  }
}
