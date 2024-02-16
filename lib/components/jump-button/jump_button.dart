import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:mario_pro_game/mario_pro_game.dart';

class JumpButton extends SpriteComponent
    with HasGameRef<MarioProGame>, TapCallbacks {
  JumpButton();
  @override
  FutureOr<void> onLoad() {
    sprite = Sprite(
      game.images.fromCache("HUD/jump.png"),
    );
    position = Vector2(
      game.size.x - 32 - 64,
      game.size.y - 32 - 64,
    );
    priority = 100;
    return super.onLoad();
  }

  @override
  void onTapDown(TapDownEvent event) {
    game.player.hasJumped = true;
    super.onTapDown(event);
  }

  @override
  void onTapUp(TapUpEvent event) {
    game.player.hasJumped = false;
    super.onTapUp(event);
  }
}
