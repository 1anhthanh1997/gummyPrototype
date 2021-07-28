import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:device_info/device_info.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:web_test/config/id_config.dart';
import 'package:web_test/db/games_database.dart';
import 'package:web_test/model/item_model.dart';
import 'package:web_test/model/parent_game_model.dart';
import 'package:web_test/model/type_model.dart';
import 'package:web_test/model/user_model.dart';
import 'package:web_test/prototype/general_screen/winning_screen.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:web_test/provider/music_controller.dart';

class ScreenModel extends ChangeNotifier {
  double screenWidth;
  double screenHeight;
  double ratio;
  BuildContext currentContext;
  List<ParentGameModel> gameData;
  int currentGameId = -1;
  ParentGameModel currentGame;
  int currentStep = 0;
  String localPath;
  User currentUser = User(
      id: 1, name: 'Thanh', image: '', correctTime: 0, wrongTime: 0, score: 8);
  List<Type> typeList = [];
  final FirebaseAnalytics analytics = FirebaseAnalytics();
  final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  String deviceId;
  int startPositionId;
  Offset startPosition;
  int endPositionId;
  Offset endPosition;
  bool isFromShowResult = false;
  MusicController musicController = MusicController();

  void playAudioBackground(String url) {
    musicController.playAudioBackground(url);
  }

  void stopBackgroundMusic() {
    musicController.stopBackgroundMusic();
  }

  void playGameItemSound(String url) {
    musicController.playItemSoundPlayer(url);
  }

  void stopGameItemSound() {
    musicController.stopGameItemSound();
  }

  void playTutorial() {
    musicController.playTutorialPlayer(getTutorialUrl());
  }

  void stopTutorial() {
    musicController.stopTutorial();
  }

  String getTutorialUrl() {
    switch (currentGameId) {
      case GAME_COLORING_ID:
      case GAME_COLORING_2_ID:
        return GAME_COLORING_TUTORIAL_MUSIC;
      case GAME_JIGSAW_ID:
        return GAME_JIGSAW_TUTORIAL_MUSIC;
      case GAME_CALCULATE_ID:
        return GAME_CALCULATE_TUTORIAL_MUSIC;
      case GAME_CLASSIFY_MODEL:
        return GAME_CLASSIFY_MODEL_TUTORIAL_MUSIC;
      case GAME_CHOOSE_PAIR_ID:
        return GAME_CHOOSE_PAIR_TUTORIAL_MUSIC;
      case GAME_MEMORY_NUMBER:
        return GAME_MEMORY_NUMBER_TUTORIAL_MUSIC;
      case GAME_DRAW_ALPHABET_ID:
        return GAME_DRAG_TARGET_TUTORIAL_MUSIC;
      case GAME_SCRATCHER_ID:
        return GAME_SCRATCHER_TUTORIAL_MUSIC;
      case GAME_DRAG_TARGET_ID:
        return GAME_DRAG_TARGET_TUTORIAL_MUSIC;
      default:
        return GAME_DRAG_TARGET_TUTORIAL_MUSIC;
    }
  }

  bool checkIsAndroidPlatform() {
    return Platform.isAndroid;
  }

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
    logBasicEvent('completed_step_${currentStep}_game_${currentGameId}',
        currentGameId, currentStep, 'completed_game');
    print('nextStep');
    if (currentStep < currentGame.gameData.length - 1) {
      currentStep++;
      await Future.delayed(Duration(milliseconds: 300));
      notifyListeners();
    } else {
      print('nextGame');
      print(currentGameId);
      // if(currentGameId==6){
      //   nextGame();
      // }else{
      // SchedulerBinding.instance.addPostFrameCallback((_) {
        showResultDialog(currentContext);
      // });

      // }
      // nextGame();
    }
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
      if (totalScore > randomValue) {
        // print(type.id);
        return type.typeId;
      }
    }
  }

  void getNextGameId() {
    int randomType = randomWithPiority(typeList);
    print('Random type:');
    print(randomType);
    List<int> gameIndex = [];
    for (int idx = 0; idx < gameData.length; idx++) {
      if (gameData[idx].gameType == randomType) {
        gameIndex.add(idx);
      }
    }
    print(gameIndex);
    Random random = Random();
    int randomIdx = gameIndex[random.nextInt(gameIndex.length)];
    print(randomIdx);
    currentGameId = randomIdx;
  }

  void nextGame() async {
    addUserScore();
    changeTypeScore();
    getNextGameId();
    currentStep = 0;
    getCurrentGame();
    await Future.delayed(Duration(milliseconds: 300));
    notifyListeners();
  }

  void getCurrentGame() {
    currentGame = gameData[currentGameId];
  }

  Future<void> getTypeList() async {
    print(typeList);
    typeList = await GamesDatabase.instance.readAllTypes();
  }

  void changeTypeScore() async {
    int currentType = currentGame.gameType;
    double currentTypeScore;
    typeList.map((type) async {
      if (type.typeId == currentType) {
        currentTypeScore = type.score;
      }
    }).toList();
    typeList.map((type) async {
      if (type.typeId == currentType) {
        type.score = 0;
      } else {
        type.score += currentTypeScore / (typeList.length - 1);
      }
      await GamesDatabase.instance.updateType(type);
    }).toList();
  }

  void skipGame() async {
    logBasicEvent('skip_game_${currentGameId}_from_step_${currentStep}',
        currentGameId, currentStep, 'skip_game');
    // randomWithPiority(typeList);
    changeTypeScore();
    getNextGameId();
    minusUserScore();
    currentStep = 0;
    getCurrentGame();
    await Future.delayed(Duration(milliseconds: 300));
    notifyListeners();
  }

  void logDragEvent(
    bool isCorrect,
  ) async {
    String actionName;
    if (isCorrect) {
      actionName =
          'drag_correct_item_${startPositionId}_step_${currentStep}_game_${currentGameId}';
    } else {
      actionName =
          'drag_incorrect_item_${startPositionId}_step_${currentStep}_game_${currentGameId}';
    }

    await analytics.logEvent(name: actionName, parameters: {
      'device_id': deviceId,
      'game_id': currentGameId,
      'step_id': currentStep,
      'action_type': 'Drag',
      'time': DateTime.now().millisecondsSinceEpoch,
      'start_position_id': startPositionId,
      'start_position_coordinate_dx': startPosition.dx,
      'start_position_coordinate_dy': startPosition.dy,
      'end_position_coordinate_id': endPositionId,
      'end_position_coordinate_dx': endPosition.dx,
      'end_position_coordinate_dy': endPosition.dy,
    });
    startPosition = null;
    endPosition = null;
  }

  void logTapEvent(
    int itemId,
    Offset positionOffset,
  ) {
    String itemIdName =
        itemId >= 0 ? itemId.toString() : 'minus_${(itemId * -1).toString()}';
    String actionName =
        'tap_item_${itemIdName}_step_${currentStep}_game_${currentGameId}';
    analytics.logEvent(name: actionName, parameters: {
      'device_id': deviceId,
      'game_id': currentGameId,
      'step_id': currentStep,
      'action_type': 'Tap',
      'time': DateTime.now().millisecondsSinceEpoch,
      'item_id': itemId,
      'position_coordinate_dx': positionOffset.dx,
      'position_coordinate_dy': positionOffset.dy,
    });
  }

  void logBasicEvent(
      String actionName, int gameId, int stepId, String actionType) {
    analytics.logEvent(name: actionName, parameters: {
      'device_id': deviceId,
      'game_id': gameId,
      'step_id': stepId,
      'action_type': actionType,
      'time': DateTime.now().millisecondsSinceEpoch,
    });
  }

  void getDeviceId() {
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    Map<String, dynamic> deviceData = <String, dynamic>{};
    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidDeviceInfo =
            await deviceInfoPlugin.androidInfo;
        deviceId = androidDeviceInfo.id;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosDeviceInfo = await deviceInfoPlugin.iosInfo;
        deviceId = iosDeviceInfo.identifierForVendor;
      }
    } on PlatformException {
      deviceData = <String, dynamic>{
        'Error:': 'Failed to get platform version.'
      };
    }
  }
}
