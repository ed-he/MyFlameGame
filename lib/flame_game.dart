import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flamegame/components/player.dart';
import 'package:flamegame/components/level.dart';
import 'package:flutter/painting.dart';

class MyFlameGame extends FlameGame with HasKeyboardHandlerComponents, DragCallbacks, HasCollisionDetection {
  @override
  Color backgroundColor() => const Color(0xFF211F30);

  late final CameraComponent cam;
  late JoystickComponent joystick;
  bool showJoystick = true;
  Player player = Player(character:  'Mask Dude');

  @override
  FutureOr<void> onLoad() async {
    // Load all images into cache
    await images.loadAllImages();

    final world = Level(
      levelName: 'level-01', 
      player: player
    );

    cam = CameraComponent.withFixedResolution(
      world: world, 
      width: 640, 
      height: 360);
    cam.priority = 0;
    cam.viewfinder.anchor = Anchor.topLeft;

    await addAll([cam, world]);
    if (showJoystick) {
      addJoystick();
    }
    return super.onLoad();
  }
  
  @override
  void update(double dt) {
    if (showJoystick) {
      _updateJoystick();
    }
    super.update(dt);
  }

  void addJoystick() {
    joystick = JoystickComponent(
      priority: 1,
      knob: SpriteComponent(
        sprite: Sprite(
          images.fromCache('Joystick/Knob.png')),
      ),
      background: SpriteComponent(
        sprite: Sprite(
          images.fromCache('Joystick/Joystick.png')),
      ),
      margin: const EdgeInsets.only(left: 32, bottom: 32),
    );
    add(joystick);
  }
  
  void _updateJoystick() {
    switch (joystick.direction) {
      case JoystickDirection.left:
      case JoystickDirection.upLeft:
      case JoystickDirection.downLeft:
        player.horizontalMovement = -1;
        break;
      case JoystickDirection.right:
      case JoystickDirection.upRight:
      case JoystickDirection.downRight:
        player.horizontalMovement = 1;
        break;
      case JoystickDirection.up:
        player.hasJumped = true;
        break;
      default:
        player.horizontalMovement = 0;
        player.hasJumped = false;
    }
  }
}