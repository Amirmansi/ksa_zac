enum TileType {
  start,
  normal,
  green,
  gold,
  purple,
  red,
  monster,
  finish,
}

class Tile {
  final int id;
  final TileType type;
  final int gridRow;
  final int gridCol;

  const Tile({
    required this.id,
    required this.type,
    required this.gridRow,
    required this.gridCol,
  });

  bool get isSpecial =>
      type != TileType.normal &&
      type != TileType.start &&
      type != TileType.finish;

  String get icon {
    switch (type) {
      case TileType.start:
        return '🏠';
      case TileType.green:
        return '🟢';
      case TileType.gold:
        return '⭐';
      case TileType.purple:
        return '🎲';
      case TileType.red:
        return '🚫';
      case TileType.monster:
        return '👹';
      case TileType.finish:
        return '🏁';
      case TileType.normal:
        return '';
    }
  }
}
