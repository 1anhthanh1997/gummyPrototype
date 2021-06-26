import 'dart:core';

class GameModel {
  late String id;
  late int levelScore;
  late List<String> tag;
  late int gameType;
  late int orderIndex;
  late int createDate;
  late String author;
  late int lastUpdate;
  late String gameName;
  late String parentId;
  late String gameData;
  late List<String> gameAssets;

  GameModel(
      {this.id = '',
      this.levelScore = 0,
      required this.tag,
      this.gameType = 1,
      this.orderIndex = 1,
      this.createDate = 0,
      this.author = '',
      this.lastUpdate = 0,
      this.gameName = '',
      this.parentId = '',
      this.gameData = '',
      required this.gameAssets});

  GameModel.fromJson(Map<String,dynamic> json){
    id=json['id'];
    levelScore=json['levelScore'];
    tag=json['tag'];
    gameType=json['gameType'];
    orderIndex=json['orderIndex'];
    createDate=json['createDate'];
    author=json['author'];
    lastUpdate=json['lastUpdate'];
    gameName=json['gameName'];
    parentId=json['parentId'];
    gameData=json['gameData'];
    gameAssets=json['gameAssets'];
  }
}
