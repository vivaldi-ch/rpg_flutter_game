import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import 'package:rpg_flutter_game/components/commons/floating_text_component.dart';
import 'package:rpg_flutter_game/constants.dart';

void main() {
  runApp(const AppWidget());
}

class AppWidget extends StatefulWidget {
  const AppWidget({super.key});

  @override
  State<StatefulWidget> createState() => _AppWidgetState();
}

class _AppWidgetState extends State<AppWidget> {
  late final MySimpleRpgGame game;
  bool showRestart = false;

  @override
  void initState() {
    super.initState();

    game = MySimpleRpgGame(onGameEnd: () {
      setState(() {
        showRestart = true;
      });
    },);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(child: GameWidget(game: game)),
              showRestart
                  ? Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              showRestart = false;
                              game.reset();
                            });
                          },
                          child: const Text('Restart'),
                        ),
                      ),
                    )
                  : Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: ElevatedButton(
                          onPressed: () => game.attack(),
                          child: const Text('Attack'),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class MySimpleRpgGame extends FlameGame {
  late final TextComponent playerHealthText;
  late final TextComponent enemyHealthText;
  late final VoidCallback onGameEnd;
  late Player player;
  late Enemy enemy;
  bool isGameOver = false;
  bool isVictory = false;
  bool isWaitingForAnimation = false;

  MySimpleRpgGame({
    required this.onGameEnd
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    player = Player(initialHealth: 5);
    enemy = Enemy(initialHealth: 50);

    playerHealthText = TextComponent(
      text: 'Player Health: ${player.health}',
      position: Vector2(20, size.y - 20),
      textRenderer: TextPaint(style: const TextStyle(color: Colors.white)),
    );

    enemyHealthText = TextComponent(
      text: 'Enemy Health: ${enemy.health}',
      position: Vector2(20, 20),
      textRenderer: TextPaint(style: const TextStyle(color: Colors.red)),
    );

    resetGame();
  }

  void reset() {
    removeAll(children);
    resetGame();
    isGameOver = false;
    isVictory = false;
  }

  void resetGame() {
    player = Player(initialHealth: 5);
    enemy = Enemy(initialHealth: 50);

    playerHealthText.text = 'Player Health: ${player.health}';
    enemyHealthText.text = 'Enemy Health: ${enemy.health}';

    add(playerHealthText);
    add(enemyHealthText);
  }

  void attack() async {
    if (isWaitingForAnimation) {
      return;
    }

    if (!isGameOver && !isVictory && enemy.health > 0) {
      final damage = Random().nextInt(15) + 1;
      enemy.takeDamage(damage);
      enemyHealthText.text = 'Enemy Health: ${enemy.health}';

      await showFloatingTextComponent('Player attacks for $damage!');

      if (enemy.health <= 0) {
        isVictory = true;
        add(TextComponent(
          text: 'Victory!',
          position: size / 2,
          textRenderer: TextPaint(
              style: const TextStyle(color: Colors.green, fontSize: 40)),
          anchor: Anchor.center,
        ));

        onGameEnd();
      } else {
        enemyAction();
      }
    }
  }

  void enemyAction() async {
    if (!isGameOver && player.health > 0) {
      final action = Random().nextInt(2);

      if (action == 0) {
        player.takeDamage(1);
        playerHealthText.text = 'Player Health: ${player.health}';

        await showFloatingTextComponent('Enemy attacks the player!');

        if (player.health <= 0) {
          isGameOver = true;
          add(TextComponent(
            text: 'Game Over',
            position: size / 2,
            textRenderer: TextPaint(
                style: const TextStyle(color: Colors.red, fontSize: 40)),
            anchor: Anchor.center,
          ));

          onGameEnd();
        }
      } else {
        await showFloatingTextComponent('Enemy does nothing');
      }
    }
  }

  Future<void> showFloatingTextComponent(String text) async {
    final floatingText = FloatingTextComponent(text, Vector2(size.x / 2, size.y / 3));
    add(floatingText);

    isWaitingForAnimation = true;
    await Future.delayed(Duration(seconds: ANIMATION_DURATION_IN_SEC.toInt()));
    isWaitingForAnimation = false;
  }
}

class Player {
  int health;
  Player({required int initialHealth}) : health = initialHealth;

  void takeDamage(int damage) {
    health = max(0, health - damage);
  }
}

class Enemy {
  int health;
  Enemy({required int initialHealth}) : health = initialHealth;

  void takeDamage(int damage) {
    health = max(0, health - damage);
  }
}
