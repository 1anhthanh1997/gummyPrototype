import 'package:flutter/material.dart';

class ItemModel {
  int id;
  int type;
  int duration;
  Offset position;
  Offset endPosition;
  bool status;

  ItemModel(
      {this.id = 0,
      this.type = 0,
      this.duration = 0,
      this.position = const Offset(0, 0),
      this.endPosition = const Offset(0, 0),
      this.status = false});
}
