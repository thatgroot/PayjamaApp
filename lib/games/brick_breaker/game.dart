import 'dart:developer';

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:provider/provider.dart';
import 'package:pyjamaapp/providers/game.dart';
import 'package:pyjamaapp/screens/games.dart';
import 'package:pyjamaapp/services/context_utility.dart';
import 'package:pyjamaapp/services/hive.dart';
import 'package:pyjamaapp/utils/navigation.dart';
import 'package:pyjamaapp/widgets/app/sections/game_settings_popup.dart';
import 'paddle.dart';
import 'ball.dart';
import 'brick.dart';
import 'audio_manager.dart';
import 'package:flutter/material.dart';

class BrickBreakerGame extends FlameGame
    with HasCollisionDetection, TapCallbacks {
  late Paddle paddle;
  late Ball ball;
  final List<Brick> bricks = [];
  final BuildContext context;
  int score = 0;
  int level = 1;
  // late TextComponent levelText;
  bool isPaused = false;

  BrickBreakerGame(this.context);

  @override
  Future<void> onLoad() async {
    await AudioManager.load();

    final bgImage = await Flame.images.load('app/background.png');
    add(SpriteComponent(sprite: Sprite(bgImage), size: size));

    ball = Ball(onBrickDestroyed: onBrickDestroyed)..anchor = Anchor.center;
    add(ball);

    paddle = Paddle(ball: ball)
      ..position = Vector2(size.x / 2, size.y - 50)
      ..anchor = Anchor.center;

    add(paddle);

    ball.position =
        Vector2(paddle.x, paddle.y - paddle.size.y / 2 - ball.size.y / 2 - 2);

    addBricks();
    // addScoreText();
    // addLevelText();
  }

  void addBricks() {
    const int brickColumns = 6;
    const int brickRows = 6;

    const double brickWidth = 58;
    const double brickHeight = 28;
    const double topPadding = 100;
    const double leftPadding = 10;

    for (int i = 0; i < brickColumns; i++) {
      for (int j = 0; j < brickRows; j++) {
        final brick = Brick()
          ..position = Vector2(
            leftPadding + i * brickWidth,
            topPadding + j * brickHeight,
          )
          ..anchor = Anchor.topLeft;
        bricks.add(brick);
        add(brick);
      }
    }
  }

  void togglePause() {
    isPaused = !isPaused;
    if (isPaused) {
      pauseEngine();
    } else {
      resumeEngine();
    }
  }

  void onBrickDestroyed() {
    score += 10;
    log("bricks destroyed called ${bricks.length}");
    final gameProvider = Provider.of<BrickBreakerGameProvider>(
        ContextUtility.context!,
        listen: false);
    gameProvider.update(score);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // var level = provider.level;
    if (ball.isOffScreen(size)) {
      pauseEngine();
      HiveService.saveCurrentGameScore(score);
      AudioManager.pauseBackgroundMusic();
      showGameOverPopup();
    }
  }

  void showLevelCompletePopup() {
    // updateScoreText();
    final gameProvider = Provider.of<BrickBreakerGameProvider>(
      ContextUtility.context!,
      listen: false,
    );
    pauseEngine();

    HiveService.saveCurrentGameScore(score);
    AudioManager.pauseBackgroundMusic();
    gameProvider.updateLevel(
      name: GameNames.brickBreaker,
      currentLevel: level + 1,
      oldLevel: level,
      oldScore: score,
    );

    level += 1;
    score = 0;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return GameSettingsPopup(
          gameCompleted: true,
          gameInfo: true,
          label: "Level Complete",
          onExit: () {
            Navigator.of(dialogContext).pop();
            resetGame();
          },
          actions: [
            SettingActionItem(
              buttonImage: Image.asset("assets/images/app/next.png"),
              action: () {
                Navigator.of(dialogContext).pop();
                resetGameForNextLevel();
                AudioManager.resumeBackgroundMusic();
              },
            ),
            SettingActionItem(
              buttonImage: Image.asset("assets/images/app/exit.png"),
              action: () {
                AudioManager.stopBackgroundMusic();
                to(ContextUtility.context!, GamesScreen.route);
              },
            ),
          ],
        );
      },
    );
  }

  void showGameOverPopup() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return GameSettingsPopup(
          gameInfo: true,
          label: "Game Over",
          onExit: () {
            Navigator.of(dialogContext).pop();
            resetGame();
          },
          actions: [
            SettingActionItem(
              buttonImage: Image.asset("assets/images/app/continue.png"),
              action: () {
                resetGame();
                AudioManager.resumeBackgroundMusic();
                Navigator.of(dialogContext).pop();
              },
            ),
            SettingActionItem(
              buttonImage: Image.asset("assets/images/app/exit.png"),
              action: () {
                to(ContextUtility.context!, GamesScreen.route);
              },
            ),
          ],
        );
      },
    );
  }

  void resetGameForNextLevel() {
    log("next resetGameForNextLevel");
    // updateScoreText();

    bricks.clear();
    removeAll(children);
    onLoad();
    resumeEngine();
    isPaused = false;
  }

  void resetGame() {
    final gameProvider = Provider.of<BrickBreakerGameProvider>(
        ContextUtility.context!,
        listen: false);
    gameProvider.resetScore();

    score = 0;
    level = 1;
    bricks.clear();
    removeAll(children);
    onLoad();
    resumeEngine();
    isPaused = false;
  }
}
