import 'dart:math';

import '../../data/models/math_question.dart';
import '../../data/models/player.dart';
import '../../data/models/power_up.dart';

enum AiDifficulty { easy, medium, hard }

class AiPlayer {
  final AiDifficulty difficulty;
  final Random _r;

  AiPlayer({required this.difficulty, Random? random}) : _r = random ?? Random();

  /// Probability the AI answers the math question correctly.
  double get _correctness {
    switch (difficulty) {
      case AiDifficulty.easy:
        return 0.30;
      case AiDifficulty.medium:
        return 0.60;
      case AiDifficulty.hard:
        return 0.85;
    }
  }

  /// Pick which option to choose for a given math question.
  int chooseAnswer(MathQuestion q) {
    if (_r.nextDouble() < _correctness) return q.correctIndex;
    int wrong = _r.nextInt(q.options.length);
    if (wrong == q.correctIndex) {
      wrong = (wrong + 1) % q.options.length;
    }
    return wrong;
  }

  /// Decide whether (and which) manual power to use BEFORE rolling.
  PowerUp? choosePowerToUse(Player me, List<Player> others) {
    if (me.powers.isEmpty) return null;
    final manuals = me.powers.where((p) => p.manual).toList();
    if (manuals.isEmpty) return null;

    switch (difficulty) {
      case AiDifficulty.easy:
        // 25% of the time, randomly fire something.
        if (_r.nextDouble() < 0.25) {
          return manuals[_r.nextInt(manuals.length)];
        }
        return null;

      case AiDifficulty.medium:
      case AiDifficulty.hard:
        // Smarter: prioritise jump/dash if behind, swap if WAY behind.
        final myPos = me.position;
        final maxOpponent = others
            .where((p) => !p.isFinished)
            .map((p) => p.position)
            .fold<int>(myPos, (a, b) => a > b ? a : b);
        final gap = maxOpponent - myPos;

        if (gap >= 8 && manuals.contains(PowerUp.swap)) return PowerUp.swap;
        if (gap >= 5 && manuals.contains(PowerUp.jump)) return PowerUp.jump;
        if (gap >= 3 && manuals.contains(PowerUp.dash)) return PowerUp.dash;
        if (gap >= 2 && manuals.contains(PowerUp.doubleDice)) return PowerUp.doubleDice;
        // Hard AI also fires opportunistically.
        if (difficulty == AiDifficulty.hard &&
            myPos > 20 &&
            manuals.contains(PowerUp.jump)) {
          return PowerUp.jump;
        }
        return null;
    }
  }
}
