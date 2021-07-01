// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:web_test/model/game_jigsaw_draggable_model.dart';
// import 'package:web_test/model/game_jigsaw_target_model.dart';
// import 'package:web_test/widgets/animation_draggable_tap.dart';
// import 'package:web_test/widgets/animation_hit_fail.dart';
// import 'package:web_test/widgets/animation_rotate.dart';
// import 'package:web_test/widgets/appear_animation.dart';
//
// class JigsawGame extends StatefulWidget {
//   _JigsawGameState createState() => _JigsawGameState();
// }
//
// class _JigsawGameState extends State<JigsawGame> {
//   List<GameJigsawDraggableModel> draggableData = [];
//   List<GameJigsawTargetModel> targetData = [];
//   List firstData = [];
//   List secondData = [];
//   double bonusHeight = 0;
//   double ratio=1;
//   bool isHitFail=false;
//   bool isWrongTarget=false;
//
//   Future<void> loadAlphabetData() async {
//     var jsonData = await rootBundle.loadString('assets/jigsaw_game_data.json');
//     var allGameData = json.decode(jsonData);
//     firstData = allGameData['gameData'][0]['items']['draggable'];
//     secondData = allGameData['gameData'][0]['items']['target'];
//     double objectHeight = allGameData['gameData'][0]['height'];
//     bonusHeight = (375 - objectHeight) / 2;
//     draggableData = firstData
//         .map((draggableInfo) =>
//             new GameJigsawDraggableModel.fromJson(draggableInfo))
//         .toList();
//     print(draggableData);
//     targetData = secondData
//         .map((targetInfo) => new GameJigsawTargetModel.fromJson(targetInfo))
//         .toList();
//     print(targetData);
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     this.loadAlphabetData().whenComplete(() => {setState(() {})});
//   }
//
//   Widget puzzleWidget(double width, double height, GameJigsawDraggableModel item) {
//     return item == null
//         ? Container()
//         : Container(
//       width: width * ratio,
//       height: height * ratio,
//       child: Image.asset(item.images[0], fit: BoxFit.contain),
//     );
//   }
//
//   Widget genFeedBack(int id) {
//     return Container(
//       height: draggableData[id].height,
//       width: draggableData[id].width,
//       child: Image.asset(draggableData[id].images[0], fit: BoxFit.contain),
//     );
//   }
//
//
//   Widget displayDraggable() {
//     List<int> indexGenerate =
//     Iterable<int>.generate(draggableData.length).toList();
//     return Stack(
//       children: indexGenerate.map((index){
//         GameJigsawDraggableModel sourceModel = draggableData[index];
//         double topAlign = sourceModel.position.dy;
//         double leftAlign = sourceModel.position.dx;
//         return AnimatedPositioned(
//             key: Key(index.toString()),
//             top: topAlign * ratio + bonusHeight,
//             left: leftAlign * ratio,
//             duration: Duration(milliseconds: sourceModel.duration),
//             child: AppearAnimation(
//                 onTab: (){
//
//                 },
//                 isMultiTab: true,
//                 child: AnimationDraggableTap(
//                     onTab: (){
//
//                     },
//                     buttonName: 'draggable_${sourceModel.groupId}',
//                     isMultiTab: true,
//                     child: AnimationRotate(
//                       onTab: () {
//                         setState(() {
//                           rotateTime[sourceModel.groupId] = isFirstRotateTime[sourceModel.groupId]
//                               ? (rotateTime[sourceModel.groupId] + 2) % 4
//                               : (rotateTime[sourceModel.groupId] + 1) % 4;
//                           isFirstRotateTime[sourceModel.groupId] = false;
//                         });
//                       },
//                       child: Draggable(
//                         data: sourceModel.groupId,
//                         child: AnimationHitFail(
//                             isDisplayAnimation: isHitFail,
//                             child: puzzleWidget(
//                               sourceModel.width,
//                               sourceModel.height,
//                               sourceModel
//                             )),
//                         feedback: genFeedBack(sourceModel.groupId),
//                         childWhenDragging: puzzleWidget(
//                             sourceModel.width, sourceModel.height, sourceModel),
//                         onDragEnd: (details) {
//                           // santaJigsawLogic.totalDrag++;
//                           if (details.wasAccepted) {
//                           } else {}
//                         },
//                         onDragStarted: () {
//                           sourceModel.duration = 0;
//                         },
//                         maxSimultaneousDrags: 1,
//                         onDraggableCanceled: (velocity, offset) {
//                           if (isWrongTarget) {
//                             Offset offsetSource = sourceModel.position;
//                             sourceModel.position = Offset((offset.dx) / ratio,
//                                 ((offset.dy - bonusHeight) / ratio));
//                             int status = sourceModel.status;
//                             if (status == STATUS_NOT_MATCH) {
//                               sourceModel.status = STATUS_INIT;
//                             }
//                             setState(() {
//                               isHitFail = true;
//                             });
//                             Timer(Duration(milliseconds: 200), () {
//                               setState(() {
//                                 isHitFail = false;
//                                 isWrongTarget = false;
//                               });
//                             });
//                             Timer(Duration(milliseconds: 800), () {
//                               double denta = screenModel.getBiggerSpace(
//                                   offsetSource, offset);
//                               if (denta < 200 && status == STATUS_NOT_MATCH) {
//                                 denta = 200;
//                               }
//                               sourceModel.duration = editValue(denta.toInt());
//                               sourceModel.position = offsetSource;
//                               setState(() {});
//                             });
//                           } else {
//                             Offset offsetSource = sourceModel.position;
//                             sourceModel.position = Offset((offset.dx) / ratio,
//                                 ((offset.dy - bonusHeight) / ratio));
//                             int status = sourceModel.status;
//                             if (status == STATUS_NOT_MATCH) {
//                               sourceModel.status = STATUS_INIT;
//                             }
//                             setState(() {});
//                             Timer(Duration(milliseconds: 50), () {
//                               double denta = screenModel.getBiggerSpace(
//                                   offsetSource, offset);
//                               if (denta < 200 && status == STATUS_NOT_MATCH) {
//                                 denta = 200;
//                               }
//                               sourceModel.duration = editValue(denta.toInt());
//                               sourceModel.position = offsetSource;
//                               setState(() {});
//                             });
//                           }
//                         },
//                       ),
//                     ))));
//       }).toList(),
//     );
//   }
//
//   List<Widget> displayScreen() {
//     List<Widget> widgets = [];
//     widgets.add(displayDraggable());
//     return widgets;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//           child: Stack(
//         children: displayScreen(),
//       )),
//     );
//   }
// }
