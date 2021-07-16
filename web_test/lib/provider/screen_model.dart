import 'dart:math';

import 'package:flutter/material.dart';
import 'package:web_test/db/games_database.dart';
import 'package:web_test/model/item_model.dart';
import 'package:web_test/model/type_model.dart';
import 'package:web_test/model/user_model.dart';

class ScreenModel extends ChangeNotifier {
  double screenWidth;
  double screenHeight;
  double ratio;
  BuildContext currentContext;
  var gameData;
  int currentGameId = 0;
  var currentGame;
  int currentStep = 0;
  String localPath;
  User currentUser = User(
      id: 1, name: 'Thanh', image: '', correctTime: 0, wrongTime: 0, score: 8);
  List<Type> typeList = [];

  void setContext(BuildContext context) {
    currentContext = context;
  }

  double getScreenWidth() {
    screenWidth = MediaQuery.of(currentContext).size.width;
    return screenWidth;
  }

  double getScreenHeight() {
    screenHeight = MediaQuery.of(currentContext).size.height;
    return screenHeight;
  }

  double getRatio() {
    double heightRatio = getScreenHeight() / 375;
    double widthRatio = getScreenWidth() / 812;
    ratio = heightRatio > widthRatio ? widthRatio : heightRatio;
    return ratio;
  }

  Path scalePath(Path path) {
    final Matrix4 matrix4 = Matrix4.identity();
    matrix4.scale(ratio, ratio);
    return path.transform(matrix4.storage);
  }

  void nextStep() async {
    if (currentStep < currentGame['gameData'].length - 1) {
      currentStep++;
    } else {
      nextGame();
    }
    await Future.delayed(Duration(milliseconds: 300));
    notifyListeners();
  }

  void addUserScore() async {
    int oldLevel = currentUser.score ~/ 8;
    currentUser.correctTime++;
    currentUser.score += pow(2, currentUser.correctTime);
    int newLevel = currentUser.score ~/ 8;
    if (newLevel > oldLevel) {
      currentUser.score = newLevel * 8;
      currentUser.correctTime = 0;
      currentUser.wrongTime = 0;
    }
    await GamesDatabase.instance.updateUser(currentUser);
  }

  void minusUserScore() async {
    int oldLevel = currentUser.score ~/ 8;
    currentUser.wrongTime++;
    currentUser.score -= pow(2, currentUser.wrongTime);
    if (currentUser.score < 8) {
      currentUser.score = 8;
    }
    int newLevel = currentUser.score ~/ 8;
    if (newLevel < oldLevel) {
      currentUser.correctTime = 0;
      currentUser.wrongTime = 0;
    }
    await GamesDatabase.instance.updateUser(currentUser);
  }

  int randomWithPiority(List<Type> typeList) {
    Random random = Random();
    double randomValue = random.nextDouble();
    double totalScore = 0;
    for (int idx = 0; idx < typeList.length; idx++) {
      Type type = typeList[idx];
      totalScore += type.score / 100;
      if (totalScore >= randomValue) {
        return type.id;
      }
    }
  }

  void getNextGameId() {
    int randomType=randomWithPiority(typeList);
  }

  void nextGame() async {
    addUserScore();
    getNextGameId();
    currentGameId++;
    currentGameId = currentGameId % 7;
    currentStep = 0;
    getCurrentGame();
    await Future.delayed(Duration(milliseconds: 300));
    notifyListeners();
  }

  void getCurrentGame() {
    currentGame = gameData[currentGameId];
  }

  void getTypeList() async {
    typeList = await GamesDatabase.instance.readAllTypes();
  }

  void changeTypeScore() async {
    var currentType = currentGame['gameType'];
    typeList.map((type) async {
      if (type.typeId == currentType) {
        type.score--;
      } else {
        type.score += 1 / (typeList.length - 1);
      }
      await GamesDatabase.instance.updateType(type);
    }).toList();
  }

  void skipGame() async {
    randomWithPiority(typeList);
    minusUserScore();
    changeTypeScore();
    currentGameId++;
    currentGameId = currentGameId % 7;
    currentStep = 0;
    getCurrentGame();
    await Future.delayed(Duration(milliseconds: 300));
    notifyListeners();
  }
}
