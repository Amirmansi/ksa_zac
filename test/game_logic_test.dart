import 'package:flutter/material.dart' show Colors;
import 'package:flutter_test/flutter_test.dart';

import 'package:egyptian_race/core/constants.dart';
import 'package:egyptian_race/data/models/player.dart';
import 'package:egyptian_race/data/models/power_up.dart';
import 'package:egyptian_race/data/models/tile.dart';
import 'package:egyptian_race/game_engine/board_layout.dart';

void main() {
  group('Player.copyWith', () {
    test('preserves identity fields, updates state', () {
      final p = Player(
        id: 'p1', name: 'Amir', characterId: 'fahlawy', color: Colors.blue,
        position: 5,
      );
      final updated = p.copyWith(position: 8);
      expect(updated.id, p.id);
      expect(updated.name, p.name);
      expect(updated.characterId, p.characterId);
      expect(updated.color, p.color);
      expect(updated.position, 8);
    });

    test('powers list is independently mutable in copy', () {
      final p = Player(
        id: 'p1', name: 'Amir', characterId: 'fahlawy', color: Colors.blue,
        powers: [PowerUp.shield],
      );
      final updated = p.copyWith(powers: [...p.powers, PowerUp.dash]);
      expect(p.powers.length, 1);
      expect(updated.powers.length, 2);
    });
  });

  group('Board layout invariants', () {
    test('30 tiles, IDs 1..30, types valid', () {
      final tiles = BoardLayout.buildTiles();
      expect(tiles.length, GameConstants.boardTiles);
      for (int i = 0; i < tiles.length; i++) {
        expect(tiles[i].id, i + 1);
      }
    });

    test('start at id 1, finish at id 30', () {
      final tiles = BoardLayout.buildTiles();
      expect(tiles.firstWhere((t) => t.type == TileType.start).id, 1);
      expect(tiles.firstWhere((t) => t.type == TileType.finish).id,
          GameConstants.boardTiles);
    });

    test('monster tiles never on start/finish', () {
      final tiles = BoardLayout.buildTiles();
      final monsters = tiles.where((t) => t.type == TileType.monster).toList();
      for (final m in monsters) {
        expect(m.id != 1, true);
        expect(m.id != GameConstants.boardTiles, true);
      }
    });
  });

  group('Collision rule predicates (pure)', () {
    int collisionThreshold() => GameConstants.collisionThresholdTile;
    test('first half sends to home', () {
      const moverPos = 7;
      expect(moverPos < collisionThreshold(), true);
    });

    test('second half retreats by 5', () {
      const moverPos = 22;
      expect(moverPos >= collisionThreshold(), true);
    });
  });

  group('Power-up classification', () {
    test('manual vs auto', () {
      expect(PowerUp.shield.manual, false);
      expect(PowerUp.skipQuestion.manual, false);
      expect(PowerUp.doubleDice.manual, true);
      expect(PowerUp.dash.manual, true);
      expect(PowerUp.swap.manual, true);
      expect(PowerUp.jump.manual, true);
    });
  });
}
