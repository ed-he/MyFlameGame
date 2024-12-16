import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flamegame/components/player.dart';

class CollisionBlock extends PositionComponent with CollisionCallbacks {
  bool isPlatform;

  CollisionBlock(
    Vector2 position, 
    Vector2 size, 
    {
    this.isPlatform = false,
    }) : super(
      position: position, 
      size: size);

  @override
  FutureOr<void> onLoad() {
    add(RectangleHitbox(size: size));
    return super.onLoad();
  }
}