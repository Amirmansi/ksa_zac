import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart' show Color, Colors, Curves;

import '../../core/constants.dart';
import '../../data/models/tile.dart';
import '../board_layout.dart';

class PlayerToken extends PositionComponent {
  final String playerId;
  final Color color;
  final int slotIndex; // 0..3 — used to offset multiple tokens on same tile.
  int currentTile;
  final List<Tile> board;
  final Vector2 canvasSize;
  final void Function()? onStepArrived;

  static const double _radius = 14;

  PlayerToken({
    required this.playerId,
    required this.color,
    required this.slotIndex,
    required this.currentTile,
    required this.board,
    required this.canvasSize,
    this.onStepArrived,
  }) : super(
          size: Vector2.all(_radius * 2),
          anchor: Anchor.center,
          priority: 10,
        ) {
    position = _positionForTile(currentTile);
  }

  Vector2 _positionForTile(int tileId) {
    final tile = board.firstWhere((t) => t.id == tileId);
    final centre = BoardLayout.centerForTile(
      tile: tile,
      canvasSize: canvasSize,
      tileSize: GameConstants.tileSize,
      tileGap: GameConstants.tileGap,
    );
    final offsets = const [
      Offset(-9, -9),
      Offset(9, -9),
      Offset(-9, 9),
      Offset(9, 9),
    ];
    final off = offsets[slotIndex.clamp(0, 3)];
    return Vector2(centre.x + off.dx, centre.y + off.dy);
  }

  /// Animate to a tile in a single tween (used for big jumps / penalties).
  Future<void> moveToTile(int tileId, {Duration duration = const Duration(milliseconds: 400)}) async {
    final target = _positionForTile(tileId);
    currentTile = tileId;
    final controller = EffectController(duration: duration.inMilliseconds / 1000.0, curve: Curves.easeInOut);
    final effect = MoveEffect.to(target, controller);
    add(effect);
    await effect.removed;
  }

  /// Walks tile-by-tile (forward or backward) so each step can play SFX.
  Future<void> moveStepByStep(int delta, {Future<void> Function()? onStep}) async {
    if (delta == 0) return;
    final dir = delta > 0 ? 1 : -1;
    final steps = delta.abs();
    for (int i = 0; i < steps; i++) {
      final next = currentTile + dir;
      if (next < 1 || next > board.length) break;
      final target = _positionForTile(next);
      currentTile = next;
      final controller = EffectController(
        duration: GameConstants.moveAnimationMs / 1000.0,
        curve: Curves.easeOutCubic,
      );
      final effect = MoveEffect.to(target, controller);
      add(effect);
      await effect.removed;
      if (onStep != null) await onStep();
      onStepArrived?.call();
    }
  }

  @override
  void render(Canvas canvas) {
    final centre = Offset(_radius, _radius);
    canvas.drawCircle(
      centre.translate(0, 2),
      _radius,
      Paint()..color = const Color(0x33000000),
    );
    canvas.drawCircle(
      centre,
      _radius,
      Paint()..color = color,
    );
    canvas.drawCircle(
      centre,
      _radius,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
    super.render(canvas);
  }
}
