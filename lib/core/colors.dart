import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Backgrounds
  static const bgPrimary = Color(0xFFFAF7F0);
  static const bgSecondary = Color(0xFFFFFFFF);
  static const bgAccent = Color(0xFFFCEFD5);

  // Text
  static const textPrimary = Color(0xFF2C2C2A);
  static const textSecondary = Color(0xFF5F5E5A);
  static const textOnDark = Color(0xFFFAF7F0);

  // Tiles
  static const tileNormal = Color(0xFFF1F0EA);
  static const tileGreen = Color(0xFF97C459);
  static const tileGold = Color(0xFFF1C40F);
  static const tilePurple = Color(0xFF9B5DBF);
  static const tileRed = Color(0xFFE24B4A);
  static const tileMonster = Color(0xFFA32D2D);

  // Players
  static const player1 = Color(0xFF378ADD);
  static const player2 = Color(0xFF3B9F6F);
  static const player3 = Color(0xFFE8A33D);
  static const player4 = Color(0xFF9B5DBF);

  // Frame
  static const border = Color(0xFFD3D1C7);

  // Game endpoints
  static const home = Color(0xFF888780);
  static const finish = Color(0xFF3B9F6F);

  // Brand
  static const brand = Color(0xFFC97B3D);
  static const brandDark = Color(0xFF8B4513);

  // Status
  static const success = Color(0xFF3B9F6F);
  static const warning = Color(0xFFF1C40F);
  static const error = Color(0xFFE24B4A);

  // Coins
  static const coinGold = Color(0xFFE8A33D);

  static const List<Color> playerPalette = [player1, player2, player3, player4];

  static Color tileColorFor(String type) {
    switch (type) {
      case 'green':
        return tileGreen;
      case 'gold':
        return tileGold;
      case 'purple':
        return tilePurple;
      case 'red':
        return tileRed;
      case 'monster':
        return tileMonster;
      case 'start':
        return home;
      case 'finish':
        return finish;
      default:
        return tileNormal;
    }
  }
}
