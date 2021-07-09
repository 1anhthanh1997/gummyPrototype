import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:web_test/config/id_config.dart';
import 'package:web_test/prototype/game_screen/game_calculate_4/calculate_game.dart';
import 'package:web_test/prototype/game_screen/game_coloring_image_1/draw_image_game.dart';
import 'package:web_test/provider/screen_model.dart';

class MainGameRoute extends StatefulWidget{
  _MainGameRouteState createState()=>_MainGameRouteState();
}
class _MainGameRouteState extends State<MainGameRoute>{
  ScreenModel screenModel;

  var allGameData;
  var currentGameData;

  Future<void> loadGameData() async {
    var jsonData = await rootBundle.loadString('assets/game_data.json');
    allGameData = json.decode(jsonData);
    allGameData.map((game){
      if(screenModel.currentGameId==game['id']){
        setState(() {
          currentGameData=game;
        });
      }
    }).toList();
    print(currentGameData);
    setState(() {

    });
  }


  @override
  void initState() {
    // TODO: implement initState
    screenModel = Provider.of<ScreenModel>(context, listen: false);
    screenModel.setContext(context);
    loadGameData();
    super.initState();
  }

  Widget displayGame(int gameId){
    switch (gameId){
      case GAME_COLORING_ID : return DrawImageGame();
      case GAME_CALCULATE_ID : return CalculateGame();
    }
  }

  @override
  Widget build(BuildContext context) {
   return currentGameData==null?Scaffold(
     body: Container(),
   ):displayGame(currentGameData['id']);
  }
}