import 'package:web_test/model/step_model.dart';

class ParentGameModel {
  int id;
  int levelScore;
  List<int> tags;
  int gameType;
  int age;
  int level;
  int orderIndex;
  String gameName;
  int createDate;
  int lastUpdate;
  String gameAssets;
  List<StepModel> gameData;

  ParentGameModel(
      {this.id = 0,
      this.levelScore,
      this.tags,
      this.gameType,
      this.age,
      this.level,
      this.orderIndex,
      this.gameName,
      this.createDate,
      this.lastUpdate,
      this.gameAssets,
      this.gameData});

  List<StepModel> getStepList(List stepListJson) {
    List<StepModel> stepList = [];
    stepList = stepListJson
        .map((imageInfo) => new StepModel.fromJson(imageInfo))
        .toList();
    return stepList;
  }

  ParentGameModel.fromJson(Map<String, dynamic> json) {
    id = json['id'] == null ? 0 : json['id'];
    levelScore = json['levelScore'] == null ? 0 : json['levelScore'];
    tags=json['tags']==null?[]:json['tags'];
    gameType = json['gameType'] == null ? 0 : json['gameType'];
    age=json['age']==null?0:json['age'];
    level=json['level']==null?0:json['level'];
    orderIndex=json['orderIndex']==null?0:json[orderIndex];
    gameName=json['gameName']==null?'':json['gameName'];
    createDate=json['createDate']==null?0:json['createDate'];
    lastUpdate=json['lastUpdate']==null?0:json['lastUpdate'];
    gameAssets=json['gameAssets']==null?'':json['gameAssets'];
    gameData=json['gameData']==null?[]:getStepList(json['gameData']);
  }
}
