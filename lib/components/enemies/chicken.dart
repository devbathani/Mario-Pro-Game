import 'dart:async';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:mario_pro_game/components/player/player.dart';
import 'package:mario_pro_game/mario_pro_game.dart';

enum EnemiesState { idle, running, hit }

class Chicken extends SpriteAnimationGroupComponent
    with HasGameRef<MarioProGame>, CollisionCallbacks {
  final double offNeg;
  final double offPos;
  Chicken({
    super.position,
    super.size,
    this.offNeg = 0,
    this.offPos = 0,
  });

  late final Player player;
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runningAnimation;
  late final SpriteAnimation hitAnimation;
  bool gotStomped = false;
  static const tileSize = 16;
  static const bounceHeight = 260.0;
  Vector2 velocity = Vector2.zero();
  double rangeNeg = 0;
  double rangePos = 0;
  double moveDirection = 1;
  double targetDirection = -1;
  SpriteAnimation spritAnimation(
      String name, int amount, double vectorSizeX, double vectorSizeY) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache(name),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: 0.05,
        textureSize: Vector2(vectorSizeX, vectorSizeY),
      ),
    );
  }

  void loadAnimations() {
    idleAnimation =
        spritAnimation('Enemies/Chicken/Idle (32x34).png', 13, 32, 34);

    runningAnimation =
        spritAnimation('Enemies/Chicken/Run (32x34).png', 13, 32, 34);
    hitAnimation = spritAnimation('Enemies/Chicken/Hit (32x34).png', 5, 32, 34)
      ..loop = false;

    animations = {
      EnemiesState.idle: idleAnimation,
      EnemiesState.running: runningAnimation,
      EnemiesState.hit: hitAnimation,
    };
    current = EnemiesState.idle;
  }

  void calculateRange() {
    rangePos = position.x + offPos * tileSize;
    rangeNeg = position.x - offNeg * tileSize;
  }

  bool playerInRange() {
    double playerOffset = (player.scale.x > 0) ? 0 : -player.width;

    return player.x + playerOffset >= rangeNeg &&
        player.x + playerOffset <= rangePos &&
        player.y + player.height > position.y &&
        player.y < position.y + player.height;
  }

  void enemiesMovement(double dt) {
    velocity.x = 0;
    double playerOffset = (player.scale.x > 0) ? 0 : -player.width;
    double enemiesOffset = (scale.x > 0) ? 0 : -width;
    if (playerInRange()) {
      targetDirection =
          (player.x + playerOffset < position.x + enemiesOffset) ? -1 : 1;
      velocity.x = targetDirection * 80; // 80 is runspeed
    }
    moveDirection = lerpDouble(moveDirection, targetDirection, 0.1) ?? 1;
    position.x += velocity.x * dt;
  }

  void updateEnemiesState() {
    current = (velocity.x != 0) ? EnemiesState.running : EnemiesState.idle;
    if ((moveDirection > 0 && scale.x > 0) ||
        (moveDirection < 0 && scale.x < 0)) {
      flipHorizontallyAroundCenter();
    }
  }

  void collidedWithPlayer() async {
    if (player.velocity.y > 0 && player.y + player.height > position.y) {
      if (game.playSound) {
        FlameAudio.play("jump-kill.mp3");
      }
      gotStomped = true;
      current = EnemiesState.hit;
      player.velocity.y = -bounceHeight;
      await animationTicker?.completed;
      removeFromParent();
    } else {
      player.collidedWithEnemy();
    }
  }

  @override
  FutureOr<void> onLoad() {
    debugMode = true;
    player = game.player;
    add(RectangleHitbox(
      position: Vector2(4, 6),
      size: Vector2(24, 26),
    ));
    loadAnimations();
    calculateRange();
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (!gotStomped) {
      enemiesMovement(dt);
      updateEnemiesState();
    }

    super.update(dt);
  }
}
