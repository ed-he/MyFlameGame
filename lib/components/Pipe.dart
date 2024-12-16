import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flamegame/components/player.dart';
import 'package:flamegame/flame_game.dart';

class GreenPipe extends SpriteComponent with HasGameRef<MyFlameGame>, CollisionCallbacks {

  GreenPipe(
  position, 
  size, 
  ) : super(
    position: position, 
    size: size);

  @override
  FutureOr<void> onLoad() {
    _loadSprite();
    add(RectangleHitbox(size: size));
    return super.onLoad();
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    
    if (other is Player) {
      other.removeFromParent();
    }

    super.onCollision(intersectionPoints, other);
  }
  
  void _loadSprite() {
    sprite = Sprite(game.images.fromCache('Other/Pipe.png'));
    flipVerticallyAroundCenter();
  }
}