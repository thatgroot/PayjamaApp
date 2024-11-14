import 'package:flutter/material.dart';
import 'package:pyjamaapp/games/brick_breaker/brick_breaker.dart';
import 'package:pyjamaapp/games/fruit_ninja/fruit_ninja.dart';
import 'package:pyjamaapp/games/pyjama_game/pyjama_runner.dart';
import 'package:pyjamaapp/screens/app_screen.dart';
import 'package:pyjamaapp/services/context_utility.dart';
import 'package:pyjamaapp/services/hive.dart';
import 'package:pyjamaapp/utils/navigation.dart';
import 'package:pyjamaapp/widgets/app/Wrapper.dart';

class DailyTasks extends StatefulWidget {
  const DailyTasks({super.key});
  static String route = "/daily_tasks";

  @override
  State<DailyTasks> createState() => _DailyTasksState();
}

class _DailyTasksState extends State<DailyTasks> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Wrapper(
      title: "Daily Tasks",
      onBack: () {
        to(context, PyjamaAppScreen.route);
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
                  'Daily Tasks',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
          CircleAvatar(
            radius: 43.5,
            backgroundImage: AssetImage(image),
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
                              horizontal: 8, vertical: 4),
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
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/images/pyjama/pyjama.png',
                            width: 26,
                            height: 26,
                          ),
                          const SizedBox(width: 4),
                          FutureBuilder(
                              future: HiveService.getGameScore(game),
                              builder: (context, snapshot) {
                                return Text(
                                  "${snapshot.data ?? 0}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              }),
                        ],
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
