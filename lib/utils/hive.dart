import 'dart:developer';

import 'package:hive/hive.dart';

void saveData(String key, dynamic value) {
  Hive.openBox("gameBox").then((box) {
    log("Saving $key: $value");
    box.put(key, value);
  });
}

Future<dynamic> getData(String key) async {
  var box = await Hive.openBox('gameBox');
  return box.get(key);
}

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
