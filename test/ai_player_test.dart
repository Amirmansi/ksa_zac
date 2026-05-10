import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:egyptian_race/data/models/math_question.dart';
import 'package:egyptian_race/data/models/player.dart';
import 'package:egyptian_race/data/models/power_up.dart';
import 'package:egyptian_race/game_engine/ai/ai_player.dart';
import 'package:flutter/material.dart' show Colors;

void main() {
  const q = MathQuestion(
    text: '7 × 8 = ؟',
    options: [50, 56, 64, 48],
    correctIndex: 1,
    difficulty: QuestionDifficulty.easy,
  );

  test('hard AI is at least 70% correct over 200 trials (deterministic seed)', () {
    final ai = AiPlayer(difficulty: AiDifficulty.hard, random: Random(42));
    int correct = 0;
    for (int i = 0; i < 200; i++) {
      if (ai.chooseAnswer(q) == q.correctIndex) correct++;
    }
    expect(correct >= 140, true, reason: 'expected >=140/200, got $correct');
  });

  test('easy AI is roughly 30% correct (loose bounds)', () {
    final ai = AiPlayer(difficulty: AiDifficulty.easy, random: Random(42));
    int correct = 0;
    for (int i = 0; i < 400; i++) {
      if (ai.chooseAnswer(q) == q.correctIndex) correct++;
    }
    expect(correct >= 80 && correct <= 200, true,
        reason: 'easy AI got $correct/400 — outside [80, 200]');
  });

  test('medium AI prefers swap when very far behind', () {
    final ai = AiPlayer(difficulty: AiDifficulty.medium, random: Random(0));
    final me = Player(
      id: 'me', name: 'Me', characterId: 'fahlawy', color: Colors.blue,
      position: 5,
      powers: [PowerUp.swap, PowerUp.dash],
    );
    final ahead = Player(
      id: 'b', name: 'B', characterId: 'osta', color: Colors.green,
      position: 20,
    );
    final pick = ai.choosePowerToUse(me, [ahead]);
    expect(pick, PowerUp.swap);
  });

  test('AI does nothing when no manual powers in inventory', () {
    final ai = AiPlayer(difficulty: AiDifficulty.medium);
    final me = Player(
      id: 'me', name: 'Me', characterId: 'fahlawy', color: Colors.blue,
      position: 5, powers: [PowerUp.shield, PowerUp.skipQuestion],
    );
    final pick = ai.choosePowerToUse(me, []);
    expect(pick, isNull);
  });
}
