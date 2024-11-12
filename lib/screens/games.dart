import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pyjamaapp/games/brick_breaker/brick_breaker.dart';
import 'package:pyjamaapp/games/fruit_ninja/fruit_ninja.dart';
import 'package:pyjamaapp/games/pyjama_game/pyjama_runner.dart';
import 'package:pyjamaapp/providers/game.dart';
import 'package:pyjamaapp/screens/pyjama/character_display.dart';
import 'package:pyjamaapp/services/context_utility.dart';
import 'package:pyjamaapp/services/solana_wallet_service.dart';
import 'package:pyjamaapp/services/hive.dart';
import 'package:pyjamaapp/utils/navigation.dart';
import 'package:pyjamaapp/widgets/app/Wrapper.dart';
import 'dart:developer';

class GamesScreen extends StatefulWidget {
  const GamesScreen({super.key});
  static String route = "/games";

  @override
  State<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen> {
  String? session;

  // Method to load the score from Hive
  void loadScore() async {
    var tempSession = await HiveService.getData(HiveKeys.walletSession);
    setState(() {
      session = tempSession;
      log("session $session");
    });
  }

  @override
  void initState() {
    loadScore();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Wrapper(
      title: "Play Games",
      onBack: () {
        to(context, CharacterDisplayScreen.route);
      },
      child: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
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
              const SizedBox(height: 20),
              session == null
                  ? TextButton(
                      onPressed: () async {
                        SolanaWalletService.connect();
                      },
                      child: SizedBox(
                        width: 272,
                        height: 39,
                        child: Image.asset(
                          'assets/icons/wallet-connect-button.png',
                        ),
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Select Game To Play',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildTaskItem(
                          'Playing',
                          'Mini-game where you play a type of Ping Pong for 10 minutes. You need to keep a ball in the air with a paddle and destroy boxes.',
                          'assets/images/pyjama/tasks/play.gif',
                          GameNames.brickBreaker,
                          BrickBreaker.route,
                        ),
                        _buildTaskItem(
                          'Walking',
                          'Mini-game where you play a Jump and Run for 10 minutes and collect coins.',
                          'assets/images/pyjama/tasks/walk.gif',
                          GameNames.runner,
                          PyjamaRunner.route,
                        ),
                        _buildTaskItem(
                          'Feeding',
                          'Mini-game where you cut various foods falling from the sky with a knife in the middle for 5 minutes.',
                          'assets/images/pyjama/tasks/feed.gif',
                          GameNames.fruitNinja,
                          FruitNinja.route,
                        ),
                        _buildTaskItem(
                          'Cleaning',
                          'Mini-game where you swipe the screen for 4 minutes to clean your character.',
                          'assets/images/pyjama/tasks/clean.gif',
                          GameNames.runner,
                          PyjamaRunner.route,
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskItem(
    String title,
    String description,
    String image,
    GameNames game,
    String gameRoute,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFFED127)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              CircleAvatar(
                radius: 48,
                backgroundImage: AssetImage(image),
              ),
              GestureDetector(
                onTap: () {
                  var provider = Provider.of<GlobalGameProvider>(
                    ContextUtility.context!,
                    listen: false,
                  );
                  provider.setGameName = game;
                  to(context, gameRoute);
                },
                child: Image.asset(
                  'assets/images/app/play_button.png',
                  height: 24,
                ),
              ),
            ],
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
                      onPressed: () {
                        to(ContextUtility.context!, gameRoute);
                      },
                      style: ButtonStyle(
                        padding: WidgetStateProperty.all(
                          const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                        ),
                        backgroundColor: WidgetStateProperty.all(
                          Colors.white.withOpacity(0.2),
                        ),
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      child: FutureBuilder(
                        future: HiveService.getGameScore(game),
                        builder: (context, snapshot) {
                          return Row(
                            children: [
                              Image.asset(
                                'assets/images/pyjama/pyjama.png',
                                width: 26,
                                height: 26,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "${snapshot.data ?? 0}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            ],
                          );
                        },
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
