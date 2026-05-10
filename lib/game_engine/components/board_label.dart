import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Colors, FontWeight;

import '../../core/colors.dart';

class BoardLabel extends PositionComponent {
  final String text;
  final Color background;
  static const double _height = 28;

  BoardLabel({
    required this.text,
    required Vector2 position,
    this.background = AppColors.brand,
    double width = 100,
  }) : super(
          position: position,
          size: Vector2(width, _height),
          anchor: Anchor.center,
          priority: 5,
        );

  @override
  Future<void> onLoad() async {
    add(TextComponent(
      text: text,
      anchor: Anchor.center,
      position: size / 2,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 13,
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
      ),
    ));
  }

  @override
  void render(Canvas canvas) {
    final rect = RRect.fromRectAndRadius(
      Offset.zero & size.toSize(),
      const Radius.circular(10),
    );
    canvas.drawRRect(rect, Paint()..color = background);
    super.render(canvas);
  }
}
