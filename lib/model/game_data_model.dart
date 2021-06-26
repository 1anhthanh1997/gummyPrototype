import 'package:flutter/material.dart';

class GameDataModel {
  late String image;
  late String path;
  late Offset position;
  late Offset startPoint;
  late Offset endPoint;

  GameDataModel(
      {this.image = '',
      this.path = '',
      this.position = const Offset(0, 0),
      this.startPoint = const Offset(0, 0),
      this.endPoint = const Offset(0, 0)});

  GameDataModel.fromJson(Map<String, dynamic> json) {
    image = json['image'];
    path = json['path'];
    position = Offset(json['position']['dx'], json['position']['dy']);
    startPoint =
        Offset(json['startPosition']['dx'], json['startPosition']['dy']);
    endPoint = Offset(json['endPosition']['dx'], json['endPosition']['dy']);
  }
}
