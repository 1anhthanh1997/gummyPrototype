import 'package:flutter/material.dart';

class GameDrawModel {
   int id;
   String image;
   String path;
   Offset position;
   String color;
   bool canDraw;
   double width;
   double height;
   int type;

  GameDrawModel(
      {this.id = 0,
      this.image = '',
      this.path = '',
      this.position = const Offset(0, 0),
      this.color = '',
      this.canDraw = true,
      this.width=0.0,
      this.height=0.0,
      this.type});

  GameDrawModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    image = json['image'];
    path = json['path'];
    position = Offset(json['position']['dx'], json['position']['dy']);
    color=json['color'];
    canDraw = json['canDraw'];
    width=json['width'];
    height=json['height'];
    type=json['type'];
  }
}
