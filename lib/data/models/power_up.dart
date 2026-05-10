enum PowerUp {
  shield,
  doubleDice,
  skipQuestion,
  dash,
  swap,
  jump,
}

extension PowerUpInfo on PowerUp {
  String get id => name;

  /// Manual = activated via tap; auto = triggered automatically.
  bool get manual {
    switch (this) {
      case PowerUp.shield:
      case PowerUp.skipQuestion:
        return false;
      case PowerUp.doubleDice:
      case PowerUp.dash:
      case PowerUp.swap:
      case PowerUp.jump:
        return true;
    }
  }

  String get arabicName {
    switch (this) {
      case PowerUp.shield:
        return 'درع';
      case PowerUp.doubleDice:
        return 'نرد مضمون';
      case PowerUp.skipQuestion:
        return 'تخطّي';
      case PowerUp.dash:
        return 'اندفاع';
      case PowerUp.swap:
        return 'تبادل';
      case PowerUp.jump:
        return 'قفزة';
    }
  }

  String get icon {
    switch (this) {
      case PowerUp.shield:
        return '🛡️';
      case PowerUp.doubleDice:
        return '🎲';
      case PowerUp.skipQuestion:
        return '⏭️';
      case PowerUp.dash:
        return '⚡';
      case PowerUp.swap:
        return '🔄';
      case PowerUp.jump:
        return '🚀';
    }
  }
}
