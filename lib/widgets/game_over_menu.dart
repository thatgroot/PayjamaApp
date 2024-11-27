import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pyjamaapp/screens/games.dart';
import 'package:pyjamaapp/utils/navigation.dart';

import '/widgets/hud.dart';
import '../games/pyjama_game/game.dart';
import '/models/player_data.dart';
import '../games/pyjama_game/audio_manager.dart';

// This represents the game over overlay,
// displayed with dino runs out of lives.
class GameOverMenu extends StatelessWidget {
  // An unique identified for this overlay.
  static const id = 'GameOverMenu';

  // Reference to parent game.
  final PyjamaRunnerGame game;

  const GameOverMenu(this.game, {super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: game.playerData,
      child: Center(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            color: Colors.black.withAlpha(100),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 100),
                child: Wrap(
                  direction: Axis.vertical,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 10,
                  children: [
                    const Text(
                      'Game Over',
                      style: TextStyle(fontSize: 40, color: Colors.white),
                    ),
                    Selector<PlayerData, int>(
                      selector: (_, playerData) => playerData.currentScore,
                      builder: (_, score, __) {
                        return Text(
                          'Your Score: $score',
                          style: const TextStyle(
                              fontSize: 40, color: Colors.white),
                        );
                      },
                    ),
                    ElevatedButton(
                      child: const Text(
                        'Restart',
                        style: TextStyle(
                          fontSize: 30,
                        ),
                      ),
                      onPressed: () {
                        game.overlays.remove(GameOverMenu.id);
                        game.overlays.add(Hud.id);
                        game.reset();
                        game.startGamePlay();
                        game.resumeEngine();
                        AudioManager.instance.resumeBgm();
                      },
                    ),
                    ElevatedButton(
                      child: const Text(
                        'Exit',
                        style: TextStyle(
                          fontSize: 30,
                        ),
                      ),
                      onPressed: () {
                        // game.reset();
                        to(context, GamesScreen.route);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
