import 'package:flutter/material.dart';

class GameDrawModel {
  late int id;
  late String image;
  late String path;
  late Offset position;
  late String color;
  late bool canDraw;

  GameDrawModel(
      {this.id = 0,
      this.image = '',
      this.path = '',
      this.position = const Offset(0, 0),
      this.color = '',
      this.canDraw = true});

  GameDrawModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    image = json['image'];
    path = json['path'];
    position = Offset(json['position']['dx'], json['position']['dy']);
    color=json['color'];
    canDraw = json['canDraw'];
  }
}
