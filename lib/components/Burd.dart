import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flamegame/components/player.dart';
import 'package:flamegame/components/projectile.dart';
import 'package:flamegame/flame_game.dart';

class Burd extends SpriteComponent with HasGameRef<MyFlameGame>, CollisionCallbacks {
  int counter = 0;

  Burd({
  position, 
  size, 
  }) : super(
    position: position, 
    size: size);

  @override
  FutureOr<void> onLoad() {
    _loadSprite();
    add(RectangleHitbox(size: size));
    _spawnProjectile();
    return super.onLoad();
  }

  @override
  void update(double dt) {
    Projectile proj = Projectile(position, size);
    add(proj);
    super.update(dt);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    
    if (other is Player) {
      removeFromParent();
    }

    super.onCollision(intersectionPoints, other);
  }
  
  void _loadSprite() {
    sprite = Sprite(game.images.fromCache('Other/Burd.png'));
    debugMode = true;
  }
  
  void _spawnProjectile() {
      Projectile proj = Projectile(position, Vector2(2, 2));
      game.add(proj);
    if(counter == 10) {
      Projectile proj = Projectile(Vector2(212, 112), Vector2(2, 2));
      game.add(proj);
      //counter = 0;
    } else {
      counter++;
    }
  }
}