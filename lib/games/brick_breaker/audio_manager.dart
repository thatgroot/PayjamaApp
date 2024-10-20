import 'package:flame_audio/flame_audio.dart';

class AudioManager {
  static bool sound = true;
  static bool bgm = true;
  static Future<void> load() async {
    // Load sound effects and background music
    await FlameAudio.audioCache.loadAll([
      'brick_breaker/hit_paddle.wav',
      'brick_breaker/hit_bricks.wav',
      'brick_breaker/bgm.mp3',
      "brick_breaker/hurt7.wav",
    ]);
  }

  // Play paddle hit sound
  static void playHitPaddle() {
    if (sound) {
      FlameAudio.play('brick_breaker/hit_paddle.wav');
    }
  }

  static void playHitWall() {
    if (sound) {
      FlameAudio.play('brick_breaker/hurt7.wav');
    }
  }

  // Play brick hit sound
  static void playHitBrick() {
    if (sound) {
      FlameAudio.play('brick_breaker/hit_bricks.wav');
    }
  }

  static void playAll() {
    FlameAudio.play('brick_breaker/hit_paddle.wav');
    FlameAudio.play('brick_breaker/hit_bricks.wav');
  }

  // Play paddle hit sound
  static void clearAll() {
    FlameAudio.audioCache.clearAll();
  }

  // Play background music with looping
  static void playBackgroundMusic() {
    if (AudioManager.bgm) {
      FlameAudio.bgm
          .play('brick_breaker/bgm.mp3', volume: 0.5); // Volume can be adjusted
    }
  }

  // Stop background music
  static void stopBackgroundMusic() {
    FlameAudio.bgm.stop();
  }

  // Pause background music
  static void pauseBackgroundMusic() {
    FlameAudio.bgm.pause();
  }

  // Resume background music
  static void resumeBackgroundMusic() {
    FlameAudio.bgm.resume();
  }
}
