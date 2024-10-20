import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class Brick extends SpriteComponent with HasGameRef, CollisionCallbacks {
  bool isHit = false; // Flag to prevent multiple collisions

  @override
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite('brick_breaker/brick.png');
    size = Vector2(55, 25); // Correct size of the brick
    anchor = Anchor.topLeft;

    // Use the exact hitbox size as the brick
    add(RectangleHitbox());
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    // Only handle collision if the brick is not already hit
    if (!isHit) {
      isHit = true; // Mark the brick as hit to avoid further collisions
      removeFromParent(); // Remove brick from the game (destroy it)
    }
  }
}
