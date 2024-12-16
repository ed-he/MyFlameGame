import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flamegame/components/collision_block.dart';
import 'package:flamegame/components/player_hitbox.dart';
import 'package:flamegame/components/utils.dart';
import 'package:flamegame/flame_game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/services/hardware_keyboard.dart';
import 'package:flutter/src/services/keyboard_key.g.dart';

enum PlayerState {idle, running, jumping, falling}

// GroupComponent is a group of animations
class Player extends SpriteAnimationGroupComponent with HasGameRef<MyFlameGame>, KeyboardHandler, CollisionCallbacks {
  String character;
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runningAnimation;
  late final SpriteAnimation jumpingAnimation;
  late final SpriteAnimation fallingAnimation;

  final double stepTime = 0.05;
  final double _gravity = 9.81;
  final double _jumpForce = 460;
  final double _terminalVelocity = 300;
  double horizontalMovement = 0;
  double moveSpeed = 100;

  Vector2 velocity = Vector2.zero();
  List<CollisionBlock> collisionBlocks = [];
  PlayerHitbox hitbox = PlayerHitbox(
    offsetX: 10, 
    offsetY: 4, 
    width: 14, 
    height: 28
  );

  bool isOnGround = false;
  bool hasJumped = false;
  bool isFacingRight = true;

  Player({
    position, 
    this.character = 'Ninja Frog'
  }) : super(position: position, priority: 1);

  @override //Flame
  FutureOr<void> onLoad() {
    _loadAllAnimations();
    debugMode = true;
    add(RectangleHitbox(
      position: Vector2(
        hitbox.offsetX,
        hitbox.offsetY),// */ 
      size: Vector2(
        hitbox.width,
        hitbox.height
      )
    ));
    return super.onLoad();
  }

  @override //Flame
  void update(double dt) {
    _updatePlayerState();
    _updatePlayerMovement(dt);
    _checkHorizontalCollisions();
    _applyGravity(dt);
    _checkVerticalCollisions();
    super.update(dt);
  }

  @override //KeyboardHandler
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    horizontalMovement = 0;
    final isLeftKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyA);
    final isRightKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyD);

    horizontalMovement += isLeftKeyPressed ? -1 : 0;
    horizontalMovement += isRightKeyPressed ? 1 : 0;

    hasJumped = keysPressed.contains(LogicalKeyboardKey.space);

    return super.onKeyEvent(event, keysPressed);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    /*
    if (other is CollisionBlock) {
      if (other.isPlatform) {
        _checkCollisionPlatform(other);
      } else {
        _checkCollisionNonPlatform(other);
      }
    }// */
    super.onCollision(intersectionPoints, other);
  }
  
  void _loadAllAnimations() {
    idleAnimation = _spriteAnimation('Idle', 11);
    runningAnimation = _spriteAnimation("Run", 12);
    jumpingAnimation = _spriteAnimation("Jump", 1);
    fallingAnimation = _spriteAnimation("Fall", 1);

    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.running: runningAnimation,
      PlayerState.jumping: jumpingAnimation,
      PlayerState.falling: fallingAnimation,
    };

    current = PlayerState.running;
  }

  SpriteAnimation _spriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Main Characters/$character/$state (32x32).png'),
      SpriteAnimationData.sequenced(
        amount: amount, 
        stepTime: stepTime, 
        textureSize: Vector2.all(32)
      ),
    );
  }
  
  void _updatePlayerState() {
    PlayerState playerState =  PlayerState.idle;

    if (velocity.x < 0 && scale.x > 0) {
      flipHorizontallyAroundCenter();
    } else if (velocity.x > 0 && scale.x < 0) {
      flipHorizontallyAroundCenter();
    } 

    if (velocity.x > 0 || velocity.x < 0) {
      playerState = PlayerState.running;
    }

    if (velocity.y < 0) {
      playerState = PlayerState.jumping;
    }

    if (velocity.y > _gravity) {
      playerState = PlayerState.falling;
    }

    current = playerState;
  }

  void _updatePlayerMovement(double dt) {
    if (hasJumped && isOnGround) {
      _playerJump(dt);
    }

    velocity.x = horizontalMovement * moveSpeed;
    position.x += velocity.x * dt;
  }
  
  void _playerJump(double dt) {
    velocity.y = -_jumpForce;
    position.y += velocity.y * dt;
    isOnGround = false;
    hasJumped = false;
  }
  /*
  void _checkCollisionNonPlatform(CollisionBlock block) {
    if (velocity.x > 0) {
      velocity.x = 0;
      position.x = block.x - hitbox.offsetX - hitbox.width;
    }
    if (velocity.x < 0) {
      velocity.x = 0;
      position.x = block.x + block.width + hitbox.offsetX + hitbox.width;
    }
    if (velocity.y > 0) {
      velocity.y = 0;
      position.y = block.y - hitbox.offsetY - hitbox.height;
      isOnGround = true;
    }
    if (velocity.y < 0) {
      velocity.y = 0;
      position.y = block.y + block.height - hitbox.offsetY;
    }
  }

  void _checkCollisionPlatform(CollisionBlock block) {
    if (velocity.y > 0) {
      velocity.y = 0;
      position.y = block.y - hitbox.offsetY - hitbox.height;
      isOnGround = true;
    }
  }// */

  void _checkHorizontalCollisions() {
    for (final block in collisionBlocks) {
      if (!block.isPlatform) {
        if (checkCollision(this, block)) {
          if (velocity.x > 0) {
            velocity.x = 0;
            position.x = block.x - hitbox.offsetX - hitbox.width;
            break;
          }
          if (velocity.x < 0) {
            velocity.x = 0;
            position.x = block.x + block.width + hitbox.offsetX + hitbox.width;
            break;
          }
        }
      }
    }
  }
  
  void _applyGravity(double dt) {
    velocity.y += _gravity;
    velocity.y = velocity.y.clamp(-_jumpForce, _terminalVelocity);
    position.y += velocity.y * dt;
  }
  
  void _checkVerticalCollisions() {
    for (final block in collisionBlocks) {
      if (block.isPlatform) {
        if (checkCollision(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - hitbox.offsetY - hitbox.height;
            isOnGround = true;
            break;
          }
        }
      } else {
        if (checkCollision(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - hitbox.offsetY - hitbox.height;
            isOnGround = true;
            break;
          }
          if (velocity.y < 0) {
            velocity.y = 0;
            position.y = block.y + block.height - hitbox.offsetY;
            break;
          }
        }
      }
    }
  }

}