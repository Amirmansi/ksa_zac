import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';

/// Wraps flame_audio. Resilient to missing files (Phase 1 ships without
/// real audio; placeholders log instead of crashing so QA can keep moving).
class AudioManager {
  AudioManager._();
  static final instance = AudioManager._();

  bool _ready = false;
  bool _soundEnabled = true;
  bool _musicEnabled = true;
  double _volume = 0.7;
  bool _musicPlaying = false;

  static const Map<String, String> _sfx = {
    'dice_roll': 'sfx/dice_roll.mp3',
    'dice_stop': 'sfx/dice_stop.mp3',
    'move_step': 'sfx/move_step.mp3',
    'tile_green': 'sfx/tile_green.mp3',
    'tile_gold': 'sfx/tile_gold.mp3',
    'tile_purple': 'sfx/tile_purple.mp3',
    'tile_red': 'sfx/tile_red.mp3',
    'tile_monster': 'sfx/tile_monster.mp3',
    'question_correct': 'sfx/question_correct.mp3',
    'question_wrong': 'sfx/question_wrong.mp3',
    'back_home': 'sfx/back_home.mp3',
    'collision': 'sfx/collision.mp3',
    'victory': 'sfx/victory.mp3',
    'timer_tick': 'sfx/timer_tick.mp3',
    'button_tap': 'sfx/button_tap.mp3',
    'power_use': 'sfx/power_use.mp3',
  };

  static const String _bgMusic = 'music/bg_music.mp3';

  Future<void> init({
    bool soundEnabled = true,
    bool musicEnabled = true,
    double volume = 0.7,
  }) async {
    if (_ready) return;
    _soundEnabled = soundEnabled;
    _musicEnabled = musicEnabled;
    _volume = volume;
    // Load each individually so a missing one doesn't kill the whole batch.
    for (final entry in _sfx.entries) {
      try {
        await FlameAudio.audioCache.load(entry.value);
      } catch (e) {
        _logMissing('preload:${entry.key}', e);
      }
    }
    _ready = true;
  }

  void setSoundEnabled(bool v) => _soundEnabled = v;
  void setMusicEnabled(bool v) {
    _musicEnabled = v;
    if (!v && _musicPlaying) stopMusic();
    if (v && !_musicPlaying) playMusic();
  }
  void setVolume(double v) {
    _volume = v.clamp(0.0, 1.0);
    if (_musicPlaying) {
      try {
        // The bgm player exposes audioPlayer in Flame Audio.
        // ignore: deprecated_member_use
        FlameAudio.bgm.audioPlayer.setVolume(_volume * 0.4);
      } catch (_) {}
    }
  }

  Future<void> playSfx(String name) async {
    if (!_soundEnabled) return;
    final path = _sfx[name];
    if (path == null) return;
    try {
      await FlameAudio.play(path, volume: _volume);
    } catch (e) {
      _logMissing('sfx:$name', e);
    }
  }

  Future<void> playMusic() async {
    if (!_musicEnabled || _musicPlaying) return;
    try {
      await FlameAudio.bgm.play(_bgMusic, volume: _volume * 0.4);
      _musicPlaying = true;
    } catch (e) {
      _logMissing('music', e);
    }
  }

  Future<void> stopMusic() async {
    try {
      await FlameAudio.bgm.stop();
    } catch (_) {}
    _musicPlaying = false;
  }

  void _logMissing(String tag, Object e) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('[AudioManager] $tag fallback (asset missing): $e');
    }
  }
}
