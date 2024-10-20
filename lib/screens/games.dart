import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pyjamaapp/games/fruit_ninja/fruit_ninja.dart';
import 'package:pyjamaapp/games/pyjama_game/pyjama_runner.dart';
import 'package:pyjamaapp/providers/game.dart';
import 'package:pyjamaapp/screens/brick_breaker/brick_breaker_screen.dart';
import 'package:pyjamaapp/screens/pyjama/character_display.dart';
import 'package:pyjamaapp/screens/pyjama/character_selection.dart';
import 'package:pyjamaapp/services/context_utility.dart';
import 'package:pyjamaapp/utils/hive.dart';
import 'package:pyjamaapp/utils/navigation.dart';
import 'package:pyjamaapp/widgets/app/Wrapper.dart';

class GamesScreen extends StatefulWidget {
  const GamesScreen({super.key});
  static String route = "/games";

  @override
  State<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen> {
  int currentScore = 0;

  // Method to load the score from Hive
  void loadScore() {
    getScore().then((score) {
      setState(() {
        currentScore = score;
      });
    });
  }

  @override
  void initState() {
    loadScore();
    super.initState();
  }

  final globalGameProvider =
      Provider.of<GlobalGameProvider>(ContextUtility.context!, listen: false);

  @override
  Widget build(BuildContext context) {
    return Wrapper(
      title: "Play Games",
      onBack: () {
        to(context, CharacterDisplayScreen.route);
      },
      child: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset('assets/images/pyjama/pyjama.png', height: 177),
            const Text(
              'Earn More PJC',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Select Game To Play',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildGameItem(
              'Pyjama',
              'Mini-game where you play a type of Ping Pong for 10 minutes. You need to keep a ball in the air with a paddle and destroy boxes.',
              'assets/images/pyjama/tasks/walk.gif',
              () {
                globalGameProvider.setGameType = GameType.pyjama;
                to(context, CharacterSelectionScreen.route);
              },
            ),
            _buildGameItem(
              'Brick Breaker',
              'Mini-game where you play a Jump and Run for 10 minutes and collect coins.',
              'assets/images/pyjama/tasks/play.gif',
              () {
                globalGameProvider.setGameType = GameType.brickBreaker;
                to(context, BrickBreakerScreen.route);
              },
            ),
            _buildGameItem(
              'Fruit Ninja',
              'Mini-game where you cut various foods falling from the sky with a knife in the middle for 5 minutes.',
              'assets/images/pyjama/tasks/feed.gif',
              () {
                globalGameProvider.setGameType = GameType.fruitNinja;
                to(context, FruitNinja.route);
              },
            ),
            _buildGameItem(
              'Cleaning',
              'Mini-game where you swipe the screen for 4 minutes to clean your character.',
              'assets/images/pyjama/tasks/clean.gif',
              () {
                to(context, PyjamaRunner.route);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameItem(String title, String description, String image,
      void Function()? onPressed) {
    // score state

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFFED127)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Image.asset(
              image,
              width: 108,
              height: 96,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: onPressed,
                      child: Image.asset(
                        'assets/images/app/play_button.png',
                        height: 36,
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
