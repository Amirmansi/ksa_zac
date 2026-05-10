import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Colors;

import '../../core/colors.dart';
import '../../data/models/tile.dart';

class TileComponent extends PositionComponent {
  final Tile tile;
  late TextComponent _iconComponent;
  late TextComponent _idComponent;

  static const double _radius = 12;

  TileComponent({
    required this.tile,
    required Vector2 position,
    required double tileSize,
  }) : super(
          position: position,
          size: Vector2.all(tileSize),
          anchor: Anchor.topLeft,
        );

  @override
  Future<void> onLoad() async {
    if (tile.icon.isNotEmpty) {
      _iconComponent = TextComponent(
        text: tile.icon,
        anchor: Anchor.center,
        position: size / 2,
        textRenderer: TextPaint(
          style: TextStyle(fontSize: size.x * 0.42, color: Colors.white),
        ),
      );
      add(_iconComponent);
    }
    _idComponent = TextComponent(
      text: '${tile.id}',
      anchor: Anchor.bottomRight,
      position: Vector2(size.x - 4, size.y - 2),
      textRenderer: TextPaint(
        style: TextStyle(
          fontSize: 10,
          color: tile.type == TileType.normal
              ? AppColors.textSecondary
              : Colors.white.withOpacity(0.8),
        ),
      ),
    );
    add(_idComponent);
  }

  @override
  void render(Canvas canvas) {
    final rect = RRect.fromRectAndRadius(
      Offset.zero & size.toSize(),
      const Radius.circular(_radius),
    );
    final paint = Paint()..color = AppColors.tileColorFor(tile.type.name);
    canvas.drawRRect(rect, paint);

    final borderPaint = Paint()
      ..color = AppColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(rect, borderPaint);

    super.render(canvas);
  }
}
