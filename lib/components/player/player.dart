import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/services.dart';
import 'package:mario_pro_game/components/checkpoint/checkpoint.dart';
import 'package:mario_pro_game/components/collisions_block.dart';
import 'package:mario_pro_game/components/enemies/chicken.dart';
import 'package:mario_pro_game/components/fruit/fruit.dart';
import 'package:mario_pro_game/components/saw/saw.dart';
import 'package:mario_pro_game/mario_pro_game.dart';
import 'package:mario_pro_game/model/custom_hitbox.dart';
import 'package:mario_pro_game/utils.dart';

enum PlayerState { idle, running, jump, hit, appearing, disappearing }

//SpriteAnimationGroupComponent for Animations
class Player extends SpriteAnimationGroupComponent
    with HasGameRef<MarioProGame>, KeyboardHandler, CollisionCallbacks {
  Player({position, this.character = "Mask Dude"}) : super(position: position);
  final String character;

  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runningAnimation;
  late final SpriteAnimation jumpAnimation;
  late final SpriteAnimation appearingAnimation;
  late final SpriteAnimation disAppearingAnimation;
  late final SpriteAnimation hitAnimation;
  final double stepTime = 0.05;
  final double gravity = 10;
  final double jumpForce = 240;
  final double terminalVelocity = 300;
  double fixedDeltaTime = 1 / 60;
  double accumulatedTime = 0;
  bool isCheckpointReached = false;
  bool isOnGround = false;
  bool hasJumped = false;
  bool gotHit = false;
  double moveSpeed = 100;
  double horizontalMovements = 0;
  CustomHitBoxEntity customHitBoxEntity =
      CustomHitBoxEntity(offSetX: 13, offSetY: 4, width: 14, height: 28);
  Vector2 velocity = Vector2.zero();
  Vector2 startingPosition = Vector2.zero();
  List<CollisionsBlock> collisionBlockList = [];

  SpriteAnimation spritAnimation(String name, int amount, double vectorSize) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache(name),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: Vector2.all(vectorSize),
      ),
    );
  }

  void initializeAnimation() {
    idleAnimation =
        spritAnimation('Main Characters/$character/Idle (32x32).png', 12, 32);

    runningAnimation =
        spritAnimation('Main Characters/$character/Run (32x32).png', 12, 32);
    jumpAnimation =
        spritAnimation('Main Characters/$character/Jump (32x32).png', 1, 32);
    hitAnimation =
        spritAnimation('Main Characters/$character/Hit (32x32).png', 7, 32);
    appearingAnimation =
        spritAnimation('Main Characters/Appearing (96x96).png', 7, 96);
    disAppearingAnimation =
        spritAnimation('Main Characters/Desappearing (96x96).png', 7, 96);
    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.running: runningAnimation,
      PlayerState.jump: jumpAnimation,
      PlayerState.hit: hitAnimation,
      PlayerState.appearing: appearingAnimation,
      PlayerState.disappearing: disAppearingAnimation,
    };
    current = PlayerState.idle;
  }

  void updatePlayerState() {
    PlayerState playerState = PlayerState.idle;
    if (velocity.x < 0 && scale.x > 0) {
      flipHorizontallyAroundCenter();
    } else if (velocity.x > 0 && scale.x < 0) {
      flipHorizontallyAroundCenter();
    }

    if (velocity.x > 0 || velocity.x < 0) playerState = PlayerState.running;
    if (velocity.y > 0 || velocity.y < 0) playerState = PlayerState.jump;
    current = playerState;
  }

  void updatePlayerMovements(double dt) {
    if (hasJumped && isOnGround) playerJump(dt);
    velocity.x = horizontalMovements * moveSpeed;
    position.x += velocity.x * dt;
  }

  void playerJump(double dt) {
    if (game.playSound) {
      FlameAudio.play(
        "jump.wav",
        volume: 0.5,
      );
    }
    velocity.y = -jumpForce;
    position.y += velocity.y * dt;
    hasJumped = false;
    isOnGround = false;
  }

  void checkHorizontalCollisions() {
    for (final block in collisionBlockList) {
      if (!block.isPlatform) {
        if (checkCollision(this, block)) {
          if (velocity.x > 0) {
            velocity.x = 0;
            position.x =
                block.x - customHitBoxEntity.offSetX - customHitBoxEntity.width;
            break;
          }
          if (velocity.x < 0) {
            velocity.x = 0;
            position.x = block.x +
                block.width +
                customHitBoxEntity.width +
                customHitBoxEntity.offSetX;
            break;
          }
        }
      }
    }
  }

  void checkVerticalCollisions() {
    for (final block in collisionBlockList) {
      if (block.isPlatform) {
        if (checkCollision(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y -
                customHitBoxEntity.height -
                customHitBoxEntity.offSetY;
            isOnGround = true;
            break;
          }
        }
      } else {
        if (checkCollision(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y -
                customHitBoxEntity.height -
                customHitBoxEntity.offSetY;
            isOnGround = true;
            break;
          }
          if (velocity.y < 0) {
            velocity.y = 0;
            position.y = block.y + block.height - customHitBoxEntity.offSetY;
          }
        }
      }
    }
  }

  void applyGravity(double dt) {
    velocity.y += gravity;
    velocity.y = velocity.y.clamp(-jumpForce, terminalVelocity);
    position.y += velocity.y * dt;
  }

  void reSpawn() {
    if (game.playSound) {
      FlameAudio.play("hit.wav");
    }
    const hitDuration = Duration(milliseconds: 350);
    const appearingDuration = Duration(milliseconds: 350);
    const canMoveDuration = Duration(milliseconds: 400);
    gotHit = true;
    current = PlayerState.hit;
    Future.delayed(hitDuration, () {
      scale.x = 1;
      position = startingPosition - Vector2.all(32);
      current = PlayerState.appearing;
      Future.delayed(appearingDuration, () {
        velocity = Vector2.zero();
        position = startingPosition;
        updatePlayerState();
        Future.delayed(canMoveDuration, () => gotHit = false);
      }); // Future.delayed
    }); // Future.delayed
  }

  void reachedCheckPoint() {
    isCheckpointReached = true;
    if (game.playSound) {
      FlameAudio.play("disappear.wav");
    }
    if (scale.x > 0) {
      position = position - Vector2.all(32);
    } else if (scale.x < 0) {
      position = position + Vector2(32, -32);
    }
    current = PlayerState.disappearing;
    const reachedCheckpointDuration = Duration(milliseconds: 350);
    Future.delayed(reachedCheckpointDuration, () {
      isCheckpointReached = false;
      position = Vector2.all(-640);
      const waitToChange = Duration(seconds: 3);
      Future.delayed(waitToChange, () {
        game.loadNextLevel();
      });
    });
  }

  void collidedWithEnemy() {
    reSpawn();
  }

  @override
  FutureOr<void> onLoad() {
    startingPosition = Vector2(position.x, position.y);
    add(RectangleHitbox(
      position: Vector2(customHitBoxEntity.offSetX, customHitBoxEntity.offSetY),
      size: Vector2(customHitBoxEntity.width, customHitBoxEntity.height),
    ));
    initializeAnimation();
    return super.onLoad();
  }

  @override
  void update(double dt) {
    accumulatedTime += dt;
    while (accumulatedTime >= fixedDeltaTime) {
      if (!gotHit && !isCheckpointReached) {
        updatePlayerState();
        updatePlayerMovements(fixedDeltaTime);
        checkHorizontalCollisions();
        applyGravity(fixedDeltaTime);
        checkVerticalCollisions();
      }
      accumulatedTime -= fixedDeltaTime;
    }

    super.update(dt);
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    horizontalMovements = 0;
    final isLeftKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyA) ||
        keysPressed.contains(LogicalKeyboardKey.arrowLeft);
    final isRightKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyD) ||
        keysPressed.contains(LogicalKeyboardKey.arrowRight);
    horizontalMovements += isLeftKeyPressed ? -1 : 0;
    horizontalMovements += isRightKeyPressed ? 1 : 0;

    hasJumped = keysPressed.contains(LogicalKeyboardKey.space);
    return super.onKeyEvent(event, keysPressed);
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    if (!isCheckpointReached) {
      if (other is Fruit) other.collidedWithPlayer();
      if (other is Saw) reSpawn();
      if (other is Checkpoint) reachedCheckPoint();
      if (other is Chicken) other.collidedWithPlayer();
    }
    super.onCollisionStart(intersectionPoints, other);
  }
}
