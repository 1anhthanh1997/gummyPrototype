import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:web_test/prototype/game_screen/game_calculate_4/calculate_game.dart';
import 'package:web_test/prototype/game_screen/game_choose_pair_6/choose_pair_game.dart';
import 'package:web_test/prototype/game_screen/game_classify_5/classify_items.dart';
import 'package:web_test/prototype/game_screen/game_draw_alphabet_3/draw_alphabet.dart';
import 'package:web_test/prototype/game_screen/game_coloring_image_1/draw_image_game.dart';
import 'package:web_test/prototype/game_screen/game_memory_number_7/game_memory_number.dart';
import 'package:web_test/prototype/game_screen/game_jigsaw_2/jigsaw_game.dart';
import 'package:web_test/provider/screen_model.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Offset currentOffset = Offset(0, 315);
  int duration = 0;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => ScreenModel())],
      child: ChoosePairGame(),
    );
  }
}
