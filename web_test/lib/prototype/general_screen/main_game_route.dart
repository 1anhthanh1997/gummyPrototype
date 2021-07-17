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
  List gameDataJson;
  var data;
  var currentGameData;
  bool debug = true;
  String _localPath;
  bool _permissionReady;
  TargetPlatform platform;
  String assetsUrl;
  bool isComplete = false;

  Future<void> loadGameData() async {
    final response = await http.get(Uri.parse(
        'https://dev-dot-micro-enigma-235001.appspot.com/dataapi?type=gummy-get-data&lastUpdate=-1'));
    var allGameData = json.decode(response.body);
    // var jsonData = await rootBundle.loadString('assets/game_data.json');
    // var allGameData = json.decode(jsonData);
    assetsUrl = allGameData['assetsUrl'];
    gameDataJson=allGameData['data'];
    screenModel.gameData =
        gameDataJson.map((parentGame) => new ParentGameModel.fromJson(parentGame)).toList();
    List<int> typeIdList = [];
    screenModel.getTypeList();
    await addUser();
    screenModel.gameData.map((game) async {
      if (!typeIdList.contains(game.gameType)) {
        typeIdList.add(game.gameType);
      }
      Game currentGame = Game(
          gameId: game.id,
          type: game.gameType,
          level: game.level,
          age: game.age,
          lastUpdate: 0,
          baseScore: game.levelScore);

      await GamesDatabase.instance.createGame(currentGame);
    }).toList();
    typeIdList.map((id) async {
      Type currentType = Type(
        typeId: id,
        skipTime: 0,
        score: 100 / typeIdList.length,
      );
      await GamesDatabase.instance.createType(currentType);
    }).toList();
    screenModel.getCurrentGame();
    // setState(() {});
  }

  Future<void> addUser() async {
    User currentUser = User(
        name: 'Thanh',
        image: '',
        score: MIN_BASE_SCORE,
        correctTime: 0,
        wrongTime: 0);
    await GamesDatabase.instance.createUser(currentUser).whenComplete(() async {
      await GamesDatabase.instance.readAllUser();
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    screenModel = Provider.of<ScreenModel>(context, listen: false);
    screenModel.setContext(context);
    screenModel.getDeviceId();
    loadGameData().whenComplete(() => {downloadAssets()});
    GamesDatabase.instance.readAllGames();
    super.initState();
  }

  Future<void> downloadAssets() async {
    _localPath =
        (await _findLocalPath()) + Platform.pathSeparator + 'Download/assets';
    print(_localPath);
    final savedDir = Directory(_localPath);
    bool hasExisted = await savedDir.exists();
    FlutterDownloader.registerCallback(downloadCallback);
    await _prepare();
    if (hasExisted) {
      setState(() {
        isComplete = true;
      });
      return;
    }
    _requestDownload();
    // print(_localPath);
    Timer(Duration(milliseconds: 3000), () {
      extractFile();
    });
  }

  void extractFile() async {
    final zipFile = File('${_localPath}/assets.zip');
    final destinationDir = Directory(_localPath);
    try {
      ZipFile.extractToDirectory(
              zipFile: zipFile, destinationDir: destinationDir)
          .whenComplete(() {
        setState(() {
          isComplete = true;
        });
      });
    } catch (e) {
      print(e);
    }
  }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    print(
        'Background Isolate Callback: task ($id) is in status ($status) and process ($progress)');

    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send.send([id, status, progress]);
  }

  void _requestDownload() async {
    final taskId = await FlutterDownloader.enqueue(
        url: assetsUrl,
        headers: {"auth": "test_for_sql_encoding"},
        savedDir: _localPath,
        showNotification: true,
        openFileFromNotification: true);
  }

  Future<bool> _checkPermission() async {
    if (platform == TargetPlatform.android) {
      final status = await Permission.storage.status;
      if (status != PermissionStatus.granted) {
        final result = await Permission.storage.request();
        if (result == PermissionStatus.granted) {
          return true;
        }
      } else {
        return true;
      }
    } else {
      return true;
    }
    return false;
  }

  Future<Null> _prepare() async {
    final tasks = await FlutterDownloader.loadTasks();

    _permissionReady = await _checkPermission();

    if (_permissionReady) {
      await _prepareSaveDir();
    }
  }

  Future<void> _prepareSaveDir() async {
    _localPath = (await _findLocalPath()) + Platform.pathSeparator + 'Download';
    final savedDir = Directory(_localPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }
    if (hasExisted) {}
    screenModel.localPath = _localPath;
  }

  Future<String> _findLocalPath() async {
    final directory = platform == TargetPlatform.android
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    return directory?.path;
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
    return !isComplete
        ? Scaffold(
            body: Container(),
          )
        : Consumer<ScreenModel>(
            builder: (context, ScreenModel value, child) {
              print(screenModel.currentGame);
              return displayGame(screenModel.currentGame.gameData
                  [screenModel.currentStep].gameType);
            },
          );
  }
}
