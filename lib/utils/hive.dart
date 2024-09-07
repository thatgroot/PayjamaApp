import 'package:hive/hive.dart';

// Save the score to Hive
void saveScore(int score) {
  var box = Hive.box('gameBox');
  box.put('game_score', score);
}

// Retrieve the score from Hive
Future<int> getScore() async {
  var box = await Hive.openBox('gameBox');
  return box.get('game_score', defaultValue: 0);
}
