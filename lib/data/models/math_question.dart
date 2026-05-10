enum QuestionDifficulty { easy, medium, hard }

class MathQuestion {
  final String text;
  final List<int> options;
  final int correctIndex;
  final QuestionDifficulty difficulty;

  const MathQuestion({
    required this.text,
    required this.options,
    required this.correctIndex,
    required this.difficulty,
  });

  int get correctAnswer => options[correctIndex];

  bool isCorrect(int chosenIndex) => chosenIndex == correctIndex;
}
