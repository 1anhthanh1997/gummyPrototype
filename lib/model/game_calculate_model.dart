import 'package:flutter/material.dart';

class GameCalculateModel{
  late int id;
  late String image;
  late int type;
  late Offset position;
  late int groupId;
  late double height;
  late double width;
  int status=0;

  GameCalculateModel({
    this.id=0,
    this.image='',
    this.type=0,
    this.position=const Offset(0,0),
    this.groupId=0,
    this.height=0,
    this.width=0,
    this.status=0
});
  GameCalculateModel.fromJson(Map<String,dynamic>json){
    image=json['image'];
    type=json['type'];
    position=Offset(json['position']['dx'],json['position']['dy']);
    groupId=json['groupId'];
    id=json['id'];
    height=json['height'];
    width=json['width'];
  }

}