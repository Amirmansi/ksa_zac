import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart' show Color;

import '../core/colors.dart';
import '../core/constants.dart';
import '../data/models/player.dart';
import '../data/models/tile.dart';
import 'board_layout.dart';
import 'components/board_label.dart';
import 'components/path_drawer.dart';
import 'components/player_token.dart';
import 'components/tile_component.dart';

/// Pure-render game canvas. Game state and player movement is owned by
/// [GameController] (Riverpod) — this class just exposes hooks that the
/// controller calls into.
class RaceGame extends FlameGame {
  late List<Tile> tiles;
  final Map<String, PlayerToken> _tokens = {};

  /// The board re-builds itself if the canvas size changes (e.g. orientation),
  /// so we keep a reference to the players to know how to redraw tokens.
  List<Player> players;

  RaceGame({this.players = const []}) {
    tiles = BoardLayout.buildTiles();
  }

  @override
  Color backgroundColor() => AppColors.bgPrimary;

  @override
  Future<void> onLoad() async {
    await _layout();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (children.isNotEmpty) {
      removeAll(children.toList());
      _layout();
    }
  }

  Future<void> _layout() async {
    final canvas = size;
    final tileComponents = <Component>[];
    for (final t in tiles) {
      final pos = BoardLayout.positionForTile(
        tile: t,
        canvasSize: canvas,
        tileSize: GameConstants.tileSize,
        tileGap: GameConstants.tileGap,
      );
      tileComponents.add(TileComponent(
        tile: t,
        position: pos,
        tileSize: GameConstants.tileSize,
      ));
    }

    addAll(<Component>[
      PathDrawer(tiles: tiles, canvasSize: canvas),
      ...tileComponents,
      BoardLabel(
        text: 'بر الأمان 🏁',
        position: _labelPositionForTile(30, canvas, above: true),
        background: AppColors.success,
        width: 110,
      ),
      BoardLabel(
        text: 'البيت 🏠',
        position: _labelPositionForTile(1, canvas, above: false),
        width: 90,
      ),
    ]);

    for (int i = 0; i < players.length; i++) {
      final p = players[i];
      final token = PlayerToken(
        playerId: p.id,
        color: p.color,
        slotIndex: i,
        currentTile: p.position,
        board: tiles,
        canvasSize: canvas,
      );
      _tokens[p.id] = token;
      add(token);
    }
  }

  Vector2 _labelPositionForTile(int tileId, Vector2 canvas, {required bool above}) {
    final tile = tiles.firstWhere((t) => t.id == tileId);
    final centre = BoardLayout.centerForTile(
      tile: tile,
      canvasSize: canvas,
      tileSize: GameConstants.tileSize,
      tileGap: GameConstants.tileGap,
    );
    final dy = (GameConstants.tileSize / 2 + 22) * (above ? -1 : 1);
    return Vector2(centre.x, centre.y + dy);
  }

  PlayerToken? tokenFor(String playerId) => _tokens[playerId];

  Future<void> animateMove(
    String playerId,
    int delta, {
    Future<void> Function()? onStep,
  }) async {
    final token = _tokens[playerId];
    if (token == null) return;
    await token.moveStepByStep(delta, onStep: onStep);
  }

  Future<void> sendToTile(String playerId, int tileId) async {
    final token = _tokens[playerId];
    if (token == null) return;
    await token.moveToTile(tileId);
  }

  void replacePlayers(List<Player> newPlayers) {
    players = newPlayers;
    removeAll(children.toList());
    _layout();
  }
}
