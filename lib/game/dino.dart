import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '/game/enemy.dart';
import '/game/dino_run.dart';
import '/game/audio_manager.dart';
import '/models/player_data.dart';

/// This enum represents the animation states of [Dino].
enum DinoAnimationStates {
  idle,
  run,
  kick,
  hit,
  sprint,
}

// This represents the dino character of this game.
class Dino extends SpriteAnimationGroupComponent<DinoAnimationStates>
    with CollisionCallbacks, HasGameReference<DinoRun> {
  // A map of all the animation states and their corresponding animations.
  static final _animationMap = {
    // DinoAnimationStates.idle: SpriteAnimationData.sequenced(
    //     amount: 4,
    //     stepTime: 0.1,
    //     textureSize: Vector2.all(30),
    //   ),
    // DinoAnimationStates.run: SpriteAnimationData.sequenced(
    //   amount: 6,
    //   stepTime: 0.1,
    //   textureSize: Vector2.all(30),
    //   texturePosition: Vector2((4) * 30, 0),
    // ),
    DinoAnimationStates.idle: SpriteAnimationData.sequenced(
      amount: 4, // 4 frames from the 0th to the 3rd frame
      stepTime: 0.1,
      textureSize: Vector2(89, 86),
      texturePosition: Vector2(0 * 89, 0), // Start at the 0th frame
    ),

    DinoAnimationStates.run: SpriteAnimationData.sequenced(
      amount: 7, // 7 frames from the 4th to the 10th frame
      stepTime: 0.1,
      textureSize: Vector2(89, 86),
      texturePosition: Vector2(4 * 89, 0), // Start at the 4th frame
    ),
    // DinoAnimationStates.run: SpriteAnimationData.sequenced(
    //   amount: 6, // 7 frames in total
    //   stepTime: 0.1,
    //   textureSize: Vector2(111, 120), // Each frame is 111x120 pixels
    //   texturePosition: Vector2(1 * 111, 0), // Start at the 4th frame
    // ),

    DinoAnimationStates.kick: SpriteAnimationData.sequenced(
      amount: 3, // 3 frames from the 11th to the 13th frame
      stepTime: 0.1,
      textureSize: Vector2(89, 86),
      texturePosition: Vector2(11 * 89, 0), // Start at the 11th frame
    ),

    DinoAnimationStates.hit: SpriteAnimationData.sequenced(
      amount: 3, // 3 frames from the 14th to the 16th frame
      stepTime: 0.1,
      textureSize: Vector2(89, 86),
      texturePosition: Vector2(14 * 89, 0), // Start at the 14th frame
    ),

    DinoAnimationStates.sprint: SpriteAnimationData.sequenced(
      amount: 7, // 7 frames from the 17th to the 23rd frame
      stepTime: 0.1,
      textureSize: Vector2(89, 86),
      texturePosition: Vector2(17 * 89, 0), // Start at the 17th frame
    ),
  };

  // The max distance from top of the screen beyond which
  // dino should never go. Basically the screen height - ground height
  double yMax = 0.0;

  // Dino's current speed along y-axis.
  double speedY = 0.0;

  // Controlls how long the hit animations will be played.
  final Timer _hitTimer = Timer(1);

  static const double gravity = 800;

  final PlayerData playerData;

  bool isHit = false;

  Dino(Image image, this.playerData)
      : super.fromFrameData(image, _animationMap);

  @override
  void onMount() {
    // First reset all the important properties, because onMount()
    // will be called even while restarting the game.
    _reset();

    // Add a hitbox for dino.
    add(
      RectangleHitbox.relative(
        Vector2(0.5, 0.7),
        parentSize: size,
        position: Vector2(size.x * 0.5, size.y * 0.3) / 2,
      ),
    );
    yMax = y;

    /// Set the callback for [_hitTimer].
    _hitTimer.onTick = () {
      current = DinoAnimationStates.run;
      isHit = false;
    };

    super.onMount();
  }

  @override
  void update(double dt) {
    // v = u + at
    speedY += gravity * dt;

    // d = s0 + s * t
    y += speedY * dt;

    /// This code makes sure that dino never goes beyond [yMax].
    if (isOnGround) {
      y = yMax;
      speedY = 0.0;
      if ((current != DinoAnimationStates.hit) &&
          (current != DinoAnimationStates.run)) {
        current = DinoAnimationStates.run;
      }
    }

    _hitTimer.update(dt);
    super.update(dt);
  }

  // Gets called when dino collides with other Collidables.
  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    // Call hit only if other component is an Enemy and dino
    // is not already in hit state.
    if ((other is Enemy) && (!isHit)) {
      hit();
    }
    super.onCollision(intersectionPoints, other);
  }

  // Returns true if dino is on ground.
  bool get isOnGround => (y >= yMax);

  // Makes the dino jump.
  void jump() {
    // Jump only if dino is on ground.
    if (isOnGround) {
      speedY = -300;
      current = DinoAnimationStates.run;
      AudioManager.instance.playSfx('jump14.wav');
    }
  }

  // This method changes the animation state to
  /// [DinoAnimationStates.hit], plays the hit sound
  /// effect and reduces the player life by 1.
  void hit() {
    isHit = true;
    AudioManager.instance.playSfx('hurt7.wav');
    current = DinoAnimationStates.hit;
    _hitTimer.start();
    playerData.lives -= 1;
  }

  // This method reset some of the important properties
  // of this component back to normal.
  void _reset() {
    if (isMounted) {
      removeFromParent();
    }
    anchor = Anchor.bottomLeft;
    position = Vector2(32, game.virtualSize.y - 32);
    size = Vector2.all(32);
    current = DinoAnimationStates.run;
    isHit = false;
    speedY = 0.0;
  }
}
