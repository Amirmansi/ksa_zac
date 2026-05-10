import 'package:flutter_test/flutter_test.dart';

import 'package:egyptian_race/data/models/math_question.dart';
import 'package:egyptian_race/data/question_generator.dart';

void main() {
  final gen = QuestionGenerator();

  test('difficulty mapping by position', () {
    expect(QuestionGenerator.difficultyFor(1), QuestionDifficulty.easy);
    expect(QuestionGenerator.difficultyFor(10), QuestionDifficulty.easy);
    expect(QuestionGenerator.difficultyFor(11), QuestionDifficulty.medium);
    expect(QuestionGenerator.difficultyFor(20), QuestionDifficulty.medium);
    expect(QuestionGenerator.difficultyFor(21), QuestionDifficulty.hard);
    expect(QuestionGenerator.difficultyFor(30), QuestionDifficulty.hard);
  });

  test('question always has 4 options', () {
    for (int i = 0; i < 50; i++) {
      final q = gen.generate(QuestionDifficulty.easy);
      expect(q.options.length, 4);
      expect(q.options.toSet().length, 4, reason: 'options should be unique');
      expect(q.options[q.correctIndex] > 0, true);
    }
  });

  test('correct answer is always among options', () {
    for (final d in QuestionDifficulty.values) {
      for (int i = 0; i < 30; i++) {
        final q = gen.generate(d);
        expect(q.options.contains(q.correctAnswer), true);
        expect(q.correctIndex, q.options.indexOf(q.correctAnswer));
      }
    }
  });

  test('easy is single-digit multiplication only', () {
    for (int i = 0; i < 50; i++) {
      final q = gen.generate(QuestionDifficulty.easy);
      expect(q.text.contains('×'), true);
      // correct = a * b where each in [2,9] => correct in [4, 81]
      expect(q.correctAnswer >= 4 && q.correctAnswer <= 81, true);
    }
  });

  test('medium uses two-digit × single-digit', () {
    for (int i = 0; i < 50; i++) {
      final q = gen.generate(QuestionDifficulty.medium);
      expect(q.text.contains('×'), true);
      // a in [11,19], b in [2,9] => correct in [22, 171]
      expect(q.correctAnswer >= 22 && q.correctAnswer <= 171, true);
    }
  });
}
