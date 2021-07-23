import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_test/model/parent_game_model.dart';
import 'package:web_test/prototype/general_screen/main_game_route.dart';
import 'package:web_test/prototype/general_screen/winning_screen.dart';
import 'package:web_test/provider/screen_model.dart';
import 'package:web_test/widgets/animation_draggable_tap.dart';
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

class HomeScreen extends StatefulWidget {
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
  int currentPlayGame;
  int currentStep;

  @override
  void initState() {
    // TODO: implement initState
    screenModel = Provider.of<ScreenModel>(context, listen: false);
    screenModel.setContext(context);
    screenModel.getDeviceId();
    getCurrentPlayGameSF();
    loadGameData().whenComplete(()async{
      await downloadAssets();
    });
    super.initState();
  }

  Future<void> loadGameData() async {
    // final response = await http.get(Uri.parse(
    //     'https://dev-dot-micro-enigma-235001.appspot.com/dataapi?type=gummy-get-data&lastUpdate=-1'));
    // var allGameData = json.decode(response.body);
    var jsonData = await rootBundle.loadString('assets/game_data.json');
    var allGameData = json.decode(jsonData);

    assetsUrl = allGameData['assetsUrl'];
    gameDataJson = allGameData['data'];
    screenModel.gameData = gameDataJson
        .map((parentGame) => new ParentGameModel.fromJson(parentGame))
        .toList();
    await addUser();
    await addDataToDB();
    // Timer(Duration(milliseconds: 500), ()  {
    await Future.delayed(Duration(milliseconds: 500));
    await screenModel.getTypeList().whenComplete(() {
      if(currentPlayGame>0){
        screenModel.currentGameId=currentPlayGame;
        screenModel.currentStep=currentStep;
      }else{
        screenModel.getNextGameId();
      }
      screenModel.getCurrentGame();
    });
    // });

    // setState(() {});
  }

  Future<void>getCurrentPlayGameSF() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return bool
    int intValue = prefs.getInt('currentPlayGame') ?? -1;
    int stepValue=prefs.getInt('currentStep')??0;
    setState(() {
      currentPlayGame = intValue;
      currentStep=stepValue;
    });
  }

  Future<void> addDataToDB() async {
    List<int> typeIdList = [];
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screenModel.currentGameId == -1
          ? Container()
          : Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image:
                          AssetImage('assets/images/home/home_background.png'),
                      fit: BoxFit.fill)),
              child: AnimationDraggableTap(
                onTab: () {
                  showResultDialog(context);
                  // Navigator.pushAndRemoveUntil(
                  //     context,
                  //     MaterialPageRoute(builder: (context) => MainGameRoute()),
                  //     ModalRoute.withName("/Home"));
                },
                // child: Container(
                //   height: 140,
                //   width: 140,
                //   child: Image.asset('assets/images/home/play_button.png',
                //       fit: BoxFit.contain),
                // ),
                child: Container(
                  height: 140,
                  width: 140,
                  child: Image.asset('assets/images/home/play_button.png',
                      fit: BoxFit.contain),
                ),
              )),
    );
  }
}
