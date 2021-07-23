import 'dart:math';

import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';

class SquareParticle {
  Animatable tween;
  AnimationProgress progress;
  double size;

  SquareParticle(Duration time, double ratio) {
    final random = Random();
    final x =
        (100 + 50) * ratio * random.nextDouble() * (random.nextBool() ? 1 : -1);
    final y =
        (100 + 50) * ratio * random.nextDouble() * (random.nextBool() ? 1 : -1);

    tween = MultiTrackTween([
      Track("x").add(Duration(milliseconds: 400), Tween(begin: 0.0, end: x),curve: Curves.easeOut),
      Track("y").add(Duration(milliseconds: 400), Tween(begin: 0.0, end: y),curve: Curves.easeOut),
      Track("opacity").add(Duration(milliseconds: 400), Tween(begin: 1.0, end: 0.0),curve: Curves.easeIn)
    ]);
    progress = AnimationProgress(
        startTime: time, duration: Duration(milliseconds: 900));
    Random random2=Random();
    List<double>sizeArr=[10.0,15.0,20.0,27.0,35.0];
    size=sizeArr[random2.nextInt(sizeArr.length)];

  }

  buildWidget(Duration time, Color color) {

    final animation = tween.transform(progress.progress(time));
    return Positioned(
      left: animation["x"],
      top: animation["y"],
      child: Opacity(
        opacity: animation["opacity"],
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      ),
    );
  }
}
