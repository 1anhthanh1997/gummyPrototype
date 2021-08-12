import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:web_test/config/id_config.dart';

class SquareParticle {
  Animatable tween;
  AnimationProgress progress;
  double size;
  double bubbleHeight;
  double bubbleWidth;
  String balloonShardUrl;
  double baseRatio;

  SquareParticle(
      Duration time,
      double ratio,
      double height,
      double width,
      String urlImage,
      List<double> randomSize,
      int duration,
      double maxX,
      double maxY) {
    final random = Random();
    final x =
        (maxX) * ratio * random.nextDouble() * (random.nextBool() ? 1 : -1);
    final y =
        (maxY) * ratio * random.nextDouble() * (random.nextBool() ? 1 : -1);
    print(duration);

    tween = MultiTrackTween([
      Track("x").add(
          Duration(milliseconds: duration), Tween(begin: 0.0, end: x),
          curve: Curves.easeOut),
      Track("y").add(
          Duration(milliseconds: duration), Tween(begin: 0.0, end: y),
          curve: Curves.easeOut),
      Track("opacity").add(
          Duration(milliseconds: duration), Tween(begin: 1.0, end: 0.0),
          curve: Curves.easeIn)
    ]);
    progress = AnimationProgress(
        startTime: time, duration: Duration(milliseconds: duration+500));
    Random random2 = Random();
    List<double> sizeArr =
        randomSize.length == 0 ? [10.0, 15.0, 20.0, 27.0, 35.0] : randomSize;
    size = sizeArr[random2.nextInt(sizeArr.length)];
    bubbleHeight = height;
    bubbleWidth = width;
    balloonShardUrl = urlImage;
    baseRatio = ratio;
  }

  buildWidget(Duration time, Color color, bool isBasic) {
    final animation = tween.transform(progress.progress(time));
    return Positioned(
      left: animation["x"] + bubbleWidth / 2,
      top: animation["y"] + bubbleHeight / 3,
      child: Opacity(
        opacity: animation["opacity"],
        child: isBasic
            ? Container(
                width: size * baseRatio,
                height: size * baseRatio,
                decoration: BoxDecoration(shape: BoxShape.circle, color: color),
              )
            : Container(
                width: size * baseRatio,
                height: size * baseRatio,
                child: SvgPicture.asset(
                  balloonShardUrl,
                  color: color,
                ),
              ),
      ),
    );
  }
}
