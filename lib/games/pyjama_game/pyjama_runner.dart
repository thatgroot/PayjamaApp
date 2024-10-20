import 'package:flame/camera.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'package:pyjamaapp/widgets/hud.dart';
import 'package:pyjamaapp/widgets/main_menu.dart';
import 'package:pyjamaapp/widgets/pause_menu.dart';
import 'package:pyjamaapp/widgets/settings_menu.dart';
import 'package:pyjamaapp/widgets/game_over_menu.dart';

import 'game.dart';

// The main widget for this game.
class PyjamaRunner extends StatelessWidget {
  const PyjamaRunner({super.key});
  static String route = "/pyjama_runner";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget<PyjamaRunnerGame>.controlled(
        // This will dislpay a loading bar until [DinoRun] completes
        // its onLoad method.
        loadingBuilder: (conetxt) => const Center(
          child: SizedBox(
            width: 200,
            child: LinearProgressIndicator(),
          ),
        ),
        // Register all the overlays that will be used by this game.
        overlayBuilderMap: {
          MainMenu.id: (_, game) => MainMenu(game),
          PauseMenu.id: (_, game) => PauseMenu(game),
          Hud.id: (_, game) => Hud(game),
          GameOverMenu.id: (_, game) => GameOverMenu(game),
          SettingsMenu.id: (_, game) => SettingsMenu(game),
        },
        // By default MainMenu overlay will be active.
        initialActiveOverlays: const [MainMenu.id],
        gameFactory: () => PyjamaRunnerGame(
          camera: CameraComponent.withFixedResolution(width: 360, height: 180),
        ),
      ),
    );
  }
}
