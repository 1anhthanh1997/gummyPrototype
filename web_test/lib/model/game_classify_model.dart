import 'package:flutter/material.dart';

class GameClassifyModel {
   int id;
   String image;
   Offset position;
   Offset endPosition;
   int groupId;
   bool status;

  GameClassifyModel(
      {this.id = 0,
      this.image = '',
      this.position = const Offset(0, 0),
      this.endPosition = const Offset(0, 0),
      this.groupId=0,
      this.status=false});

  GameClassifyModel.fromJson(Map<String,dynamic>json){
    this.id=json['id'];
    this.image=json['image'];
    this.position=Offset(json['position']['dx'],json['position']['dy']);
    this.endPosition=Offset(json['endPosition']['dx'],json['endPosition']['dy']);
    this.groupId=json['groupId'];
    this.status=false;
  }

}