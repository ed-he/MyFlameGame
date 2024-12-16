import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flamegame/components/player.dart';
import 'package:flamegame/flame_game.dart';

class Projectile extends SpriteComponent with HasGameRef<MyFlameGame>, CollisionCallbacks {
  
  double moveSpeed = 100;
  Vector2 velocity = Vector2.zero();

  Projectile(
  position, 
  size, 
  ) : super(
    position: position, 
    size: size);

  @override
  FutureOr<void> onLoad() {
    _loadSprite();
    add(RectangleHitbox(position: Vector2(9, 9), size: Vector2(14, 14)));
    return super.onLoad();
  }

  @override
  void update(double dt) {
    _updatePosition(dt);
    super.update(dt);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player) {
      other.removeFromParent();
    }
    removeFromParent();
    super.onCollision(intersectionPoints, other);
  }
  
  void _loadSprite() {
    sprite = Sprite(game.images.fromCache('Other/Dust Particle.png'));
  }
  
  void _updatePosition(dt) {
    position.x += moveSpeed * dt; 
  }
}