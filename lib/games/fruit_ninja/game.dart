import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pyjamaapp/games/fruit_ninja/config/app_config.dart';
import 'package:pyjamaapp/games/fruit_ninja/models/fruit_model.dart';
import 'package:pyjamaapp/games/fruit_ninja/routes/game_over_page.dart';
import 'package:pyjamaapp/games/fruit_ninja/routes/game_page.dart';
import 'package:pyjamaapp/games/fruit_ninja/routes/home_page.dart';
import 'package:pyjamaapp/providers/game.dart';
import 'package:pyjamaapp/screens/games.dart';
import 'package:pyjamaapp/services/context_utility.dart';
import 'package:flame/src/components/route.dart' as flame_router;
import 'package:pyjamaapp/utils/navigation.dart';
import 'package:pyjamaapp/widgets/app/sections/game_settings_popup.dart';

class FruitNinjaGame extends FlameGame {
  late RouterComponent router;
  late double maxVerticalVelocity;
  bool isPaused = false;

  final List<FruitModel> fruits = [
    FruitModel(image: "fruit_ninja/apple.png"),
    FruitModel(image: "fruit_ninja/banana.png"),
    FruitModel(image: "fruit_ninja/kiwi.png"),
    FruitModel(image: "fruit_ninja/orange.png"),
    FruitModel(image: "fruit_ninja/peach.png"),
    FruitModel(image: "fruit_ninja/pineapple.png"),
    FruitModel(image: "app/pcoin.png"),
    FruitModel(image: "fruit_ninja/bomb.png", isBomb: true),
  ];

  void togglePause() {
    isPaused = !isPaused;
    if (isPaused) {
      pauseEngine();
    } else {
      resumeEngine();
    }
  }

  void resetGame() {
    final gameProvider = Provider.of<FruitNinjaGameProvider>(
        ContextUtility.context!,
        listen: false);
    gameProvider.resetScore();
    removeAll(children);
    onLoad();
    resumeEngine();
    isPaused = false;
  }

  @override
  void onLoad() async {
    super.onLoad();

    for (final fruit in fruits) {
      await images.load(fruit.image);
    }

    router = RouterComponent(initialRoute: 'home', routes: {
      'home': flame_router.Route(HomePage.new),
      'game-page': flame_router.Route(GamePage.new),
      // 'pause': PauseRoute(),
      'game-over': GameOverRoute()
    });
    addAll([
      ParallaxComponent(
          parallax: Parallax([
        await ParallaxLayer.load(ParallaxImageData('fruit_ninja/bg.png'))
      ])),
      router
    ]);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    getMaxVerticalVelocity(size);
  }

  void getMaxVerticalVelocity(Vector2 size) {
    maxVerticalVelocity = sqrt(2 *
        (AppConfig.gravity.abs() + AppConfig.acceleration.abs()) *
        (size.y - AppConfig.objSize * 2));
  }

  void showGameCompletedOverlay() {
    isPaused = true;
    showDialog(
      context: ContextUtility.context!,
      builder: (dialogContext) {
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
                resetGame();
              },
            ),
            SettingActionItem(
              buttonImage: Image.asset("assets/images/app/exit.png"),
              action: () {
                Navigator.of(dialogContext).pop();
                to(ContextUtility.context!, GamesScreen.route);
              },
            ),
          ],
        );
      },
    );
  }

  void showGamePauseOverlay() {
    showDialog(
      context: ContextUtility.context!,
      builder: (dialogContext) {
        return GameSettingsPopup(
          gameInfo: true,
          label: "Pause",
          onExit: () {
            Navigator.of(dialogContext).pop();
            resetGame();
          },
          actions: [
            SettingActionItem(
              buttonImage: Image.asset("assets/images/app/continue.png"),
              action: () {
                Navigator.of(dialogContext).pop();
                togglePause();
              },
            ),
            SettingActionItem(
              buttonImage: Image.asset("assets/images/app/exit.png"),
              action: () {
                Navigator.of(dialogContext).pop();
                to(ContextUtility.context!, GamesScreen.route);
              },
            ),
          ],
        );
      },
    );
  }
}
