import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:hive/hive.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'package:pyjamaapp/services/hive.dart';

import 'dino_sprite_group.dart';
import '/widgets/hud.dart';
import '/models/settings.dart';
import 'audio_manager.dart';
import 'enemy_manager.dart';
import '/models/player_data.dart';
import '/widgets/pause_menu.dart';
import '/widgets/game_over_menu.dart';

// This is the main flame game class.
class PyjamaRunnerGame extends FlameGame
    with TapDetector, HasCollisionDetection {
  PyjamaRunnerGame({super.camera});

  // List of all the image assets.
  static const _imageAssets = [
    'pyjama/Sprite.png',
    'pyjama/cushion1.png',
    'pyjama/AngryPig/Walk (36x30).png',
    'pyjama/AngryPig/balloon.png',
    'pyjama/Bat/Flying (46x30).png',
    'pyjama/Rino/Run (52x34).png',
    'pyjama/Rino/bubble.png',
    'pyjama/Bat/bird1.png',
    'pyjama/parallax/plx-1.png',
    'pyjama/parallax/plx-2.png',
    'pyjama/parallax/plx-3.png',
    'pyjama/parallax/plx-4.png',
    'pyjama/parallax/plx-5.png',
    'pyjama/parallax/plx-6.png',
  ];

  // List of all the audio assets.
  static const _audioAssets = [
    'pyjama/8BitPlatformerLoop.wav',
    'pyjama/hurt7.wav',
    'pyjama/jump14.wav',
  ];

  late Dino _dino;
  late Settings settings;
  late PlayerData playerData;
  late EnemyManager _enemyManager;

  Vector2 get virtualSize => camera.viewport.virtualSize;

  // This method get called while flame is preparing this game.
  @override
  Future<void> onLoad() async {
    // Makes the game full screen and landscape only.
    await Flame.device.fullScreen();
    await Flame.device.setLandscape();

    /// Read [PlayerData] and [Settings] from hive.
    playerData = await _readPlayerData();
    settings = await _readSettings();

    /// Initilize [AudioManager].
    await AudioManager.instance.init(_audioAssets, settings);

    // Start playing background music. Internally takes care
    // of checking user settings.
    AudioManager.instance.startBgm('pyjama/8BitPlatformerLoop.wav');

    // Cache all the images.
    await images.loadAll(_imageAssets);

    // This makes the camera look at the center of the viewport.
    camera.viewfinder.position = camera.viewport.virtualSize * 0.5;

    /// Create a [ParallaxComponent] and add it to game.
    final parallaxBackground = await loadParallaxComponent(
      [
        ParallaxImageData('pyjama/parallax/new/0.png'),
        ParallaxImageData('pyjama/parallax/new/1.png'),
        ParallaxImageData('pyjama/parallax/new/2.png'),
        ParallaxImageData('pyjama/parallax/new/3.png'),
        ParallaxImageData('pyjama/parallax/new/4.png'),
        ParallaxImageData('pyjama/parallax/new/5.png'),
        ParallaxImageData('pyjama/parallax/new/6.png'),
      ],
      baseVelocity: Vector2(10, 0),
      velocityMultiplierDelta: Vector2(1.4, 0),
    );

    // Add the parallax as the backdrop.
    camera.backdrop.add(parallaxBackground);
  }

  /// This method add the already created [Dino]
  /// and [EnemyManager] to this game.
  void startGamePlay() {
    _dino = Dino(images.fromCache('pyjama/Sprite.png'), playerData);
    _enemyManager = EnemyManager();

    world.add(_dino);
    world.add(_enemyManager);
  }

  // This method remove all the actors from the game.
  void _disconnectActors() {
    _dino.removeFromParent();
    _enemyManager.removeAllEnemies();
    _enemyManager.removeFromParent();
  }

  // This method reset the whole game world to initial state.
  void reset() {
    // First disconnect all actions from game world.
    _disconnectActors();

    // Reset player data to inital values.
    playerData.currentScore = 0;
    playerData.lives = 5;
  }

  // This method gets called for each tick/frame of the game.
  @override
  void update(double dt) {
    // If number of lives is 0 or less, game is over.
    if (playerData.lives <= 0) {
      overlays.add(GameOverMenu.id);
      overlays.remove(Hud.id);
      HiveService.getCurrentGameScore().then((value) {
        int score = value;
        HiveService.setGameScore(
          GameNames.runner,
          score + playerData.highScore,
        );
      });
      pauseEngine();
      AudioManager.instance.pauseBgm();
    }
    super.update(dt);
  }

  // This will get called for each tap on the screen.
  @override
  void onTapDown(TapDownInfo info) {
    // Make dino jump only when game is playing.
    // When game is in playing state, only Hud will be the active overlay.
    if (overlays.isActive(Hud.id)) {
      _dino.jump();
    }
    super.onTapDown(info);
  }

  /// This method reads [PlayerData] from the hive box.
  Future<PlayerData> _readPlayerData() async {
    final playerDataBox =
        await Hive.openBox<PlayerData>('DinoRun.PlayerDataBox');
    final playerData = playerDataBox.get('DinoRun.PlayerData');

    // If data is null, this is probably a fresh launch of the game.
    if (playerData == null) {
      // In such cases store default values in hive.
      await playerDataBox.put('DinoRun.PlayerData', PlayerData());
    }

    // Now it is safe to return the stored value.
    return playerDataBox.get('DinoRun.PlayerData')!;
  }

  /// This method reads [Settings] from the hive box.
  Future<Settings> _readSettings() async {
    final settingsBox = await Hive.openBox<Settings>('DinoRun.SettingsBox');
    final settings = settingsBox.get('DinoRun.Settings');

    // If data is null, this is probably a fresh launch of the game.
    if (settings == null) {
      // In such cases store default values in hive.
      await settingsBox.put(
        'DinoRun.Settings',
        Settings(bgm: true, sfx: true),
      );
    }

    // Now it is safe to return the stored value.
    return settingsBox.get('DinoRun.Settings')!;
  }

  @override
  void lifecycleStateChange(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // On resume, if active overlay is not PauseMenu,
        // resume the engine (lets the parallax effect play).
        if (!(overlays.isActive(PauseMenu.id)) &&
            !(overlays.isActive(GameOverMenu.id))) {
          resumeEngine();
        }
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        // If game is active, then remove Hud and add PauseMenu
        // before pausing the game.
        if (overlays.isActive(Hud.id)) {
          overlays.remove(Hud.id);
          overlays.add(PauseMenu.id);
        }
        pauseEngine();
        break;
    }
    super.lifecycleStateChange(state);
  }
}
