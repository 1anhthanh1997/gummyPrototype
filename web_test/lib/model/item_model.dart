import 'package:flutter/material.dart';

class ItemModel {
  int id;
  String image;
  int type;
  Offset position;
  int groupId;
  double height;
  double width;
  int status = 0;
  String color;
  int duration = 0;
  int count = 0;
  bool canDraw = false;
  Offset startPosition = Offset(0, 0);
  Offset endPosition = Offset(0, 0);
  String path;

  ItemModel(
      {this.id = 0,
      this.image = '',
      this.type = 0,
      this.position = const Offset(0, 0),
      this.groupId = 0,
      this.height = 0,
      this.width = 0,
      this.status = 0,
      this.color,
      this.duration,
      this.count,
      this.canDraw,
      this.startPosition,
      this.endPosition,
      this.path});

  ItemModel.fromJson(Map<String, dynamic> json) {
    image = json['image'] == null ? '' : json['image'];
    type = json['type'] == null ? 0 : json['type'];
    position = json['position'] == null
        ? Offset(0, 0)
        : Offset(json['position']['dx'], json['position']['dy']);
    groupId = json['groupId'] == null ? 0 : json['groupId'];
    id = json['id'] == null ? 0 : json['id'];
    height = json['height'] == null ? 0 : json['height'];
    width = json['width'] == null ? 0 : json['width'];
    color = json['color'] == null ? '' : json['color'];
    duration = json['duration'] == null ? 0 : json['duration'];
    count = json['count'] == null ? 0 : json['count'];
    canDraw = json['canDraw'] == null ? false : json['canDraw'];
    startPosition =
        json['startPosition'] == null ? Offset(0, 0) : Offset(json['startPosition']['dx'], json['startPosition']['dy']);
    endPosition =
        json['endPosition'] == null ? Offset(0, 0) : Offset(json['endPosition']['dx'], json['endPosition']['dy']);
    path = json['path'] == null ? '' : json['path'];
    status=0;
  }
}
