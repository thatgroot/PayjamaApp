import 'package:flutter/material.dart';
import 'package:pyjama_runner/screens/CharacterDisplayScreen.dart';
import 'package:pyjama_runner/utils/navigation.dart';
import 'package:pyjama_runner/widgets/app/Wrapper.dart';

class DailyTasks extends StatelessWidget {
  const DailyTasks({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrapper(
      title: "Daily Tasks",
      onBack: () {
        to(context, const CharacterDisplayScreen());
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
                child: const Text(
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
            ),
            _buildTaskItem(
              'Walking',
              'Mini-game where you play a Jump and Run for 10 minutes and collect coins.',
              'assets/images/pyjama/tasks/walk.gif',
            ),
            _buildTaskItem(
              'Feeding',
              'Mini-game where you cut various foods falling from the sky with a knife in the middle for 5 minutes.',
              'assets/images/pyjama/tasks/feed.gif',
            ),
            _buildTaskItem(
              'Cleaning',
              'Mini-game where you swipe the screen for 4 minutes to clean your character.',
              'assets/images/pyjama/tasks/clean.gif',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskItem(String title, String description, String image) {
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
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Image.asset('assets/images/pyjama/pyjama.png',
                              width: 26, height: 26),
                          const SizedBox(width: 4),
                          const Text(
                            '100',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
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
