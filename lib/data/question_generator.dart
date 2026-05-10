import 'dart:math';

import 'models/math_question.dart';

class QuestionGenerator {
  final Random _r;
  QuestionGenerator({Random? random}) : _r = random ?? Random();

  static QuestionDifficulty difficultyFor(int playerPosition) {
    if (playerPosition <= 10) return QuestionDifficulty.easy;
    if (playerPosition <= 20) return QuestionDifficulty.medium;
    return QuestionDifficulty.hard;
  }

  MathQuestion generate(QuestionDifficulty d) {
    int a = 0, b = 0;
    String op = '×';
    int correct = 0;
    switch (d) {
      case QuestionDifficulty.easy:
        a = _between(2, 9);
        b = _between(2, 9);
        op = '×';
        correct = a * b;
        break;
      case QuestionDifficulty.medium:
        a = _between(11, 19);
        b = _between(2, 9);
        op = '×';
        correct = a * b;
        break;
      case QuestionDifficulty.hard:
        if (_r.nextBool()) {
          a = _between(15, 30);
          b = _between(15, 30);
          op = '+';
          correct = a + b;
        } else {
          a = _between(15, 25);
          b = _between(3, 6);
          op = '×';
          correct = a * b;
        }
        break;
    }
    final options = _options(correct);
    final correctIdx = options.indexOf(correct);
    return MathQuestion(
      text: '$a $op $b = ؟',
      options: options,
      correctIndex: correctIdx,
      difficulty: d,
    );
  }

  int _between(int lo, int hi) => lo + _r.nextInt(hi - lo + 1);

  List<int> _options(int correct) {
    final set = <int>{correct};
    int safety = 0;
    while (set.length < 4 && safety++ < 50) {
      // Generate plausible distractors near the correct answer.
      final delta = _r.nextInt(20) - 10;
      final candidate = correct + delta;
      if (candidate > 0 && candidate != correct) set.add(candidate);
    }
    while (set.length < 4) {
      set.add(correct + set.length);
    }
    final list = set.toList()..shuffle(_r);
    return list;
  }
}
