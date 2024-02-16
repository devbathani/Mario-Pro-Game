import 'package:flame/components.dart';

class CollisionsBlock extends PositionComponent {
  CollisionsBlock({
    position,
    size,
    this.isPlatform = false,
  }) : super(position: position, size: size);
  bool isPlatform;
}
