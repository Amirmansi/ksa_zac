import 'dart:ui';

import 'package:flame/components.dart';

import '../../core/colors.dart';
import '../../core/constants.dart';
import '../../data/models/tile.dart';
import '../board_layout.dart';

/// Renders dashed connector lines between consecutive tiles to clearly mark
/// the snake path even before tokens move.
class PathDrawer extends PositionComponent {
  final List<Tile> tiles;
  final Vector2 canvasSize;

  PathDrawer({required this.tiles, required this.canvasSize})
      : super(priority: -1);

  @override
  void render(Canvas canvas) {
    if (tiles.length < 2) return;
    final paint = Paint()
      ..color = AppColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < tiles.length - 1; i++) {
      final from = BoardLayout.centerForTile(
        tile: tiles[i],
        canvasSize: canvasSize,
        tileSize: GameConstants.tileSize,
        tileGap: GameConstants.tileGap,
      );
      final to = BoardLayout.centerForTile(
        tile: tiles[i + 1],
        canvasSize: canvasSize,
        tileSize: GameConstants.tileSize,
        tileGap: GameConstants.tileGap,
      );
      _drawDashed(canvas, from.toOffset(), to.toOffset(), paint);
    }
  }

  void _drawDashed(Canvas c, Offset a, Offset b, Paint p) {
    const dash = 6.0;
    const gap = 4.0;
    final dx = b.dx - a.dx;
    final dy = b.dy - a.dy;
    final dist = (dx * dx + dy * dy);
    if (dist == 0) return;
    final length = (dist).abs().clamp(0, double.infinity);
    final stride = dash + gap;
    final total = (length).abs();
    // Use parametric drawing along (a, b)
    final dxNorm = dx / (total == 0 ? 1 : total);
    final dyNorm = dy / (total == 0 ? 1 : total);
    final lineLen = ((b - a).distance);
    double drawn = 0;
    while (drawn < lineLen) {
      final start = Offset(a.dx + dxNorm * drawn, a.dy + dyNorm * drawn);
      final end = Offset(
        a.dx + dxNorm * (drawn + dash).clamp(0, lineLen),
        a.dy + dyNorm * (drawn + dash).clamp(0, lineLen),
      );
      c.drawLine(start, end, p);
      drawn += stride;
    }
  }
}
