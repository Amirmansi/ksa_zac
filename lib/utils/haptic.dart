import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

class Haptic {
  Haptic._();
  static bool _enabled = true;
  static bool? _hasCustomVibrator;

  static void setEnabled(bool v) => _enabled = v;

  static Future<bool> _hasVibrator() async {
    _hasCustomVibrator ??= (await Vibration.hasVibrator()) ?? false;
    return _hasCustomVibrator!;
  }

  static Future<void> light() async {
    if (!_enabled) return;
    HapticFeedback.lightImpact();
  }

  static Future<void> medium() async {
    if (!_enabled) return;
    HapticFeedback.mediumImpact();
  }

  static Future<void> heavy() async {
    if (!_enabled) return;
    HapticFeedback.heavyImpact();
  }

  static Future<void> selection() async {
    if (!_enabled) return;
    HapticFeedback.selectionClick();
  }

  static Future<void> success() async {
    if (!_enabled) return;
    if (await _hasVibrator()) {
      Vibration.vibrate(pattern: const [0, 60, 80, 60]);
    } else {
      HapticFeedback.mediumImpact();
    }
  }

  static Future<void> error() async {
    if (!_enabled) return;
    if (await _hasVibrator()) {
      Vibration.vibrate(pattern: const [0, 100, 60, 100, 60, 100]);
    } else {
      HapticFeedback.heavyImpact();
    }
  }
}
