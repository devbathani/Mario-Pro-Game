import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/painting.dart';
import 'package:mario_pro_game/components/jump-button/jump_button.dart';
import 'package:mario_pro_game/components/map/mario_pro_map.dart';
import 'package:mario_pro_game/components/player/player.dart';

class MarioProGame extends FlameGame
    with
        HasKeyboardHandlerComponents,
        DragCallbacks,
        HasCollisionDetection,
        TapCallbacks {
  @override
  Color backgroundColor() => const Color(0xff211f30);
  late CameraComponent cameraComponent;
  late JoystickComponent joystickComponent;
  Player player = Player(character: "Mask Dude");
  bool showControlls = false;
  bool playSound = true;
  List<String> levelNames = [
    "mario_pro_04.tmx",
    "mario_pro_01.tmx",
    "mario_pro_02.tmx",
    "mario_pro_03.tmx",
    "mario_pro_05.tmx",
  ];
  int currentLevelIndex = 0;
  void addJoyStick() {
    joystickComponent = JoystickComponent(
      priority: 10,
      knob: SpriteComponent(
        sprite: Sprite(
          images.fromCache("HUD/knob.png"),
        ),
      ),
      background: SpriteComponent(
        sprite: Sprite(
          images.fromCache("HUD/joystick.png"),
        ),
      ),
      margin: const EdgeInsets.only(left: 32, bottom: 32),
    );
    add(joystickComponent);
  }

  void updateJoyStick(double dt) {
    switch (joystickComponent.direction) {
      case JoystickDirection.left:
      case JoystickDirection.upLeft:
      case JoystickDirection.downLeft:
        player.horizontalMovements = -1;
        break;
      case JoystickDirection.right:
      case JoystickDirection.downRight:
      case JoystickDirection.upRight:
        player.horizontalMovements = 1;
        break;
      //idle
      default:
        player.horizontalMovements = 0;
        break;
    }
  }

  @override
  FutureOr<void> onLoad() async {
    await images.loadAllImages();
    loadLevel();
    if (showControlls) {
      addJoyStick();
      add(JumpButton());
    }

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (showControlls) {
      updateJoyStick(dt);
    }

    super.update(dt);
  }

  void loadNextLevel() {
    removeWhere((component) => component is MarioProMap);
    if (currentLevelIndex < levelNames.length - 1) {
      currentLevelIndex++;
      loadLevel();
    } else {
      //no more levels
      //Menu will be added
    }
  }

  void loadLevel() async {
    await Future.delayed(const Duration(seconds: 1));
    MarioProMap worldMap =
        MarioProMap(level: levelNames[currentLevelIndex], player: player);
    cameraComponent = CameraComponent.withFixedResolution(
      world: worldMap,
      height: 360,
      width: 640,
    );
    cameraComponent.viewfinder.anchor = Anchor.topLeft;

    addAll([cameraComponent, worldMap]);
  }
}
