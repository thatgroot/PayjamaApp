import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'package:pyjamaapp/games/brick_breaker/game.dart';
import 'package:pyjamaapp/screens/brick_breaker/brick_breaker_screen.dart';
import 'package:pyjamaapp/services/context_utility.dart';
import 'package:pyjamaapp/utils/navigation.dart';
import 'package:pyjamaapp/widgets/app/game_action_bar.dart';
import 'package:pyjamaapp/widgets/app/sections/game_settings_popup.dart';
import 'package:pyjamaapp/widgets/app/sections/popover_manager.dart';
import 'package:pyjamaapp/widgets/app/wrapper.dart';

class BrickBreaker extends StatefulWidget {
  const BrickBreaker({super.key});

  static String route = "/brick_breaker";

  @override
  BrickBreakerState createState() => BrickBreakerState();
}

class BrickBreakerState extends State<BrickBreaker> {
  final PopoverManager _popoverManager = PopoverManager();
  bool paused = false;
  late BrickBreakerGame _game;

  @override
  void initState() {
    super.initState();
    if (mounted) {
      _game = BrickBreakerGame(context);
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
              to(ContextUtility.context!, BrickBreakerScreen.route);
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
              _game.resetGameForNextLevel();
              _popoverManager.removeOverlay();
            },
          ),
          SettingActionItem(
            buttonImage: Image.asset("assets/images/app/exit.png"),
            action: () {
              // Implement exit logic, e.g., navigate to main menu
              _popoverManager.removeOverlay();
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
            padding: const EdgeInsets.only(bottom: 8.0),
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
