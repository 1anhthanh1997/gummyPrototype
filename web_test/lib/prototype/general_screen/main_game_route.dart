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
import 'package:web_test/prototype/game_screen/game_calculate_4/calculate_game.dart';
import 'package:web_test/prototype/game_screen/game_coloring_image_1/draw_image_game.dart';
import 'package:web_test/prototype/game_screen/game_draw_alphabet_3/draw_alphabet.dart';
import 'package:web_test/prototype/game_screen/game_draw_alphabet_3/game_drag_target.dart';
import 'package:web_test/prototype/game_screen/game_draw_alphabet_3/scratcher_game.dart';
import 'package:web_test/provider/screen_model.dart';

class MainGameRoute extends StatefulWidget {
  _MainGameRouteState createState() => _MainGameRouteState();
}

class _MainGameRouteState extends State<MainGameRoute> {
  ScreenModel screenModel;

  var data;
  var currentGameData;
  bool debug = true;
  String _localPath;
  bool _permissionReady;
  TargetPlatform platform;
  String assetsUrl;
  bool isComplete = false;

  Future<void> loadGameData() async {
    var jsonData = await rootBundle.loadString('assets/game_data.json');
    var allGameData = json.decode(jsonData);
    assetsUrl = allGameData['assetsUrl'];
    data = allGameData['data'];
    data.map((game) {
      if (screenModel.currentGameId == game['id']) {
        screenModel.currentGame = game;
        setState(() {
          currentGameData = game;
        });
      }
    }).toList();
    print(currentGameData);
    setState(() {});
    downloadAssets();
  }

  @override
  void initState() {
    // TODO: implement initState
    screenModel = Provider.of<ScreenModel>(context, listen: false);
    screenModel.setContext(context);
    loadGameData();
    super.initState();
  }

  Future<void> downloadAssets() async {
    FlutterDownloader.registerCallback(downloadCallback);
    await _prepare();
    _requestDownload();
    Timer(Duration(milliseconds: 3000), () {
      extractFile();
      print('Completed');
      setState(() {

      });
    });
  }

  void extractFile() {
    final zipFile = File('${_localPath}/assets.zip');
    final destinationDir = Directory(_localPath);
    try {
      ZipFile.extractToDirectory(
          zipFile: zipFile, destinationDir: destinationDir);
      setState(() {
        isComplete = true;
        print('completed');
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
    if(hasExisted){
      setState(() {
        isComplete=true;
      });
    }
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
        return DrawImageGame();
      case GAME_DRAW_ALPHABET_ID:
        return DrawAlphabet();
      case GAME_SCRATCHER_ID:
        return ScratcherGame();
      case GAME_DRAG_TARGET_ID:
        return GameDragTarget();
      case GAME_CALCULATE_ID:
        return CalculateGame();
    }
  }

  @override
  Widget build(BuildContext context) {
    return currentGameData == null
        ? Scaffold(
            body: Container(),
          )
        : Consumer<ScreenModel>(
            builder: (context, ScreenModel value, child) {
              return
                // isComplete
                //   ?
                displayGame(currentGameData['gameData']
                      [screenModel.currentStep]['gameType']);
                  // : Scaffold(
                  //     body: Container(),
                  //   );
            },
          );
  }
}
