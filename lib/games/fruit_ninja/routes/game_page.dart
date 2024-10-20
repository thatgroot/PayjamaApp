import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame_audio/flame_audio.dart'; // Import flame_audio package
import 'package:provider/provider.dart';
import 'package:pyjamaapp/games/fruit_ninja/components/back_button.dart';
import 'package:pyjamaapp/games/fruit_ninja/components/pause_button.dart';
import 'package:pyjamaapp/games/fruit_ninja/config/app_config.dart';
import 'package:pyjamaapp/games/fruit_ninja/game.dart';
import 'package:pyjamaapp/providers/game.dart';
import 'package:pyjamaapp/services/context_utility.dart';
import 'dart:developer' as dev;
import '../components/fruit_component.dart';

class GamePage extends Component
    with DragCallbacks, HasGameReference<FruitNinjaGame> {
  final Random random = Random();
  late List<double> fruitsTime;
  late double time, countDown;
  TextComponent? _countdownTextComponent, _mistakeTextComponent;
  bool _countdownFinished = false;
  late int mistakeCount;
  final globalGameProvider = Provider.of<GlobalGameProvider>(
    ContextUtility.context!,
    listen: false,
  );
  final gameProvider = Provider.of<FruitNinjaGameProvider>(
    ContextUtility.context!,
    listen: false,
  );
  @override
  void onMount() {
    super.onMount();

    FlameAudio.bgm.play('fruit_ninja/bgm.mp3');

    fruitsTime = [];
    countDown = 3;
    mistakeCount = 0;
    time = 0;
    _countdownFinished = false;

    double initTime = 0;
    for (int i = 0; i < 40; i++) {
      if (i != 0) {
        initTime = fruitsTime.last;
      }
      final millySecondTime = random.nextInt(100) / 100;
      final componentTime = random.nextInt(1) + millySecondTime + initTime;
      fruitsTime.add(componentTime);
    }

    addAll([
      BackButton(onPressed: () {
        removeAll(children);
        game.router.pop();
        FlameAudio.bgm.stop(); // Stop background music when exiting the game
      }),
      PauseButton(),
      _countdownTextComponent = TextComponent(
        text: '${countDown.toInt() + 1}',
        size: Vector2.all(50),
        position: game.size / 2,
        anchor: Anchor.center,
      ),
      _mistakeTextComponent = TextComponent(
        text: 'Mistake: $mistakeCount',
        // 10 is padding
        position: Vector2(game.size.x - 80, 30),
        anchor: Anchor.topRight,
      ),
      // _scoreTextComponent = TextComponent(
      //   text: 'Score: $score',
      //   position:
      //       Vector2(game.size.x - 10, _mistakeTextComponent!.position.y + 40),
      //   anchor: Anchor.topRight,
      // ),
    ]);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!_countdownFinished) {
      countDown -= dt;

      _countdownTextComponent?.text = (countDown.toInt() + 1).toString();
      if (countDown < 0) {
        _countdownFinished = true;
      }
    } else {
      _countdownTextComponent?.removeFromParent();

      time += dt;

      fruitsTime.where((element) => element < time).toList().forEach((element) {
        final gameSize = game.size;

        double posX = random.nextInt(gameSize.x.toInt()).toDouble();

        Vector2 fruitPosition = Vector2(posX, gameSize.y);
        Vector2 velocity = Vector2(0, game.maxVerticalVelocity);

        final randFruit = game.fruits.random();

        add(FruitComponent(
          this,
          fruitPosition,
          acceleration: AppConfig.acceleration,
          fruit: randFruit,
          size: AppConfig.shapeSize,
          image: game.images.fromCache(randFruit.image),
          pageSize: gameSize,
          velocity: velocity,
        ));
        fruitsTime.remove(element);
      });
    }
  }

  @override
  bool containsLocalPoint(Vector2 point) => true;

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);

    componentsAtPoint(event.canvasStartPosition).forEach((element) {
      if (element is FruitComponent) {
        if (element.canDragOnShape) {
          element.touchAtPoint(event.canvasStartPosition);
        }
      }
    });
  }

  void gameOver() {
    FlameAudio.bgm.stop(); // Stop background music when the game is over
    game.router.pushNamed('game-over');
  }

  int baseLevelScore = 10;

  void addScore() {
    int level = gameProvider.level;
    int updatedScore = gameProvider.score + 1;

    // Define a variable for score increment based on the level
    int scoreIncrement;

    // Set the score increment based on the current level
    if (level == 2) {
      scoreIncrement = 7;
    } else if (level == 3) {
      scoreIncrement = 10;
    } else if (level == 4) {
      scoreIncrement = 15;
    } else if (level == 5) {
      scoreIncrement = 20;
    } else if (level == 6) {
      scoreIncrement = 25;
    } else if (level == 7) {
      scoreIncrement = 30;
    } else if (level == 8) {
      scoreIncrement = 35;
    } else {
      scoreIncrement = 1;
    }

    int levelScoreThreshold =
        level == 1 ? baseLevelScore : baseLevelScore + scoreIncrement;
    gameProvider.update(updatedScore);
    if (updatedScore >= levelScoreThreshold) {
      dev.log(
          "updated score is $updatedScore -> game type ${globalGameProvider.gameType}");
      gameProvider.completePopover();
      Future.delayed(const Duration(seconds: 2), () {
        game.isPaused = true;
        game.resetGame();
        gameProvider.updateLevel(level + 1);
      });
    }
  }

  void addMistake() {
    mistakeCount++;
    _mistakeTextComponent?.text = 'Mistake: $mistakeCount';
    if (mistakeCount >= 10) {
      game.resetGame();
      gameOver();
    }
  }
}
