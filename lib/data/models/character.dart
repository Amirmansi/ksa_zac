import 'package:flutter/material.dart' show Color;
import '../../core/colors.dart';
import '../../core/strings.dart';

class GameCharacter {
  final String id;
  final String name;
  final String description;
  final String ability;
  final String emoji;
  final Color color;
  final int price; // in coins; 0 means free / unlocked by default

  const GameCharacter({
    required this.id,
    required this.name,
    required this.description,
    required this.ability,
    required this.emoji,
    required this.color,
    this.price = 0,
  });

  static const fahlawy = GameCharacter(
    id: 'fahlawy',
    name: AppStrings.charFahlawy,
    description: AppStrings.charFahlawyDesc,
    ability: AppStrings.charFahlawyAbility,
    emoji: '🧢',
    color: AppColors.player1,
    price: 0,
  );

  static const osta = GameCharacter(
    id: 'osta',
    name: AppStrings.charOsta,
    description: AppStrings.charOstaDesc,
    ability: AppStrings.charOstaAbility,
    emoji: '🔧',
    color: AppColors.player2,
    price: 500,
  );

  static const sett = GameCharacter(
    id: 'sett',
    name: AppStrings.charSett,
    description: AppStrings.charSettDesc,
    ability: AppStrings.charSettAbility,
    emoji: '👜',
    color: AppColors.player3,
    price: 800,
  );

  static const hag = GameCharacter(
    id: 'hag',
    name: AppStrings.charHag,
    description: AppStrings.charHagDesc,
    ability: AppStrings.charHagAbility,
    emoji: '👴',
    color: AppColors.player4,
    price: 1000,
  );

  static const all = <GameCharacter>[fahlawy, osta, sett, hag];

  static GameCharacter byId(String id) =>
      all.firstWhere((c) => c.id == id, orElse: () => fahlawy);
}
