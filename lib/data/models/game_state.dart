import 'math_question.dart';
import 'player.dart';
import 'tile.dart';

enum GameStatus {
  idle,
  rolling,
  moving,
  awaitingPower,
  awaitingQuestion,
  showingResult,
  gameOver,
}

class GameState {
  final List<Player> players;
  final int currentPlayerIndex;
  final GameStatus status;
  final List<Tile> board;
  final int consecutiveSixes;
  final int? lastDiceValue;
  final MathQuestion? currentQuestion;
  final String? currentQuestionPlayerId;
  final List<String> finishOrder; // player ids in order of finishing

  const GameState({
    required this.players,
    required this.currentPlayerIndex,
    required this.status,
    required this.board,
    this.consecutiveSixes = 0,
    this.lastDiceValue,
    this.currentQuestion,
    this.currentQuestionPlayerId,
    this.finishOrder = const [],
  });

  Player get currentPlayer => players[currentPlayerIndex];

  bool get isGameOver => status == GameStatus.gameOver;

  GameState copyWith({
    List<Player>? players,
    int? currentPlayerIndex,
    GameStatus? status,
    List<Tile>? board,
    int? consecutiveSixes,
    int? lastDiceValue,
    bool clearLastDiceValue = false,
    MathQuestion? currentQuestion,
    bool clearQuestion = false,
    String? currentQuestionPlayerId,
    List<String>? finishOrder,
  }) {
    return GameState(
      players: players ?? this.players,
      currentPlayerIndex: currentPlayerIndex ?? this.currentPlayerIndex,
      status: status ?? this.status,
      board: board ?? this.board,
      consecutiveSixes: consecutiveSixes ?? this.consecutiveSixes,
      lastDiceValue:
          clearLastDiceValue ? null : (lastDiceValue ?? this.lastDiceValue),
      currentQuestion: clearQuestion ? null : (currentQuestion ?? this.currentQuestion),
      currentQuestionPlayerId:
          clearQuestion ? null : (currentQuestionPlayerId ?? this.currentQuestionPlayerId),
      finishOrder: finishOrder ?? this.finishOrder,
    );
  }
}
