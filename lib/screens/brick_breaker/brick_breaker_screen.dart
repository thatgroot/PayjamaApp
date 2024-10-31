import 'package:flutter/material.dart';
import 'package:pyjamaapp/screens/games.dart';
import 'package:pyjamaapp/screens/brick_breaker/brick_breaker_levels.dart';
import 'package:pyjamaapp/services/context_utility.dart';
import 'package:pyjamaapp/utils/navigation.dart';
import 'package:pyjamaapp/widgets/app/app_action_bar.dart';
import 'package:pyjamaapp/widgets/app/sections/game_settings_popup.dart';
import 'package:pyjamaapp/widgets/app/sections/popover_manager.dart';
import 'package:pyjamaapp/widgets/app/wrapper.dart';

class BrickBreakerScreen extends StatefulWidget {
  const BrickBreakerScreen({super.key});
  static String route = "/brick_breaker_home";

  @override
  State<BrickBreakerScreen> createState() => _BrickBreakerState();
}

class _BrickBreakerState extends State<BrickBreakerScreen> {
  final PopoverManager _popoverManager = PopoverManager();

  @override
  void initState() {
    super.initState();
    initialization();
  }

  // Create an instance of PopoverManager
  void initialization() async {
    // This is where you can initialize the resources needed by your app while
    // the splash screen is displayed.  Remove the following example because
    // delaying the user experience is a bad design practice!
    // ignore_for_file: avoid_print
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    void showSettingsOverlay() {
      _popoverManager.showOverlay(
        context,
        GameSettingsPopup(
          label: "Settings",
          onExit: _popoverManager.removeOverlay,
          actions: [
            SettingActionItem(
              buttonImage: Image.asset("assets/images/app/exit.png"),
              action: _popoverManager.removeOverlay,
            )
          ],
        ),
      );
    }

    // void showGamePauseOverlay() {
    //   _popoverManager.showOverlay(
    //     context,
    //     GameSettingsPopup(
    //       gameInfo: true,
    //       label: "Pause",
    //       onExit: _popoverManager.removeOverlay,
    //       actions: [
    //         SettingActionItem(
    //           buttonImage: Image.asset("assets/images/app/continue.png"),
    //           action: _popoverManager.removeOverlay,
    //         ),
    //         SettingActionItem(
    //           buttonImage: Image.asset("assets/images/app/exit.png"),
    //           action: _popoverManager.removeOverlay,
    //         ),
    //       ],
    //     ),
    //   );
    // }

    // void showGameCompletedOverlay() {
    //   _popoverManager.showOverlay(
    //     context,
    //     GameSettingsPopup(
    //       gameCompleted: true,
    //       gameInfo: true,
    //       label: "Pause",
    //       onExit: _popoverManager.removeOverlay,
    //       actions: [
    //         SettingActionItem(
    //           buttonImage: Image.asset("assets/images/app/next.png"),
    //           action: _popoverManager.removeOverlay,
    //         ),
    //         SettingActionItem(
    //           buttonImage: Image.asset("assets/images/app/exit.png"),
    //           action: _popoverManager.removeOverlay,
    //         ),
    //       ],
    //     ),
    //   );
    // }

    return Wrapper(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 32.0,
          vertical: 24.0,
        ),
        child: ListView(
          children: [
            AppActionBar(balance: "20", showBalance: true, actions: [
              ActionItem(
                icon: Icons.shopping_cart,
                action: () {},
              ),
              ActionItem(
                icon: Icons.settings,
                action: showSettingsOverlay,
              ),
            ]),
            const SizedBox(height: 50),
            Image.asset("assets/images/app/pingpon-pyjama.png"),
            const SizedBox(height: 10),
            Image.asset("assets/images/app/earn-coin.png"),
            const SizedBox(height: 50),
            GestureDetector(
              onTap: () {
                to(ContextUtility.context!, BrickBreakerLevelsScreen.route);
              },
              child: Image.asset(
                "assets/images/app/play_button.png",
                height: 96,
                fit: BoxFit.contain,
              ),
            ),
            TextButton(
              child: Image.asset(
                "assets/images/app/about_button.png",
                height: 98,
                fit: BoxFit.contain,
              ),
              onPressed: () {},
            ),
            TextButton(
              child: Image.asset(
                "assets/images/app/exit_button.png",
                height: 98,
                fit: BoxFit.contain,
              ),
              onPressed: () {
                to(ContextUtility.context!, GamesScreen.route);
              },
            ),
          ],
        ),
      ),
    );
  }
}
