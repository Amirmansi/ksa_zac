import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/colors.dart';
import '../../core/constants.dart';
import '../../core/routes.dart';
import '../../core/strings.dart';
import '../../core/typography.dart';
import '../../data/models/character.dart';
import '../../data/models/player.dart';
import '../../data/repositories/profile_repo.dart';
import '../../game_engine/ai/ai_player.dart';
import '../game/controllers/game_controller.dart';
import 'character_picker.dart';

class PlayerSetupScreen extends ConsumerStatefulWidget {
  const PlayerSetupScreen({super.key});

  @override
  ConsumerState<PlayerSetupScreen> createState() => _PlayerSetupScreenState();
}

class _PlayerSetupScreenState extends ConsumerState<PlayerSetupScreen> {
  int _playerCount = 2;
  late List<TextEditingController> _names;
  late List<String> _selected;
  bool _vsCpu = false;
  AiDifficulty _aiDifficulty = AiDifficulty.medium;

  @override
  void initState() {
    super.initState();
    _names = List.generate(GameConstants.maxPlayers, (i) => TextEditingController(text: 'لاعب ${i + 1}'));
    _selected = ['fahlawy', 'osta', 'sett', 'hag'];
  }

  @override
  void dispose() {
    for (final c in _names) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileRepoProvider);
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.whoIsPlaying)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _SectionHeader(AppStrings.numberOfPlayers),
          _CountToggle(
            count: _playerCount,
            onChanged: (n) => setState(() => _playerCount = n),
          ),
          const SizedBox(height: 16),
          _SectionHeader(AppStrings.vsComputer),
          SwitchListTile.adaptive(
            value: _vsCpu,
            onChanged: (v) => setState(() => _vsCpu = v),
            title: Text(AppStrings.vsComputer, style: AppText.body16),
            subtitle: Text('انت + باقي لاعبين كمبيوتر',
                style: AppText.caption12),
            contentPadding: EdgeInsets.zero,
          ),
          if (_vsCpu) _DifficultyToggle(
            value: _aiDifficulty,
            onChanged: (d) => setState(() => _aiDifficulty = d),
          ),
          const SizedBox(height: 16),
          for (int i = 0; i < _playerCount; i++) _buildPlayerSlot(i, profile.unlockedChars),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _validate() ? _startGame : null,
            child: Text(AppStrings.startGame, style: AppText.button18),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerSlot(int i, List<String> unlocked) {
    final isHumanSlot = !_vsCpu || i == 0;
    final used = <String>{
      for (int j = 0; j < _playerCount; j++)
        if (j != i) _selected[j],
    };
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.playerPalette[i],
                child: Text('${i + 1}',
                    style: AppText.body14
                        .copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _names[i],
                  enabled: isHumanSlot,
                  decoration: InputDecoration(
                    hintText: AppStrings.enterName,
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                  textInputAction: TextInputAction.done,
                ),
              ),
              if (!isHumanSlot)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.brand,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('CPU',
                        style: AppText.caption12.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        )),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          CharacterPicker(
            selectedId: _selected[i],
            unlockedIds: unlocked,
            usedByOthers: used,
            onSelected: (id) => setState(() => _selected[i] = id),
          ),
        ],
      ),
    );
  }

  bool _validate() {
    final ids = _selected.take(_playerCount).toSet();
    return ids.length == _playerCount;
  }

  void _startGame() {
    final players = <Player>[];
    final usedNames = <String>{};
    for (int i = 0; i < _playerCount; i++) {
      var name = _names[i].text.trim();
      if (name.isEmpty) name = 'لاعب ${i + 1}';
      while (usedNames.contains(name)) {
        name += '·';
      }
      usedNames.add(name);
      final character = GameCharacter.byId(_selected[i]);
      final isAi = _vsCpu && i != 0;
      final startTile = character.id == 'hag' ? 3 : 1;
      players.add(Player(
        id: 'p$i',
        name: isAi ? '$name (CPU)' : name,
        characterId: character.id,
        color: AppColors.playerPalette[i],
        isAi: isAi,
        position: startTile,
      ));
    }
    ref.read(gameControllerProvider.notifier).setup(GameSetup(
          players: players,
          aiDifficulty: _vsCpu ? _aiDifficulty : null,
        ));
    context.go(AppRoutes.game);
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: AppText.body14.copyWith(color: AppColors.textSecondary)),
    );
  }
}

class _CountToggle extends StatelessWidget {
  final int count;
  final ValueChanged<int> onChanged;
  const _CountToggle({required this.count, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        for (int n = GameConstants.minPlayers; n <= GameConstants.maxPlayers; n++)
          ChoiceChip(
            selected: count == n,
            onSelected: (_) => onChanged(n),
            selectedColor: AppColors.brand,
            label: Text('$n لاعبين',
                style: AppText.body16.copyWith(
                  color: count == n ? Colors.white : AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                )),
          ),
      ],
    );
  }
}

class _DifficultyToggle extends StatelessWidget {
  final AiDifficulty value;
  final ValueChanged<AiDifficulty> onChanged;
  const _DifficultyToggle({required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Wrap(
        spacing: 8,
        children: [
          for (final d in AiDifficulty.values)
            ChoiceChip(
              selected: value == d,
              onSelected: (_) => onChanged(d),
              selectedColor: AppColors.brand,
              label: Text(_label(d),
                  style: AppText.body14.copyWith(
                    color: value == d ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  )),
            ),
        ],
      ),
    );
  }

  String _label(AiDifficulty d) {
    switch (d) {
      case AiDifficulty.easy:
        return AppStrings.easy;
      case AiDifficulty.medium:
        return AppStrings.medium;
      case AiDifficulty.hard:
        return AppStrings.hard;
    }
  }
}
