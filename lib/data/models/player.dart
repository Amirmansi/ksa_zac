import 'package:flutter/material.dart';
import 'power_up.dart';

class Player {
  final String id;
  final String name;
  final String characterId;
  final Color color;
  final bool isAi;

  int position;
  bool isFinished;
  int? finalRank;
  List<PowerUp> powers;
  bool shieldActive;
  bool hasUsedShield;
  bool doubleDiceNext;

  Player({
    required this.id,
    required this.name,
    required this.characterId,
    required this.color,
    this.isAi = false,
    this.position = 1,
    this.isFinished = false,
    this.finalRank,
    List<PowerUp>? powers,
    this.shieldActive = false,
    this.hasUsedShield = false,
    this.doubleDiceNext = false,
  }) : powers = powers ?? <PowerUp>[];

  Player copyWith({
    int? position,
    bool? isFinished,
    int? finalRank,
    List<PowerUp>? powers,
    bool? shieldActive,
    bool? hasUsedShield,
    bool? doubleDiceNext,
  }) {
    return Player(
      id: id,
      name: name,
      characterId: characterId,
      color: color,
      isAi: isAi,
      position: position ?? this.position,
      isFinished: isFinished ?? this.isFinished,
      finalRank: finalRank ?? this.finalRank,
      powers: powers ?? List<PowerUp>.from(this.powers),
      shieldActive: shieldActive ?? this.shieldActive,
      hasUsedShield: hasUsedShield ?? this.hasUsedShield,
      doubleDiceNext: doubleDiceNext ?? this.doubleDiceNext,
    );
  }
}
