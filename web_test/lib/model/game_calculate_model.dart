import 'package:flutter/material.dart';

class GameCalculateModel{
   int id;
   String image;
   int type;
   Offset position;
   int groupId;
   double height;
   double width;
   int status=0;
   String color;
   int duration=0;

  GameCalculateModel({
    this.id=0,
    this.image='',
    this.type=0,
    this.position=const Offset(0,0),
    this.groupId=0,
    this.height=0,
    this.width=0,
    this.status=0,
    this.color,
    this.duration
});
  GameCalculateModel.fromJson(Map<String,dynamic>json){
    image=json['image'];
    type=json['type'];
    position=Offset(json['position']['dx'],json['position']['dy']);
    groupId=json['groupId'];
    id=json['id'];
    height=json['height'];
    width=json['width'];
    color=json['color'];
  }

}