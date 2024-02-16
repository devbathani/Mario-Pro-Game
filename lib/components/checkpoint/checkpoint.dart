import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:mario_pro_game/components/player/player.dart';
import 'package:mario_pro_game/mario_pro_game.dart';

class Checkpoint extends SpriteAnimationComponent
    with HasGameRef<MarioProGame>, CollisionCallbacks {
  Checkpoint({size, position}) : super(size: size, position: position);
  bool isReachedCheckpoint = false;

  void reachedCheckpoint() {
    isReachedCheckpoint = true;
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache(
          "Items/Checkpoints/Checkpoint/Checkpoint (Flag Out) (64x64).png"),
      SpriteAnimationData.sequenced(
        amount: 26,
        stepTime: 0.05,
        textureSize: Vector2.all(64),
        loop: false,
      ),
    );
    const flagDuration = Duration(milliseconds: 1300);
    Future.delayed(flagDuration, () {
      animation = SpriteAnimation.fromFrameData(
        game.images.fromCache(
            "Items/Checkpoints/Checkpoint/Checkpoint (Flag Idle)(64x64).png"),
        SpriteAnimationData.sequenced(
          amount: 10,
          stepTime: 0.05,
          textureSize: Vector2.all(64),
        ),
      );
    });
  }

  @override
  FutureOr<void> onLoad() {
    add(RectangleHitbox(
      position: Vector2(18, 56),
      size: Vector2(35, 8),
      collisionType: CollisionType.passive,
    ));
    animation = SpriteAnimation.fromFrameData(
      game.images
          .fromCache("Items/Checkpoints/Checkpoint/Checkpoint (No Flag).png"),
      SpriteAnimationData.sequenced(
        amount: 1,
        stepTime: 1,
        textureSize: Vector2.all(64),
      ),
    );
    return super.onLoad();
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player && !isReachedCheckpoint) reachedCheckpoint();
    super.onCollisionStart(intersectionPoints, other);
  }
}
