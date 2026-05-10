import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/colors.dart';
import '../../core/strings.dart';
import '../../core/typography.dart';
import '../../data/repositories/profile_repo.dart';
import '../../utils/audio_manager.dart';
import '../../utils/haptic.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileRepoProvider);
    final repo = ref.read(profileRepoProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.settings)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _SectionTitle('الصوت والاهتزاز'),
          _SwitchTile(
            icon: Icons.volume_up_outlined,
            label: AppStrings.sound,
            value: profile.soundEnabled,
            onChanged: (v) {
              repo.setSoundEnabled(v);
              AudioManager.instance.setSoundEnabled(v);
            },
          ),
          _SwitchTile(
            icon: Icons.music_note_outlined,
            label: AppStrings.music,
            value: profile.musicEnabled,
            onChanged: (v) {
              repo.setMusicEnabled(v);
              AudioManager.instance.setMusicEnabled(v);
            },
          ),
          _SwitchTile(
            icon: Icons.vibration,
            label: AppStrings.haptics,
            value: profile.hapticsEnabled,
            onChanged: (v) {
              repo.setHapticsEnabled(v);
              Haptic.setEnabled(v);
            },
          ),
          const SizedBox(height: 8),
          _VolumeTile(
            value: profile.volume,
            onChanged: (v) {
              repo.setVolume(v);
              AudioManager.instance.setVolume(v);
            },
          ),
          const SizedBox(height: 24),
          _SectionTitle('البيانات'),
          _DangerTile(
            icon: Icons.refresh,
            label: AppStrings.resetData,
            onTap: () => _confirmReset(context, repo),
          ),
          const SizedBox(height: 32),
          _SectionTitle(AppStrings.about),
          ListTile(
            title: Text(AppStrings.version, style: AppText.body16),
            trailing: Text('1.0.0', style: AppText.body14),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              AppStrings.credits,
              style: AppText.body14,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context, ProfileRepo repo) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppStrings.resetData, style: AppText.header20),
        content: Text(AppStrings.resetWarning, style: AppText.body16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppStrings.cancel, style: AppText.button16.copyWith(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppStrings.yes, style: AppText.button16.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await repo.resetProgress();
    }
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Text(text, style: AppText.body14.copyWith(color: AppColors.textSecondary)),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SwitchTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: SwitchListTile.adaptive(
        secondary: Icon(icon, color: AppColors.textPrimary),
        title: Text(label, style: AppText.body16),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}

class _VolumeTile extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  const _VolumeTile({required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.tune, color: AppColors.textPrimary),
          const SizedBox(width: 12),
          Text(AppStrings.volume, style: AppText.body16),
          Expanded(
            child: Slider(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.brand,
            ),
          ),
          SizedBox(
            width: 40,
            child: Text(
              '${(value * 100).round()}%',
              style: AppText.caption12,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

class _DangerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _DangerTile({required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.bgSecondary,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.error.withOpacity(0.4)),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.error),
              const SizedBox(width: 12),
              Text(label, style: AppText.body16.copyWith(color: AppColors.error)),
            ],
          ),
        ),
      ),
    );
  }
}
