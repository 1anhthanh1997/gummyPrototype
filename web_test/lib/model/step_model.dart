import 'package:flutter/material.dart';
import 'package:web_test/model/item_model.dart';

class StepModel {
  int id;
  int parentId;
  int gameType;
  String background;
  List<ItemModel> items;

  StepModel(
      {this.id = 0, this.parentId, this.gameType, this.background, this.items});

  List<ItemModel> getItemList(List itemListJson){
    List<ItemModel> itemList=[];
    itemList =
        itemListJson.map((imageInfo) => new ItemModel.fromJson(imageInfo)).toList();
    return itemList;
  }

  StepModel.fromJson(Map<String, dynamic> json) {
    id=json['id']==null?0:json['id'];
    parentId=json['parentId']==null?0:json['parentId'];
    gameType=json['gameType']==null?0:json['gameType'];
    background=json['background']==null?0:json['background'];
    items=json['items']==null?[]:getItemList(json['items']);

  }
}
