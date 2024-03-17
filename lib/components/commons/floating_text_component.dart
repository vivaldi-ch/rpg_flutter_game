import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:rpg_flutter_game/constants.dart';

class FloatingTextComponent extends TextComponent with HasGameRef {
  late Timer _timer;

  FloatingTextComponent(String text, Vector2 position)
      : super(
          text: text,
          textRenderer:
              TextPaint(style: const TextStyle(fontSize: 24.0, color: Colors.white)),
          position: position,
          anchor: Anchor.topCenter,
        ) {
    // Set the timer to remove this component after 2 seconds
    _timer = Timer(ANIMATION_DURATION_IN_SEC, onTick: () {
      removeFromParent();
    });
    _timer.start();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _timer.update(dt);

    // Example of making the text "float" upwards
    y -= 1;
  }
}
