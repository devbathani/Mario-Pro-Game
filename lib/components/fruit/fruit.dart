import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:mario_pro_game/mario_pro_game.dart';
import 'package:mario_pro_game/model/custom_hitbox.dart';

class Fruit extends SpriteAnimationComponent
    with HasGameRef<MarioProGame>, CollisionCallbacks {
  final String fruitName;
  Fruit({
    position,
    size,
    this.fruitName = "Apple",
  }) : super(size: size, position: position);

  final double stepTime = 0.04;
  bool frutiCollected = false;
  CustomHitBoxEntity customHitBoxEntity =
      CustomHitBoxEntity(offSetX: 10, offSetY: 10, width: 12, height: 12);

  void collidedWithPlayer() async {
    if (!frutiCollected) {
      if (game.playSound) {
        FlameAudio.play("collect_fruit.wav");
      }
      animation = SpriteAnimation.fromFrameData(
        game.images.fromCache('Items/Fruits/Collected.png'),
        SpriteAnimationData.sequenced(
          amount: 6,
          stepTime: stepTime,
          textureSize: Vector2.all(32),
          loop: false,
        ),
      );
      frutiCollected = true;
    }
    await Future.delayed(const Duration(milliseconds: 300));
    removeFromParent();
  }

  @override
  FutureOr<void> onLoad() {
    priority = -1;

    add(
      RectangleHitbox(
        position:
            Vector2(customHitBoxEntity.offSetX, customHitBoxEntity.offSetY),
        size: Vector2(customHitBoxEntity.width, customHitBoxEntity.height),
        collisionType: CollisionType.passive,
      ),
    );
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('Items/Fruits/$fruitName.png'),
      SpriteAnimationData.sequenced(
        amount: 17,
        stepTime: stepTime,
        textureSize: Vector2.all(32),
      ),
    );

    return super.onLoad();
  }
}
