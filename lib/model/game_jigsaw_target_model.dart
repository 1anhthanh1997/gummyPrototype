import 'package:flutter/material.dart';

class GameJigsawTargetModel{
  late String images;
  late int groupId;
  late Offset position;
  late double width;
  late double height;
  late int correctRotateTime;

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