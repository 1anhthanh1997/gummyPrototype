import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:web_test/config/id_config.dart';
import 'package:web_test/db/games_database.dart';
import 'package:web_test/model/game_model.dart';
import 'package:web_test/model/parent_game_model.dart';
import 'package:web_test/model/type_model.dart';
import 'package:web_test/model/user_model.dart';
import 'package:web_test/prototype/game_screen/game_calculate_4/calculate_game.dart';
import 'package:web_test/prototype/game_screen/game_choose_pair_6/choose_pair_game.dart';
import 'package:web_test/prototype/game_screen/game_classify_5/classify_items.dart';
import 'package:web_test/prototype/game_screen/game_coloring_image_1/draw_image_game.dart';
import 'package:web_test/prototype/game_screen/game_draw_alphabet_3/draw_alphabet.dart';
import 'package:web_test/prototype/game_screen/game_draw_alphabet_3/game_drag_target.dart';
import 'package:web_test/prototype/game_screen/game_draw_alphabet_3/scratcher_game.dart';
import 'package:web_test/prototype/game_screen/game_jigsaw_2/jigsaw_game.dart';
import 'package:web_test/prototype/game_screen/game_memory_number_7/game_memory_number.dart';
import 'package:web_test/provider/screen_model.dart';
import 'package:http/http.dart' as http;

class MainGameRoute extends StatefulWidget {
  _MainGameRouteState createState() => _MainGameRouteState();
}

class _MainGameRouteState extends State<MainGameRoute> {
  ScreenModel screenModel;

  @override
  void initState() {
    // TODO: implement initState
    screenModel = Provider.of<ScreenModel>(context, listen: false);
    screenModel.setContext(context);
    super.initState();
  }
  Widget displayGame(int gameId) {
    switch (gameId) {
      case GAME_COLORING_ID:
      case GAME_COLORING_2_ID:
        return DrawImageGame(
            key: Key(DateTime.now().millisecondsSinceEpoch.toString()));
      case GAME_JIGSAW_ID:
        return JigsawGame();
      case GAME_DRAW_ALPHABET_ID:
        return DrawAlphabet();
      case GAME_SCRATCHER_ID:
        return ScratcherGame();
      case GAME_DRAG_TARGET_ID:
        return GameDragTarget();
      case GAME_CALCULATE_ID:
        return CalculateGame();
      case GAME_CHOOSE_PAIR_ID:
        return ChoosePairGame();
      case GAME_CLASSIFY_MODEL:
        return ClassifyItem();
      case GAME_MEMORY_NUMBER:
        return GameMemoryNumber();
    }
  }

  @override
  Widget build(BuildContext context) {
    return screenModel.currentGameId == -1
        ? Scaffold(
            body: Container(),
          )
        : Consumer<ScreenModel>(
            builder: (context, ScreenModel value, child) {
              return displayGame(screenModel
                  .currentGame.gameData[screenModel.currentStep].gameType);
            },
          );
  }
}
