import 'package:flutter/material.dart';
import 'package:web_test/db/games_database.dart';
import 'package:web_test/model/item_model.dart';
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
  User currentUser = User(id: 1, name: 'Thanh', image: '', score: 8);

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
    print(currentStep < currentGame['gameData'].length - 1);
    if (currentStep < currentGame['gameData'].length - 1) {
      currentStep++;
    } else {
      nextGame();
    }
    await Future.delayed(Duration(milliseconds: 300));
    notifyListeners();
  }

  // void addUserScore() async {
  //   User newUser=currentUser;
  //   newUser.score=
  // }

  void nextGame() async {
    print('Next Game');
    currentGameId++;
    currentGameId = currentGameId % 7;
    currentStep = 0;
    getCurrentGame();
    await Future.delayed(Duration(milliseconds: 300));
    notifyListeners();
  }

  void getCurrentGame() {
    print('Current Game Id:${currentGameId}');
    currentGame = gameData[currentGameId];
  }
}
