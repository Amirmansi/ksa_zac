import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:egyptian_race/core/constants.dart';
import 'package:egyptian_race/data/models/tile.dart';
import 'package:egyptian_race/game_engine/board_layout.dart';

void main() {
  test('builds 30 tiles with start + finish + special types', () {
    final tiles = BoardLayout.buildTiles();
    expect(tiles.length, GameConstants.boardTiles);
    expect(tiles.first.id, 1);
    expect(tiles.last.id, GameConstants.boardTiles);
    expect(tiles.first.type, TileType.start);
    expect(tiles.last.type, TileType.finish);
  });

  test('serpentine pattern: row 0 (bottom) goes right-to-left', () {
    final tiles = BoardLayout.buildTiles();
    // Row 0 holds tiles 1..5
    final row0 = tiles.where((t) => t.gridRow == 0).toList()
      ..sort((a, b) => a.id.compareTo(b.id));
    // Tile 1 should be the rightmost, tile 5 the leftmost.
    expect(row0.first.gridCol, GameConstants.gridCols - 1);
    expect(row0.last.gridCol, 0);
  });

  test('serpentine alternates: row 1 left-to-right', () {
    final tiles = BoardLayout.buildTiles();
    final row1 = tiles.where((t) => t.gridRow == 1).toList()
      ..sort((a, b) => a.id.compareTo(b.id));
    expect(row1.first.gridCol, 0);
    expect(row1.last.gridCol, GameConstants.gridCols - 1);
  });

  test('positionForTile produces non-overlapping tiles', () {
    final canvas = Vector2(400, 700);
    final tiles = BoardLayout.buildTiles();
    final seen = <String>{};
    for (final t in tiles) {
      final p = BoardLayout.positionForTile(
        tile: t,
        canvasSize: canvas,
        tileSize: GameConstants.tileSize,
        tileGap: GameConstants.tileGap,
      );
      final key = '${p.x.toStringAsFixed(1)},${p.y.toStringAsFixed(1)}';
      expect(seen.add(key), true);
    }
  });

  test('special tiles distribution matches BoardLayout._typeAssignments', () {
    final tiles = BoardLayout.buildTiles();
    final monsters = tiles.where((t) => t.type == TileType.monster).toList();
    final greens = tiles.where((t) => t.type == TileType.green).toList();
    final golds = tiles.where((t) => t.type == TileType.gold).toList();
    expect(monsters.length, 2);
    expect(greens.length, 3);
    expect(golds.length, 3);
  });
}
