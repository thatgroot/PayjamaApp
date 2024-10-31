import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pyjamaapp/providers/game.dart';
import 'package:pyjamaapp/services/hive.dart';

class ActionItem {
  final IconData icon; // The type for icon is strictly IconData
  final VoidCallback
      action; // The type for action is a function that returns void

  ActionItem({
    required this.icon,
    required this.action,
  });
}

class GameActionBar extends StatelessWidget {
  final List<ActionItem> actions;

  const GameActionBar({super.key, required this.actions});

  @override
  Widget build(BuildContext context) {
    var globalGameProvider = Provider.of<GlobalGameProvider>(context);
    GameProvider provider = Provider.of<BrickBreakerGameProvider>(context);
    if (globalGameProvider.gameName == GameNames.brickBreaker) {
      provider = Provider.of<BrickBreakerGameProvider>(context);
    } else if (globalGameProvider.gameName == GameNames.fruitNinja) {
      provider = Provider.of<FruitNinjaGameProvider>(context);
    }

    final score = provider.score;
    final level = provider.level;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/app/balance_bg.png"),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                icon: Image.asset(
                  "assets/images/app/pcoin.png",
                  width: 48,
                  fit: BoxFit.cover,
                ),
                onPressed: () {},
              ),
              const SizedBox(width: 6),
              Container(
                height: 64,
                width: 42, // Set a fixed width for the container
                alignment: Alignment.center, // Align the text in the center
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    8,
                  ), // Optional: rounding the corners
                ),
                child: Text(
                  score.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: 'Rubik',
                    fontWeight: FontWeight.w600,
                    height: 0,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Opacity(
                opacity: 1,
                child: Padding(
                  padding: const EdgeInsets.only(top: 4.0, right: 4.0),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      IconButton(
                        icon: Image.asset(
                          "assets/images/app/blue_block.png",
                          width: 36,
                        ),
                        onPressed: () {},
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Text(
                          "L$level",
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Row(
          children: actions.map((actionItem) {
            return GestureDetector(
              onTap: actionItem.action, // Trigger the action
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset("assets/images/app/blue_block.png"),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Icon(
                      actionItem.icon, // Display the icon
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
