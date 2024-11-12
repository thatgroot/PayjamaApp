import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:pyjamaapp/games/fruit_ninja/game.dart';
import 'package:pyjamaapp/providers/game.dart';
import 'package:pyjamaapp/services/context_utility.dart';
import 'package:pyjamaapp/widgets/app/game_action_bar.dart';
import 'package:pyjamaapp/widgets/app/wrapper.dart';

class FruitNinja extends StatefulWidget {
  const FruitNinja({super.key});
  static String route = "/fruit_ninja";
  @override
  FruitNinjaState createState() => FruitNinjaState();
}

class FruitNinjaState extends State<FruitNinja> {
  bool paused = false;
  late FruitNinjaGame _game;
  final gameProvider = Provider.of<FruitNinjaGameProvider>(
    ContextUtility.context!,
    listen: false,
  );
  @override
  void initState() {
    super.initState();

    if (mounted) {
      _game = FruitNinjaGame();
      setState(() {
        paused = _game.isPaused;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Wrapper(
      child: Stack(
        children: [
          // Game Widget
          Padding(
            padding: const EdgeInsets.only(bottom: 0.0),
            child: GameWidget(
              game: _game,
            ),
          ),
          // Game Action Bar Overlay
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 8, top: 12),
            child: GameActionBar(
              actions: [
                // ActionItem(
                //   icon: Icons.replay,
                //   action: _game.resetGame,
                // ),
                ActionItem(
                  icon: paused ? Icons.play_circle : Icons.pause,
                  action: () {
                    _game.togglePause();
                    if (_game.isPaused) {
                      _game.showGamePauseOverlay();
                    }

                    setState(() {
                      paused = _game.isPaused;
                    });
                  },
                ),
                // ActionItem(
                //   icon: Icons.skip_next,
                //   action: _game.resetGameForNextLevel,
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
