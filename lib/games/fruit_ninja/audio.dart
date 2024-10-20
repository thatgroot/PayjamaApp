import 'package:flame_audio/flame_audio.dart';

class AudioManager {
  static bool sound = true;
  static bool bgm = true;
  static Future<void> load() async {
    // Load sound effects and background music
    await FlameAudio.audioCache.loadAll([
      'fruit_ninja/bgm.mp3',
      "fruit_ninja/cut.wav",
    ]);
  }

  // Play brick hit sound
  static void playCut() {
    if (sound) {
      FlameAudio.play('fruit_ninja/cut.wav');
    }
  }

  // Play paddle hit sound
  static void clearAll() {
    FlameAudio.audioCache.clearAll();
  }

  // Play background music with looping
  static void playBgm() {
    if (AudioManager.bgm) {
      FlameAudio.bgm
          .play('fruit_ninja/bgm.mp3', volume: 0.5); // Volume can be adjusted
    }
  }

  // Stop background music
  static void stopBackgroundMusic() {
    FlameAudio.bgm.stop();
  }

  // Pause background music
  static void pauseBgm() {
    FlameAudio.bgm.pause();
  }

  // Resume background music
  static void resumeBgm() {
    FlameAudio.bgm.resume();
  }
}
