import 'package:flutter/material.dart';

class GameJigsawTargetModel{
   String images;
   int groupId;
   Offset position;
   double width;
   double height;
   int correctRotateTime;

  GameJigsawTargetModel({
    this.images='',
    this.groupId=0,
    this.position=const Offset(0,0),
    this.width=0,
    this.height=0,
    this.correctRotateTime=0
  });
  GameJigsawTargetModel.fromJson(Map<String,dynamic>json){
    images=json['image'];
    groupId=json['groupId'];
    position=Offset(json['position']['dx'],json['position']['dy']);
    width=json['width'];
    height=json['height'];
    correctRotateTime=json['correctRotateTime'];
  }
}