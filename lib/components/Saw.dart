import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flamegame/components/player.dart';

class Saw extends SpriteAnimationComponent with HasGameRef<FlameGame>, CollisionCallbacks {

  double range;
  double startPos = 0;
  double endPos = 0;
  double tileSize = 16;
  double moveSpeed = 100;
  int moveDirection = 1;
  final double stepTime = 0.03;

  Saw ({
  this.range = 0,
  position, 
  size, 
  }) : super(
    position: position, 
    size: size);

  @override
  FutureOr<void> onLoad() {
    add(RectangleHitbox(size: size));
    startPos = position.x;
    endPos = position.x + range * tileSize;

    priority = -1;
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('Traps/Saw/On (38x38).png'), 
      SpriteAnimationData.sequenced(
        amount: 8, 
        stepTime: stepTime, 
        textureSize: Vector2.all(38)
      )
    );
    return super.onLoad();
  }

  @override
  void update(double dt) {
    _moveSaw(dt);
    super.update(dt);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player) {
      other.removeFromParent();
    }
    super.onCollision(intersectionPoints, other);
  }
  
  void _moveSaw(dt) {
    if (position.x >= endPos) {
      moveDirection = -1;
    } else if (position.x <= startPos) {
      moveDirection = 1;
    }
    position.x += moveDirection * moveSpeed * dt;
  }
}