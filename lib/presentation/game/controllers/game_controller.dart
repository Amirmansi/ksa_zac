import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants.dart';
import '../../../data/models/game_state.dart';
import '../../../data/models/math_question.dart';
import '../../../data/models/player.dart';
import '../../../data/models/power_up.dart';
import '../../../data/models/tile.dart';
import '../../../data/question_generator.dart';
import '../../../data/repositories/profile_repo.dart';
import '../../../game_engine/ai/ai_player.dart';
import '../../../game_engine/board_layout.dart';
import '../../../game_engine/race_game.dart';
import '../../../utils/audio_manager.dart';
import '../../../utils/haptic.dart';

class GameSetup {
  final List<Player> players;
  final AiDifficulty? aiDifficulty;
  const GameSetup({required this.players, this.aiDifficulty});
}

final gameControllerProvider =
    NotifierProvider<GameController, GameState>(GameController.new);

class GameController extends Notifier<GameState> {
  final QuestionGenerator _qgen = QuestionGenerator();
  final Random _r = Random();
  AiDifficulty _aiDifficulty = AiDifficulty.medium;
  RaceGame? _game;
  Completer<int>? _questionCompleter;

  @override
  GameState build() {
    return GameState(
      players: const [],
      currentPlayerIndex: 0,
      status: GameStatus.idle,
      board: BoardLayout.buildTiles(),
    );
  }

  void attachGame(RaceGame game) {
    _game = game;
    game.replacePlayers(state.players);
  }

  void setup(GameSetup setup) {
    if (setup.aiDifficulty != null) _aiDifficulty = setup.aiDifficulty!;
    state = state.copyWith(
      players: setup.players,
      currentPlayerIndex: 0,
      status: GameStatus.idle,
      consecutiveSixes: 0,
      finishOrder: const [],
      clearLastDiceValue: true,
      clearQuestion: true,
    );
    _game?.replacePlayers(state.players);
  }

  Future<void> rollDice({int? rawValue}) async {
    if (state.status != GameStatus.idle) return;
    final me = state.currentPlayer;
    if (me.isFinished) {
      _nextTurn();
      return;
    }

    int value = rawValue ?? (_r.nextInt(6) + 1);

    // Osta passive: 5% double the dice value.
    if (me.characterId == 'osta' && _r.nextDouble() < 0.05) {
      value = (value * 2).clamp(1, 12);
    }
    // Used double-dice power-up.
    if (me.doubleDiceNext) {
      value = (value * 2).clamp(1, 12);
      _patchPlayer(me.id, (p) => p.copyWith(doubleDiceNext: false));
    }

    await applyDiceValue(value);
  }

  /// Public so the dice widget can also drive the value (UI -> controller).
  Future<void> applyDiceValue(int value) async {
    if (state.status != GameStatus.idle && state.status != GameStatus.rolling) return;
    final me = state.currentPlayer;

    state = state.copyWith(
      status: GameStatus.moving,
      lastDiceValue: value,
      consecutiveSixes: value == 6 ? state.consecutiveSixes + 1 : 0,
    );

    final originalPos = me.position;
    final targetPos = (originalPos + value).clamp(1, GameConstants.boardTiles);
    final delta = targetPos - originalPos;

    await _game?.animateMove(
      me.id,
      delta,
      onStep: () async {
        Haptic.light();
        AudioManager.instance.playSfx('move_step');
      },
    );
    _patchPlayer(me.id, (p) => p.copyWith(position: targetPos));

    await _applyTileEffect(targetPos);
    if (state.isGameOver) return;

    final didFinish = state.players.firstWhere((p) => p.id == me.id).isFinished;
    if (didFinish) {
      _nextTurn();
      return;
    }

    // Dice 6 rule: extra turn unless 3 consecutive 6s.
    if (value == 6 && state.consecutiveSixes < GameConstants.maxConsecutiveSixes) {
      state = state.copyWith(status: GameStatus.idle);
      _maybeRunAi();
      return;
    }
    _nextTurn();
  }

  Future<void> _applyTileEffect(int tileId) async {
    final tile = state.board.firstWhere((t) => t.id == tileId);
    final me = state.currentPlayer;

    switch (tile.type) {
      case TileType.normal:
      case TileType.start:
        await _checkCollision(me.id);
        state = state.copyWith(status: GameStatus.idle);
        break;

      case TileType.green:
        AudioManager.instance.playSfx('tile_green');
        Haptic.success();
        await _game?.animateMove(
          me.id,
          GameConstants.greenForward,
          onStep: () async {
            Haptic.light();
            AudioManager.instance.playSfx('move_step');
          },
        );
        _patchPlayer(me.id,
            (p) => p.copyWith(position: (p.position + GameConstants.greenForward).clamp(1, GameConstants.boardTiles)));
        await _checkCollision(me.id);
        await _checkFinishFor(me.id);
        if (!state.isGameOver) state = state.copyWith(status: GameStatus.idle);
        break;

      case TileType.gold:
        AudioManager.instance.playSfx('tile_gold');
        final granted = _grantRandomPower(me.id);
        if (granted != null) {
          Haptic.success();
        }
        await _checkCollision(me.id);
        state = state.copyWith(status: GameStatus.idle);
        break;

      case TileType.purple:
        AudioManager.instance.playSfx('tile_purple');
        _patchPlayer(me.id, (p) => p.copyWith(doubleDiceNext: true));
        await _checkCollision(me.id);
        state = state.copyWith(status: GameStatus.idle);
        break;

      case TileType.red:
        AudioManager.instance.playSfx('tile_red');
        Haptic.error();
        final newPos = (me.position - GameConstants.redBackward).clamp(1, GameConstants.boardTiles);
        await _game?.animateMove(
          me.id,
          newPos - me.position,
          onStep: () async {
            Haptic.light();
            AudioManager.instance.playSfx('move_step');
          },
        );
        _patchPlayer(me.id, (p) => p.copyWith(position: newPos));
        state = state.copyWith(status: GameStatus.idle);
        break;

      case TileType.monster:
        // Skip-question power consumes itself.
        final updated = state.players.firstWhere((p) => p.id == me.id);
        if (updated.powers.contains(PowerUp.skipQuestion)) {
          _consumePower(me.id, PowerUp.skipQuestion);
          AudioManager.instance.playSfx('power_use');
          await _game?.animateMove(me.id, 1);
          _patchPlayer(me.id, (p) => p.copyWith(position: (p.position + 1).clamp(1, GameConstants.boardTiles)));
          await _checkFinishFor(me.id);
          if (!state.isGameOver) state = state.copyWith(status: GameStatus.idle);
          break;
        }
        AudioManager.instance.playSfx('tile_monster');
        Haptic.heavy();
        await _askQuestion(me.id);
        break;

      case TileType.finish:
        await _checkFinishFor(me.id);
        break;
    }
  }

  Future<void> _askQuestion(String playerId) async {
    final me = state.players.firstWhere((p) => p.id == playerId);
    final difficulty = QuestionGenerator.difficultyFor(me.position);
    final q = _qgen.generate(difficulty);
    state = state.copyWith(
      status: GameStatus.awaitingQuestion,
      currentQuestion: q,
      currentQuestionPlayerId: playerId,
    );

    _questionCompleter = Completer<int>();

    if (me.isAi) {
      final ai = AiPlayer(difficulty: _aiDifficulty);
      await Future<void>.delayed(const Duration(milliseconds: 800));
      final pick = ai.chooseAnswer(q);
      if (!(_questionCompleter?.isCompleted ?? true)) {
        _questionCompleter!.complete(pick);
      }
    }

    final picked = await _questionCompleter!.future;
    await _resolveQuestion(picked);
  }

  /// Called by the UI when the user picks an option (or timeout fires with -1).
  void submitQuestionAnswer(int chosenIndex) {
    if (state.status != GameStatus.awaitingQuestion) return;
    if (!(_questionCompleter?.isCompleted ?? true)) {
      _questionCompleter!.complete(chosenIndex);
    }
  }

  Future<void> _resolveQuestion(int chosenIndex) async {
    final q = state.currentQuestion;
    final pid = state.currentQuestionPlayerId;
    if (q == null || pid == null) return;
    final isCorrect = chosenIndex == q.correctIndex;

    state = state.copyWith(clearQuestion: true, status: GameStatus.moving);

    if (isCorrect) {
      AudioManager.instance.playSfx('question_correct');
      Haptic.success();
      // Pass the monster: skip the tile by stepping +1.
      final me = state.players.firstWhere((p) => p.id == pid);
      await _game?.animateMove(me.id, 1);
      _patchPlayer(me.id, (p) => p.copyWith(position: (p.position + 1).clamp(1, GameConstants.boardTiles)));
      // Award coin to humans only.
      if (!me.isAi) {
        await ref
            .read(profileRepoProvider.notifier)
            .addCoins(GameConstants.coinsPerCorrectAnswer);
        await ref.read(profileRepoProvider.notifier).recordCorrectAnswer();
      }
      await _checkCollision(me.id);
      await _checkFinishFor(me.id);
    } else {
      AudioManager.instance.playSfx('question_wrong');
      AudioManager.instance.playSfx('back_home');
      Haptic.error();
      // Send back to home.
      await _game?.sendToTile(pid, 1);
      _patchPlayer(pid, (p) => p.copyWith(position: 1));
    }

    if (state.isGameOver) return;
    state = state.copyWith(status: GameStatus.idle);
    final value = state.lastDiceValue ?? 0;
    if (value == 6 && state.consecutiveSixes < GameConstants.maxConsecutiveSixes) {
      _maybeRunAi();
      return;
    }
    _nextTurn();
  }

  Future<void> _checkCollision(String moverId) async {
    final mover = state.players.firstWhere((p) => p.id == moverId);
    if (mover.position == 1 || mover.position == GameConstants.boardTiles) return;
    for (final other in state.players) {
      if (other.id == moverId) continue;
      if (other.isFinished) continue;
      if (other.position != mover.position) continue;

      // Shield consumes the hit.
      if (other.shieldActive && !other.hasUsedShield) {
        _patchPlayer(other.id, (p) => p.copyWith(hasUsedShield: true, shieldActive: false));
        AudioManager.instance.playSfx('power_use');
        Haptic.medium();
        continue;
      }

      AudioManager.instance.playSfx('collision');
      Haptic.heavy();
      AudioManager.instance.playSfx('back_home');

      if (mover.position < GameConstants.collisionThresholdTile) {
        await _game?.sendToTile(other.id, 1);
        _patchPlayer(other.id, (p) => p.copyWith(position: 1));
      } else {
        final newPos = (other.position - GameConstants.collisionLateRetreat).clamp(1, GameConstants.boardTiles);
        await _game?.sendToTile(other.id, newPos);
        _patchPlayer(other.id, (p) => p.copyWith(position: newPos));
      }
    }
  }

  Future<void> _checkFinishFor(String playerId) async {
    final me = state.players.firstWhere((p) => p.id == playerId);
    if (me.position >= GameConstants.boardTiles && !me.isFinished) {
      _patchPlayer(me.id, (p) => p.copyWith(isFinished: true, finalRank: state.finishOrder.length + 1));
      AudioManager.instance.playSfx('victory');
      Haptic.success();
      state = state.copyWith(finishOrder: [...state.finishOrder, me.id]);
      await _maybeEndGame();
    }
  }

  Future<void> _maybeEndGame() async {
    final remaining = state.players.where((p) => !p.isFinished).length;
    if (remaining <= 1) {
      // Auto-finish the last player.
      for (final p in state.players) {
        if (!p.isFinished) {
          _patchPlayer(p.id, (x) => x.copyWith(isFinished: true, finalRank: state.finishOrder.length + 1));
          state = state.copyWith(finishOrder: [...state.finishOrder, p.id]);
        }
      }
      state = state.copyWith(status: GameStatus.gameOver);
      await _awardCoinsAndStats();
    }
  }

  Future<void> _awardCoinsAndStats() async {
    final repo = ref.read(profileRepoProvider.notifier);
    await repo.recordGame();
    // Find human players and award based on rank.
    final humans = state.players.where((p) => !p.isAi).toList();
    if (humans.isEmpty) return;
    int rewardFor(int rank) {
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
    for (final h in humans) {
      final reward = rewardFor(h.finalRank ?? 4);
      if (reward > 0) await repo.addCoins(reward);
      if (h.finalRank == 1) await repo.recordWin();
    }
  }

  void _nextTurn() {
    if (state.isGameOver) return;
    int nextIdx = state.currentPlayerIndex;
    int safety = 0;
    do {
      nextIdx = (nextIdx + 1) % state.players.length;
      safety++;
    } while (state.players[nextIdx].isFinished && safety < state.players.length);
    state = state.copyWith(
      currentPlayerIndex: nextIdx,
      status: GameStatus.idle,
      consecutiveSixes: 0,
    );
    _maybeRunAi();
  }

  void _maybeRunAi() {
    final me = state.currentPlayer;
    if (!me.isAi) return;
    Future<void>.delayed(const Duration(milliseconds: 700), () async {
      if (state.status != GameStatus.idle) return;
      final ai = AiPlayer(difficulty: _aiDifficulty);
      final powerToUse = ai.choosePowerToUse(me, state.players.where((p) => p.id != me.id).toList());
      if (powerToUse != null) {
        await usePower(me.id, powerToUse);
      }
      await rollDice();
    });
  }

  Future<void> usePower(String playerId, PowerUp power) async {
    final me = state.players.firstWhere((p) => p.id == playerId);
    if (!me.powers.contains(power)) return;
    if (state.status != GameStatus.idle && state.status != GameStatus.awaitingPower) return;
    AudioManager.instance.playSfx('power_use');
    Haptic.medium();
    _consumePower(me.id, power);
    switch (power) {
      case PowerUp.shield:
        _patchPlayer(me.id, (p) => p.copyWith(shieldActive: true, hasUsedShield: false));
        break;
      case PowerUp.doubleDice:
        _patchPlayer(me.id, (p) => p.copyWith(doubleDiceNext: true));
        break;
      case PowerUp.skipQuestion:
        // Stays in inventory until the player lands on a monster — but we
        // already consumed it above. Re-add so the monster handler can pop.
        _patchPlayer(me.id, (p) => p.copyWith(powers: [...p.powers, PowerUp.skipQuestion]));
        break;
      case PowerUp.dash:
        await _game?.animateMove(me.id, GameConstants.dashForward);
        _patchPlayer(me.id, (p) => p.copyWith(position: (p.position + GameConstants.dashForward).clamp(1, GameConstants.boardTiles)));
        await _applyTileEffect(state.players.firstWhere((p) => p.id == me.id).position);
        break;
      case PowerUp.swap:
        final ahead = state.players
            .where((p) => p.id != me.id && !p.isFinished && p.position > me.position)
            .toList()
          ..sort((a, b) => a.position.compareTo(b.position));
        if (ahead.isNotEmpty) {
          final target = ahead.first;
          final tmp = me.position;
          await _game?.sendToTile(me.id, target.position);
          await _game?.sendToTile(target.id, tmp);
          _patchPlayer(me.id, (p) => p.copyWith(position: target.position));
          _patchPlayer(target.id, (p) => p.copyWith(position: tmp));
        }
        break;
      case PowerUp.jump:
        await _game?.animateMove(me.id, GameConstants.jumpForward);
        _patchPlayer(me.id, (p) => p.copyWith(position: (p.position + GameConstants.jumpForward).clamp(1, GameConstants.boardTiles)));
        await _applyTileEffect(state.players.firstWhere((p) => p.id == me.id).position);
        break;
    }
  }

  // ---------- helpers ----------
  void _patchPlayer(String id, Player Function(Player) f) {
    final updated = state.players.map((p) => p.id == id ? f(p) : p).toList();
    state = state.copyWith(players: updated);
  }

  void _consumePower(String id, PowerUp power) {
    _patchPlayer(id, (p) {
      final list = List<PowerUp>.from(p.powers);
      list.remove(power);
      return p.copyWith(powers: list);
    });
  }

  PowerUp? _grantRandomPower(String id) {
    final me = state.players.firstWhere((p) => p.id == id);
    if (me.powers.length >= GameConstants.maxPowersInBar) return null;
    final pool = PowerUp.values;
    final pick = pool[_r.nextInt(pool.length)];
    _patchPlayer(id, (p) => p.copyWith(powers: [...p.powers, pick]));
    return pick;
  }
}
