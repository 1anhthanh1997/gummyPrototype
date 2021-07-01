import 'package:flutter/material.dart';

class ColorModel {
   int id;
   String color;
   Offset position;
   int count;

  ColorModel(
      {this.id = 0,
      this.color = '',
      this.position = const Offset(0, 0),
      this.count = 0});

  ColorModel.fromJson(Map<String,dynamic>json){
    id=json['id'];
    color=json['color'];
    position=Offset(json['position']['dx'],json['position']['dy']);
    count=json['time'];
  }
}
