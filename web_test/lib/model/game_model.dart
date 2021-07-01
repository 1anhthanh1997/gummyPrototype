import 'dart:core';

class GameModel {
   String id;
   int levelScore;
   List<String> tag;
   int gameType;
   int orderIndex;
   int createDate;
   String author;
   int lastUpdate;
   String gameName;
   String parentId;
   String gameData;
   List<String> gameAssets;

  GameModel(
      {this.id = '',
      this.levelScore = 0,
      this.tag,
      this.gameType = 1,
      this.orderIndex = 1,
      this.createDate = 0,
      this.author = '',
      this.lastUpdate = 0,
      this.gameName = '',
      this.parentId = '',
      this.gameData = '',
      this.gameAssets});

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
