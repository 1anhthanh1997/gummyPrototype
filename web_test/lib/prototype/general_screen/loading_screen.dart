import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_test/config/id_config.dart';
import 'package:web_test/db/games_database.dart';
import 'package:web_test/model/game_model.dart';
import 'package:web_test/model/parent_game_model.dart';
import 'package:web_test/model/type_model.dart';
import 'package:web_test/model/user_model.dart';
import 'package:web_test/prototype/general_screen/home_screen.dart';
import 'package:web_test/provider/screen_model.dart';
import 'package:web_test/widgets/loading_translate.dart';

class LoadingScreen extends StatefulWidget {
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  double screenWidth;
  double screenHeight;
  double ratio;
  ScreenModel screenModel;
  int currentLoadingIndex = 0;
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
  Timer timer;
  int periodicTime = 200;
  DocumentReference gummyData=FirebaseFirestore.instance.collection('gummy').doc('game-data');

  Future<void> loadGameData() async {
    // final response = await http.get(Uri.parse(
    //     'https://dev-dot-micro-enigma-235001.appspot.com/dataapi?type=gummy-get-data&lastUpdate=-1'));
    // var allGameData = json.decode(response.body);
    var jsonData = await rootBundle.loadString('assets/game_data.json');
    var allGameData = json.decode(jsonData);
    // DocumentSnapshot doc=await gummyData.get();
    // // var allGameData = json.decode(doc.data());
    // Map<String, dynamic> allGameData=doc.data();
    // print('Doc data');
    // print(allGameData['assetsUrl']);

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
      if (currentPlayGame > 0) {
        screenModel.currentGameId = currentPlayGame;
        screenModel.currentStep = currentStep;
      } else {
        screenModel.getNextGameId();
      }
      screenModel.getCurrentGame();
    });
    // });

    // setState(() {});
  }

  Future<void> getCurrentPlayGameSF() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return bool
    int intValue = prefs.getInt('currentPlayGame') ?? -1;
    int stepValue = prefs.getInt('currentStep') ?? 0;
    setState(() {
      currentPlayGame = intValue;
      currentStep = stepValue;
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
      // setState(() {
      //   isComplete = true;
      // });
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
          ModalRoute.withName("/Home"));
      return;
    }
    _requestDownload();
    Timer(Duration(milliseconds: 12000), () {
      extractFile();
    });
  }

  void extractFile() async {
    final zipFile = File('${_localPath}/assets.zip');
    bool fileExist = await zipFile.exists();
    // print(fileExist);
    if (fileExist) {
      final destinationDir = Directory(_localPath);
      try {
        ZipFile.extractToDirectory(
                zipFile: zipFile, destinationDir: destinationDir)
            .whenComplete(() {
          setState(() {
            isComplete = true;
          });
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
              ModalRoute.withName("/Home"));
        });
      } catch (e) {
        print(e);
      }
    } else {
      Timer(Duration(milliseconds: 2000), () {
        extractFile();
      });
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

  void addAnimation() {
    timer = Timer.periodic(Duration(milliseconds: periodicTime), (timer) async {
      if (currentLoadingIndex == 2) {
        Timer(Duration(milliseconds: 1000), () {
          setState(() {
            currentLoadingIndex = 0;
          });
          addAnimation();
        });
        if (timer != null) {
          timer.cancel();
        }
        print('Delay');
      } else {
        print('normal');
        setState(() {
          currentLoadingIndex = (currentLoadingIndex + 1) % 3;
        });
      }

      print(currentLoadingIndex);
    });
  }

  @override
  void initState() {
    screenModel = Provider.of<ScreenModel>(context, listen: false);
    screenModel.setContext(context);
    loadGameData().whenComplete(() async {
      await downloadAssets();
    });
    screenModel.getDeviceId();
    screenModel.playAudioBackground(HOME_MUSIC);
    getCurrentPlayGameSF();
    addAnimation();

    super.initState();
  }

  @override
  void dispose() {
    if (timer != null) {
      timer.cancel();
    }
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    screenWidth = screenModel.getScreenWidth();
    screenHeight = screenModel.getScreenHeight();
    ratio = screenModel.getRatio();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: HexColor('#2BA6F4'),
        child: Stack(
          children: [
            Positioned(
              top: screenHeight / 2 - 49 * ratio,
              left: 270 * ratio,
              child: LoadingTranslate(
                  isScale: currentLoadingIndex == 0,
                  beginValue: 12.5,
                  endValue: -12.5 * ratio,
                  curve: Curves.easeOutQuad,
                  time: 250,
                  child: Container(
                    height: 72 * ratio,
                    width: 72 * ratio,
                    child: Image.asset(
                        'assets/images/common/loading/bear_loading.png'),
                  )),
            ),
            Positioned(
              top: screenHeight / 2 - 49 * ratio,
              left: 360 * ratio,
              child: LoadingTranslate(
                  isScale: currentLoadingIndex == 1,
                  beginValue: 12.5,
                  endValue: -12.5 * ratio,
                  curve: Curves.easeOutQuad,
                  time: 250,
                  child: Container(
                    height: 72 * ratio,
                    width: 72 * ratio,
                    child: Image.asset(
                        'assets/images/common/loading/dog_loading.png'),
                  )),
            ),
            Positioned(
              top: screenHeight / 2 - 49 * ratio,
              left: 450 * ratio,
              child: LoadingTranslate(
                  isScale: currentLoadingIndex == 2,
                  beginValue: 12.5,
                  endValue: -12.5 * ratio,
                  curve: Curves.easeOutQuad,
                  time: 250,
                  child: Container(
                    height: 72 * ratio,
                    width: 72 * ratio,
                    child: Image.asset(
                        'assets/images/common/loading/bird_loading.png'),
                  )),
            )
          ],
        ),
      ),
    );
  }
}
