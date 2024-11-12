import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pyjamaapp/services/hive.dart';
import 'paddle.dart';
import 'brick.dart';
import 'audio_manager.dart';
import 'game.dart'; // Import the game class to access the bricks list

class Ball extends SpriteComponent with HasGameRef, CollisionCallbacks {
  Vector2 velocity = Vector2(0, 0); // Initially, the ball doesn't move
  bool isLaunched = false; // Track whether the ball is launched
  late double upperBound; // Define an upper boundary for the ball
  void Function() onBrickDestroyed;
  bool hasCollidedWithPaddle = false; // Prevent double paddle collisions

  Ball({required this.onBrickDestroyed});

  @override
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite('brick_breaker/ball.png');
    size = Vector2(42, 42); // Ball size
    anchor = Anchor.center;

    // Use CircleHitbox for a circular ball
    add(CircleHitbox());

    // Calculate the correct upper bound to bounce back from the first row of bricks
    const double topPadding = 100; // Top padding space where bricks are drawn
    upperBound =
        topPadding; // Set upper bound to the top padding (top of the first row of bricks)
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Move the ball only if it has been launched
    if (isLaunched) {
      position += velocity * dt;

      // Bounce off left and right walls
      if (position.x - size.x / 2 <= 0) {
        // Left wall
        velocity.x = -velocity.x;
        position.x = size.x / 2; // Correct position to prevent getting stuck
      }
      if (position.x + size.x / 2 >= gameRef.size.x) {
        // Right wall
        velocity.x = -velocity.x;
        position.x = gameRef.size.x -
            size.x / 2; // Correct position to prevent getting stuck
      }

      // Bounce off top boundary (upper bound = first row of bricks)
      if (position.y <= upperBound) {
        velocity.y = -velocity.y;
      }

      // End game if ball moves below the paddle or off-screen
      if (isOffScreen(gameRef.size)) {}
    }
  }

  // Launch the ball
  void launchBall() {
    if (!isLaunched) {
      HiveService.getGameLevel(GameNames.brickBreaker).then((level) {
        int currentLevel = int.parse("${level ?? "0"} ");
        velocity = Vector2(
          150 + (150 * currentLevel * 0.15),
          -150 + (-150 * currentLevel * 0.15),
        );
      });
      // Set ball velocity when launched (moving upwards)
      isLaunched = true;
    }
  }

  // Check if the ball has moved off-screen or below the paddle
  bool isOffScreen(Vector2 screenSize) {
    return position.y > screenSize.y;
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    final game = gameRef as BrickBreakerGame; // Get reference to the game
    if (other is Paddle || other is Brick) {
      velocity.y = -velocity.y;
    }

    // Check if the collision is with a Paddle
    if (other is Paddle) {
      if (!hasCollidedWithPaddle) {
        hasCollidedWithPaddle = true;

        // Calculate the horizontal position relative to the paddle center
        // double relativeHitPosition =
        //     (position.x - other.position.x) / (other.size.x / 2);
        // Apply some horizontal velocity based on where the ball hits the paddle
        // velocity.x = velocity.x + relativeHitPosition * 100;
        // velocity.y = -velocity.y; // Reverse Y-velocity to bounce

        AudioManager.playHitPaddle();
      }
    }
    // Check if the collision is with a Brick
    else if (other is Brick) {
      // velocity.y = -velocity.y; // Reverse Y-velocity to bounce off the brick
      other.removeFromParent(); // Remove the brick on collision
      onBrickDestroyed();
      game.bricks.remove(other); // Remove brick from the list
      AudioManager.playHitBrick(); // Play brick hit sound

      // Check if all bricks are destroyed
      if (game.bricks.isEmpty) {
        game.pauseEngine();
        game.showLevelCompletePopup(); // Show level complete popup
      }
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    // Reset the flag after the ball moves away from the paddle
    if (other is Paddle && !isColliding) {
      hasCollidedWithPaddle = false;
    }
  }
}
