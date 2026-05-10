import 'package:flame/components.dart';

import '../core/constants.dart';
import '../data/models/tile.dart';

/// Builds the 30-tile serpentine board.
///
/// Tile 1 sits at bottom-right; rows alternate direction so the path snakes
/// upward in an "S" pattern. Tile 30 sits at top-right.
class BoardLayout {
  BoardLayout._();

  /// Static deterministic distribution. Total of 30 tiles.
  /// Tweak counts here without touching renderer code.
  static const Map<TileType, List<int>> _typeAssignments = {
    TileType.start: [1],
    TileType.green: [4, 11, 19],
    TileType.gold: [7, 16, 24],
    TileType.purple: [13, 26],
    TileType.red: [9, 22],
    TileType.monster: [15, 28],
    TileType.finish: [30],
  };

  static List<Tile> buildTiles() {
    final tiles = <Tile>[];
    for (int id = 1; id <= GameConstants.boardTiles; id++) {
      final row = ((id - 1) ~/ GameConstants.gridCols);
      final indexInRow = (id - 1) % GameConstants.gridCols;
      // Row 0 = bottom row, going right-to-left from the player's perspective.
      // We alternate direction every row.
      final goingLeft = row.isEven;
      final col = goingLeft
          ? (GameConstants.gridCols - 1 - indexInRow)
          : indexInRow;
      tiles.add(Tile(id: id, type: _typeFor(id), gridRow: row, gridCol: col));
    }
    return tiles;
  }

  static TileType _typeFor(int id) {
    for (final entry in _typeAssignments.entries) {
      if (entry.value.contains(id)) return entry.key;
    }
    return TileType.normal;
  }

  /// Computes the canvas position for a tile given the playable area size.
  /// Origin (0,0) = top-left of the canvas.
  static Vector2 positionForTile({
    required Tile tile,
    required Vector2 canvasSize,
    required double tileSize,
    required double tileGap,
  }) {
    final boardWidth = GameConstants.gridCols * tileSize +
        (GameConstants.gridCols - 1) * tileGap;
    final boardHeight = GameConstants.gridRows * tileSize +
        (GameConstants.gridRows - 1) * tileGap;
    final originX = (canvasSize.x - boardWidth) / 2;
    final originY = (canvasSize.y - boardHeight) / 2;

    final x = originX + tile.gridCol * (tileSize + tileGap);
    // Bottom-up: row 0 is the bottom row.
    final yFromBottom = tile.gridRow * (tileSize + tileGap);
    final y = originY + boardHeight - tileSize - yFromBottom;
    return Vector2(x, y);
  }

  /// Returns the centre of a tile (used for player tokens).
  static Vector2 centerForTile({
    required Tile tile,
    required Vector2 canvasSize,
    required double tileSize,
    required double tileGap,
  }) {
    final p = positionForTile(
      tile: tile,
      canvasSize: canvasSize,
      tileSize: tileSize,
      tileGap: tileGap,
    );
    return Vector2(p.x + tileSize / 2, p.y + tileSize / 2);
  }
}
