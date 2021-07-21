import 'dart:math';

import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';

class SquareParticle {
  Animatable tween;
  AnimationProgress progress;

  SquareParticle(Duration time, double ratio) {
    final random = Random();
    final x =
        (100 + 50) * ratio * random.nextDouble() * (random.nextBool() ? 1 : -1);
    final y =
        (100 + 50) * ratio * random.nextDouble() * (random.nextBool() ? 1 : -1);

    tween = MultiTrackTween([
      Track("x").add(Duration(seconds: 1), Tween(begin: 0.0, end: x)),
      Track("y").add(Duration(seconds: 1), Tween(begin: 0.0, end: y)),
      Track("scale").add(Duration(seconds: 1), Tween(begin: 1.0, end: 0.0))
    ]);
    progress = AnimationProgress(
        startTime: time, duration: Duration(milliseconds: 900));
  }

  buildWidget(Duration time, Color color) {
    final animation = tween.transform(progress.progress(time));
    return Positioned(
      left: animation["x"],
      top: animation["y"],
      child: Transform.scale(
        scale: animation["scale"],
        child: Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      ),
    );
  }
}
