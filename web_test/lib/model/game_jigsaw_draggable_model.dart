import 'package:flutter/material.dart';

class GameJigsawDraggableModel{
   List<dynamic> images;
   int groupId;
   Offset position;
   double width;
   double height;
   int duration;
   bool status;

  GameJigsawDraggableModel({
    this.images,
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