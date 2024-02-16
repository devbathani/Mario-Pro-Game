import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:mario_pro_game/components/checkpoint/checkpoint.dart';
import 'package:mario_pro_game/components/collisions_block.dart';
import 'package:mario_pro_game/components/custom_background.dart';
import 'package:mario_pro_game/components/enemies/chicken.dart';
import 'package:mario_pro_game/components/fruit/fruit.dart';
import 'package:mario_pro_game/components/player/player.dart';
import 'package:mario_pro_game/components/saw/saw.dart';
import 'package:mario_pro_game/mario_pro_game.dart';

class MarioProMap extends World with HasGameRef<MarioProGame> {
  late TiledComponent map;
  final Player player;
  final String level;
  List<CollisionsBlock> collisionBlockList = [];

  MarioProMap({required this.level, required this.player});

  void scrollingBackground() {
    final backgroundLayer = map.tileMap.getLayer("Background");

    if (backgroundLayer != null) {
      final backGroundColor =
          backgroundLayer.properties.getValue("BackgroundColor");

      final backgroundTile = CustomBackground(
        color: backGroundColor ?? "Purple",
        position: Vector2(0, 0),
      );

      add(backgroundTile);
    }
  }

  void spawingObjects() {
    final spawnPointsLayer = map.tileMap.getLayer<ObjectGroup>("Spawnpoints");
    if (spawnPointsLayer != null) {
      for (final spawnPoint in spawnPointsLayer.objects) {
        switch (spawnPoint.class_) {
          case 'Player':
            player.position = Vector2(spawnPoint.x, spawnPoint.y);
            player.scale.x = 1;
            add(player);
            break;
          case 'Fruit':
            final fruit = Fruit(
              fruitName: spawnPoint.name,
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
            );
            add(fruit);
            break;
          case 'Checkpoint':
            final checkPoint = Checkpoint(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
            );
            add(checkPoint);
            break;
          case 'Saw':
            final isVertical = spawnPoint.properties.getValue("isVertical");
            final offNeg = spawnPoint.properties.getValue("offNeg");
            final offPos = spawnPoint.properties.getValue("offPos");
            final saw = Saw(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
              isVertical: isVertical,
              offNeg: offNeg,
              offPos: offPos,
            );
            add(saw);
            break;
          case 'Chicken':
            final offNeg = spawnPoint.properties.getValue("offNeg");
            final offPos = spawnPoint.properties.getValue("offPos");
            final chicken = Chicken(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
              offNeg: offNeg,
              offPos: offPos,
            );
            add(chicken);
            break;
          default:
        }
      }
    }
  }

  void addCollisions() {
    final collisionsLayer = map.tileMap.getLayer<ObjectGroup>('Collisions');
    if (collisionsLayer != null) {
      for (final collision in collisionsLayer.objects) {
        switch (collision.class_) {
          case 'Platform':
            final platform = CollisionsBlock(
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
              isPlatform: true,
            );
            collisionBlockList.add(platform);
            add(platform);
            break;
          default:
            final block = CollisionsBlock(
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
            );
            collisionBlockList.add(block);
            add(block);
        }
      }
    }
    player.collisionBlockList = collisionBlockList;
  }

  @override
  Future<void> onLoad() async {
    map = await TiledComponent.load(level, Vector2.all(16));
    add(map);
    scrollingBackground();
    spawingObjects();
    addCollisions();

    return super.onLoad();
  }
}
