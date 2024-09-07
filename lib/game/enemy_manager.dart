import 'dart:math';

import 'package:flame/components.dart';

import '/game/enemy.dart';
import '/game/dino_run.dart';
import '/models/enemy_data.dart';

// This class is responsible for spawning random enemies at certain
// interval of time depending upon players current score.
class EnemyManager extends Component with HasGameReference<DinoRun> {
  // A list to hold data for all the enemies.
  final List<EnemyData> _data = [];

  // Random generator required for randomly selecting enemy type.
  final Random _random = Random();

  // Timer to decide when to spawn next enemy.
  final Timer _timer = Timer(2, repeat: true);

  EnemyManager() {
    _timer.onTick = spawnRandomEnemy;
  }

  // This method is responsible for spawning a random enemy.
  void spawnRandomEnemy() {
    /// Generate a random index within [_data] and get an [EnemyData].
    final randomIndex = _random.nextInt(_data.length);
    final enemyData = _data.elementAt(randomIndex);
    final enemy = Enemy(enemyData);

    // Help in setting all enemies on ground.
    enemy.anchor = Anchor.bottomLeft;
    enemy.position = Vector2(
      game.virtualSize.x + 34,
      game.virtualSize.y - 30,
    );

    // If this enemy can fly, set its y position randomly.
    if (enemyData.canFly) {
      final newHeight = _random.nextDouble() * 2 * enemyData.textureSize.y;
      enemy.position.y -= newHeight;
    }

    // Due to the size of our viewport, we can
    // use textureSize as size for the components.
    enemy.size = enemyData.textureSize;
    game.world.add(enemy);
  }

  @override
  void onMount() {
    if (isMounted) {
      removeFromParent();
    }

    // Don't fill list again and again on every mount.
    if (_data.isEmpty) {
      // As soon as this component is mounted, initilize all the data.
      _data.addAll([
        EnemyData(
          image: game.images.fromCache('AngryPig/balloon.png'),
          nFrames: 4, // The sprite sheet has 4 frames
          stepTime: 0.1,
          textureSize:
              Vector2(28, 40), // Each frame is approximately 26x40 pixels
          speedX: 100,
          canFly: true,
        ),
        // EnemyData(
        //   image: game.images.fromCache('Bat/book.png'),
        //   nFrames: 4, // The sprite sheet has 4 frames
        //   stepTime: 0.1,
        //   textureSize: Vector2(36, 26), // Each frame is 36x26 pixels
        //   speedX: 100,
        //   canFly: true,
        // ),
        EnemyData(
          image: game.images.fromCache('Bat/bird1.png'),
          nFrames: 3, // The sprite sheet has 3 frames
          stepTime: 0.1,
          textureSize: Vector2(82, 82), // Each frame is 52x42 pixels
          speedX: 100,
          canFly: true,
        ),
        EnemyData(
          // image: game.images.fromCache('Rino/Run (52x34).png'),
          image: game.images.fromCache('Rino/bubble.png'),
          nFrames: 5,
          stepTime: 0.09,
          textureSize: Vector2(37.2, 30),
          speedX: 150,
          canFly: true,
        ),
        EnemyData(
          // image: game.images.fromCache('Rino/Run (52x34).png'),
          image: game.images.fromCache('cushion1.png'),
          nFrames: 4,
          stepTime: 0.1,
          textureSize: Vector2(46, 52),
          speedX: 150,
          canFly: false,
        ),
      ]);
    }
    _timer.start();
    super.onMount();
  }

  @override
  void update(double dt) {
    _timer.update(dt);
    super.update(dt);
  }

  void removeAllEnemies() {
    final enemies = game.world.children.whereType<Enemy>();
    for (var enemy in enemies) {
      enemy.removeFromParent();
    }
  }
}
