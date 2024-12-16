import 'dart:async';
import 'dart:io';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flamegame/components/Burd.dart';
import 'package:flamegame/components/Pipe.dart';
import 'package:flamegame/components/Saw.dart';
import 'package:flamegame/components/collision_block.dart';
import 'package:flamegame/components/player.dart';

class Level extends World {
  final String levelName;
  final Player player;
  late TiledComponent level;
  List<CollisionBlock> collisionBlocks = [];

  Level({required this.levelName, required this.player});

  @override
  Future<void> onLoad() async {
    level = await TiledComponent.load('$levelName.tmx', Vector2.all(16));
    add(level);
    
    _renderWorld();
    _addCollisions();

    return super.onLoad();
  }
  
  void _renderWorld() {
    final spawnPointLayer = level.tileMap.getLayer<ObjectGroup>('Spawnpoints');
    if (spawnPointLayer != null) {
      for(final spawnPoint in spawnPointLayer.objects) {
        switch (spawnPoint.class_) {
          case 'Player':
            player.position = Vector2(spawnPoint.x, spawnPoint.y);
            add(player);
            break;
          case 'Pipe':
            GreenPipe pipe = GreenPipe(Vector2(spawnPoint.x, spawnPoint.y), Vector2(spawnPoint.width, spawnPoint.height));
            add(pipe);
            break;
          case 'Burd':/*
            Burd burd = Burd(
              position: Vector2(spawnPoint.x, spawnPoint.y), 
              size: Vector2(spawnPoint.width, spawnPoint.height));
            add(burd);// */
            break;
          case 'Saw':
            final sawRange = spawnPoint.properties.getValue('range');
            Saw saw = Saw(
              range: sawRange,
              position: Vector2(spawnPoint.x, spawnPoint.y), 
              size: Vector2(spawnPoint.width, spawnPoint.height));
            add(saw);
            break;
          default:
        }
      }
    }
  }
  
  void _addCollisions() {
    final collisionsLayer = level.tileMap.getLayer<ObjectGroup>('Collisions');
    if (collisionsLayer != null) {
      for (final collision in collisionsLayer.objects) {
        switch (collision.class_) {
          case 'Platform':
            final platform = CollisionBlock(
              Vector2(collision.x, collision.y), 
              Vector2(collision.width, collision.height),
              isPlatform: true,
            );
            collisionBlocks.add(platform);
            add(platform);
            break;
          default:
            final block = CollisionBlock(
              Vector2(collision.x, collision.y), 
              Vector2(collision.width, collision.height),
            );
            collisionBlocks.add(block);
            add(block);
        }
      }
    }
    player.collisionBlocks = collisionBlocks;
  }
} // */