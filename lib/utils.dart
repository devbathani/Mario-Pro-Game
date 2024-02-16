bool checkCollision(player, block) {
  final hitBox = player.customHitBoxEntity;
  final playerX = player.position.x + hitBox.offSetX;
  final playerY = player.position.y + hitBox.offSetY;
  final playerWidth = hitBox.width;
  final playerHeight = hitBox.height;
  final blockX = block.x;
  final blockY = block.y;
  final blockWidth = block.width;
  final blockHeight = block.height;
  final fixedx = player.scale.x < 0
      ? playerX - (hitBox.offSetX * 2) - playerWidth
      : playerX;
  final fixedy = block.isPlatform ? playerY + playerHeight : playerY;

  return (fixedy < blockY + blockHeight &&
      playerY + playerHeight > blockY &&
      fixedx < blockX + blockWidth &&
      fixedx + playerWidth > blockX);
}
