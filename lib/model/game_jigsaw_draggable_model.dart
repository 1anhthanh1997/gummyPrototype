import 'package:flutter/material.dart';

class GameJigsawDraggableModel{
  late List<dynamic> images;
  late int groupId;
  late Offset position;
  late double width;
  late double height;
  late int duration;
  late bool status;

  GameJigsawDraggableModel({
    required this.images,
    this.groupId=0,
    this.position=const Offset(0,0),
    this.width=0,
    this.height=0,
    this.duration=0,
    this.status=false
});
  GameJigsawDraggableModel.fromJson(Map<String,dynamic>json){
    images=json['image'];
    groupId=json['groupId'];
    position=Offset(json['position']['dx'],json['position']['dy']);
    width=json['width'];
    height=json['height'];
    duration=0;
    status=false;
  }
}