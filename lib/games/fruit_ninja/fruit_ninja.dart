import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:pyjamaapp/games/fruit_ninja/game.dart';
import 'package:pyjamaapp/providers/game.dart';
import 'package:pyjamaapp/screens/games.dart';
import 'package:pyjamaapp/services/context_utility.dart';
import 'package:pyjamaapp/utils/navigation.dart';
import 'package:pyjamaapp/widgets/app/game_action_bar.dart';
import 'package:pyjamaapp/widgets/app/sections/game_settings_popup.dart';
import 'package:pyjamaapp/widgets/app/sections/popover_manager.dart';
import 'package:pyjamaapp/widgets/app/wrapper.dart';

class FruitNinja extends StatefulWidget {
  const FruitNinja({super.key});
  static String route = "/fruit_ninja";
  @override
  FruitNinjaState createState() => FruitNinjaState();
}

class FruitNinjaState extends State<FruitNinja> {
  final PopoverManager _popoverManager = PopoverManager();
  bool paused = false;
  late FruitNinjaGame _game;
  final gameProvider = Provider.of<FruitNinjaGameProvider>(
    ContextUtility.context!,
    listen: false,
  );
  @override
  void initState() {
    super.initState();
    _game = FruitNinjaGame();

    if (mounted) {
      gameProvider.setCompletePopover = () {
        showGameCompletedOverlay();
      };
      setState(() {
        paused = _game.isPaused;
      });
    }
  }

  void showGamePauseOverlay() {
    _popoverManager.showOverlay(
      context,
      GameSettingsPopup(
        gameInfo: true,
        label: "Pause",
        onExit: _popoverManager.removeOverlay,
        actions: [
          SettingActionItem(
            buttonImage: Image.asset("assets/images/app/continue.png"),
            action: () {
              _game.togglePause();
              _popoverManager.removeOverlay();
            },
          ),
          SettingActionItem(
            buttonImage: Image.asset("assets/images/app/exit.png"),
            action: () {
              // Implement exit logic, e.g., navigate to main menu
              _popoverManager.removeOverlay();
              to(ContextUtility.context!, GamesScreen.route);
            },
          ),
        ],
      ),
    );
  }

  void showGameCompletedOverlay() {
    _popoverManager.showOverlay(
      context,
      GameSettingsPopup(
        gameCompleted: true,
        gameInfo: true,
        label: "Level Complete",
        onExit: _popoverManager.removeOverlay,
        actions: [
          SettingActionItem(
            buttonImage: Image.asset("assets/images/app/next.png"),
            action: () {
              _popoverManager.removeOverlay();
              _game.resetGame();
            },
          ),
          SettingActionItem(
            buttonImage: Image.asset("assets/images/app/exit.png"),
            action: () {
              // Implement exit logic, e.g., navigate to main menu
              _popoverManager.removeOverlay();
              to(ContextUtility.context!, GamesScreen.route);
            },
          ),
        ],
      ),
    );
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
                      showGamePauseOverlay();
                    } else {
                      _popoverManager.removeOverlay();
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
