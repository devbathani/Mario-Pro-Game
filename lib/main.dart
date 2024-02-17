import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mario_pro_game/mario_pro_game.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
  await Flame.device.setLandscape();
  MarioProGame game = MarioProGame();
  runApp(
    MaterialApp(
      home: GameWidget(
        game: kDebugMode ? MarioProGame() : game,
      ),
    ),
  );
}
