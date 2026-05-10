import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/colors.dart';
import '../../core/constants.dart';
import '../../core/routes.dart';
import '../../core/strings.dart';
import '../../core/typography.dart';
import '../../data/models/game_state.dart';
import '../../data/models/player.dart';
import '../../data/models/character.dart';
import '../../game_engine/race_game.dart';
import 'controllers/game_controller.dart';
import 'widgets/dice_widget.dart';
import 'widgets/player_strip.dart';
import 'widgets/power_bar.dart';
import 'widgets/question_modal.dart';
import 'widgets/result_dialog.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  late RaceGame _game;
  bool _modalOpen = false;
  bool _resultShown = false;

  @override
  void initState() {
    super.initState();
    _game = RaceGame();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gameControllerProvider.notifier).attachGame(_game);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameControllerProvider);
    if (state.players.isEmpty) {
      // No setup performed; bounce back.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go(AppRoutes.setup);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    _maybeShowQuestion(state);
    _maybeShowResult(state);

    final me = state.currentPlayer;
    final canRoll = state.status == GameStatus.idle && !me.isAi && !me.isFinished;

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🎲', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Text('${AppStrings.turnOf} ${me.name}',
                style: AppText.body18.copyWith(color: me.color, fontWeight: FontWeight.w800)),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _confirmExit(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  GameWidget(game: _game),
                  if (state.status == GameStatus.moving ||
                      state.status == GameStatus.rolling)
                    Positioned(
                      top: 8,
                      right: 16,
                      child: _StatusPill(text: AppStrings.rolling),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            PowerBar(player: me, isInteractable: canRoll),
            const SizedBox(height: 4),
            PlayerStrip(
              players: state.players,
              currentIndex: state.currentPlayerIndex,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_diceLabel(state, me), style: AppText.body14),
                  const SizedBox(width: 16),
                  DiceWidget(
                    enabled: canRoll,
                    onRolled: (v) async =>
                        ref.read(gameControllerProvider.notifier).rollDice(rawValue: v),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _diceLabel(GameState state, Player me) {
    if (me.isAi && state.status == GameStatus.idle) return 'الكمبيوتر بيلعب';
    if (state.status == GameStatus.moving) return 'بيتحرك...';
    if (state.lastDiceValue != null) return 'آخر رمية: ${state.lastDiceValue}';
    return 'اضغط للف النرد';
  }

  void _maybeShowQuestion(GameState state) {
    if (state.status == GameStatus.awaitingQuestion &&
        state.currentQuestion != null &&
        !_modalOpen) {
      _modalOpen = true;
      final me = state.players.firstWhere(
        (p) => p.id == state.currentQuestionPlayerId,
        orElse: () => state.currentPlayer,
      );
      final extra = me.characterId == 'fahlawy'
          ? GameConstants.questionTimeBonusFahlawy
          : 0;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (_) => QuestionModal(
            question: state.currentQuestion!,
            extraSeconds: extra,
            isAiTurn: me.isAi,
          ),
        ).then((_) => _modalOpen = false);
      });
    }
  }

  void _maybeShowResult(GameState state) {
    if (state.isGameOver && !_resultShown) {
      _resultShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (_) => const ResultDialog(),
        );
      });
    }
  }

  Future<void> _confirmExit(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('الخروج من اللعبة', style: AppText.header20),
        content: Text('هتخسر التقدم اللي حصل في اللعبة دي. متأكد؟',
            style: AppText.body16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppStrings.yes,
                style: AppText.button16.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (result == true && mounted) context.go(AppRoutes.home);
  }
}

class _StatusPill extends StatelessWidget {
  final String text;
  const _StatusPill({required this.text});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.brand,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text,
          style: AppText.caption12.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
    );
  }
}
