// import 'dart:async';
//
// import 'package:animator/animator.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:gummy/animals/AnimalTargetWidget.dart';
// import 'package:gummy/common/animated_matched_target.dart';
// import 'package:gummy/common/animation_button.dart';
// import 'package:gummy/common/animation_draggable_tap.dart';
// import 'package:gummy/common/animation_hit_fail.dart';
// import 'package:gummy/common/animation_rotate.dart';
// import 'package:gummy/common/appear_animation.dart';
// import 'package:gummy/common/mascot_rive_widget.dart';
// import 'package:gummy/common/screen_gesture_detector.dart';
// import 'package:gummy/components/header/header_game.dart';
// import 'package:gummy/database/database_id.dart';
// import 'package:gummy/model/DragGameModel.dart';
// import 'package:gummy/model/ItemModel.dart';
// import 'package:gummy/model/config.dart';
// import 'package:gummy/providers/screen_model.dart';
// import 'package:gummy/screen/snows_category/santa_jigsaw/santa_jigsaw_logic.dart';
// import 'package:provider/provider.dart';
// import 'package:rive/rive.dart';
//
// class SantaJigsawScreen extends StatefulWidget {
//   SantaJigsawScreen({Key key}) : super(key: key);
//
//   @override
//   _SantaJigsawScreenState createState() => _SantaJigsawScreenState();
// }
//
// class _SantaJigsawScreenState extends State<SantaJigsawScreen> {
//   double screenWidth;
//   double screenHeight;
//   double ratio;
//   ScreenModel screenModel;
//   MascotRiveWidget mascotRiveWidget;
//   SantaJigsawLogic santaJigsawLogic;
//   Map<int, DragGameModel> animals;
//   List<int> keyAnimalDragableTmp;
//   List<int> keyAnimalDragable;
//   List<int> keyAnimalDragTarget;
//   bool isMatch = false;
//   int index = 0;
//   bool isHitFail = false;
//   bool isDisplayTutorial = false;
//   Timer _timer;
//   AnimationRotate firstAnimationRotate;
//   AnimationRotate secondAnimationRotate;
//   int firstRotateCorrectTime = 0;
//   int secondRotateCorrectTime = 1;
//   int firstRotateTime = 0;
//   int secondRotateTime = 0;
//   bool isFirstTimeFirstImage = true;
//   bool isFirstTimeSecondImage = true;
//   RiveAnimationController showResultRive;
//   Artboard showResultArtboard;
//   bool isShowRive = false;
//   List<Offset> draggableDirection;
//   bool isFirstTime = true;
//   double bonusHeight;
//   int count = 0;
//   List<int> rotateTime = [0, 0, 0, 0];
//   List<bool> isFirstRotateTime = [true, true, true, true];
//   bool isWrongTarget = false;
//   Timer remindTimer;
//   int tutorialCount = 0;
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     screenModel = Provider.of<ScreenModel>(context, listen: false);
//     screenModel.setContext(context);
//     mascotRiveWidget = new MascotRiveWidget();
//     screenModel.logBasicEvent(
//         'enter_screen_${screenModel.currentGameScreen.id}',
//         screenModel.currentGameScreen.id,
//         'enter_screen');
//     santaJigsawLogic = new SantaJigsawLogic(context);
//     keyAnimalDragable = santaJigsawLogic.keyAnimalDragable;
//     keyAnimalDragableTmp = santaJigsawLogic.keyAnimalDragable;
//     keyAnimalDragTarget = santaJigsawLogic.keyAnimalDragTarget;
//     startShowResultRive();
//     // remindTimer=Timer.periodic(Duration(seconds: 20),(timer){
//     //   screenModel.playRemindMusic();
//     // });
//     _initializeTimer();
//   }
//
//   @override
//   void dispose() {
//     // TODO: implement dispose
//     if (_timer != null) {
//       _timer.cancel();
//     }
//     super.dispose();
//   }
//
//   void startShowResultRive() {
//     rootBundle.load(SHOW_RESULT_SANTA_JIGSAW_RIVE).then(
//           (data) async {
//         final file = RiveFile();
//         if (file.import(data)) {
//           final artboard = file.mainArtboard;
//           artboard
//               .addController(showResultRive = SimpleAnimation('Animation 1'));
//           setState(() => showResultArtboard = artboard);
//         }
//       },
//     );
//   }
//
//   void onPointerTap(PointerEvent details) {
//     if (!_timer.isActive) {
//       return;
//     }
//     _timer.cancel();
//     _initializeTimer();
//   }
//
//   void _initializeTimer() {
//     _timer =
//         Timer.periodic(new Duration(seconds: WAITING_TIME_TUTORIAL), (timer) {
//           setState(() {
//             tutorialCount++;
//             // isDisplayTutorial = true;
//           });
//         });
//   }
//
//   int editValue(int val) {
//     if (val >= 0)
//       return val;
//     else
//       return -1 * val;
//   }
//
//   Widget puzzleWidget(double width, double height, ItemModel item) {
//     return item == null
//         ? Container()
//         : Container(
//       width: width * ratio,
//       height: height * ratio,
//       child: Image.asset(item.urlImage, fit: BoxFit.contain),
//     );
//   }
//
//   Widget getFeedbackImage(int status, int index) {
//     if (index == 0) {
//       switch (status) {
//         case 0:
//           {
//             return Container(
//                 height: 203 * ratio,
//                 width: 188 * ratio,
//                 // color: Colors.red,
//                 child: Image.asset(
//                   SANTA_JIGSAW_IMAGE_1,
//                   fit: BoxFit.contain,
//                 ));
//           }
//           break;
//         case 1:
//           {
//             return Container(
//                 height: 188 * ratio,
//                 width: 203 * ratio,
//                 // color: Colors.red,
//                 child: Image.asset(
//                   SANTA_JIGSAW_IMAGE_1_90,
//                   fit: BoxFit.contain,
//                 ));
//           }
//           break;
//         case 2:
//           {
//             return Container(
//                 height: 203 * ratio,
//                 width: 188 * ratio,
//                 // color: Colors.red,
//                 child: Image.asset(
//                   SANTA_JIGSAW_IMAGE_1_180,
//                   fit: BoxFit.contain,
//                 ));
//           }
//           break;
//         case 3:
//           {
//             return Container(
//                 height: 188 * ratio,
//                 width: 203 * ratio,
//                 // color: Colors.red,
//                 child: Image.asset(
//                   SANTA_JIGSAW_IMAGE_1_270,
//                   fit: BoxFit.contain,
//                 ));
//           }
//           break;
//         default:
//           return Container();
//           break;
//       }
//     } else {
//       switch (status) {
//         case 0:
//           {
//             return Container(
//                 height: 196 * ratio,
//                 width: 245 * ratio,
//                 // color: Colors.red,
//                 child: Image.asset(
//                   SANTA_JIGSAW_IMAGE_2,
//                   fit: BoxFit.contain,
//                 ));
//           }
//           break;
//         case 1:
//           {
//             return Container(
//                 height: 245 * ratio,
//                 width: 196 * ratio,
//                 // color: Colors.red,
//                 child: Image.asset(
//                   SANTA_JIGSAW_IMAGE_2_90,
//                   fit: BoxFit.contain,
//                 ));
//           }
//           break;
//         case 2:
//           {
//             return Container(
//                 height: 196 * ratio,
//                 width: 245 * ratio,
//                 // color: Colors.red,
//                 child: Image.asset(
//                   SANTA_JIGSAW_IMAGE_2_180,
//                   fit: BoxFit.contain,
//                 ));
//           }
//           break;
//         case 3:
//           {
//             return Container(
//                 height: 245 * ratio,
//                 width: 196 * ratio,
//                 // color: Colors.red,
//                 child: Image.asset(
//                   SANTA_JIGSAW_IMAGE_2_270,
//                   fit: BoxFit.contain,
//                 ));
//           }
//           break;
//         default:
//           return Container();
//           break;
//       }
//     }
//   }
//
//   Widget displayBackground() {
//     return Container(
//       decoration: BoxDecoration(
//         image: DecorationImage(
//           image: AssetImage(BACKGROUND_HOME_2),
//           fit: BoxFit.fill,
//         ),
//       ),
//     );
//   }
//
//   Widget displayMascot() {
//     return Positioned(
//         top: screenHeight - 78 * ratio,
//         left: 5 * ratio,
//         child: GestureDetector(
//           onTap: () {
//             mascotRiveWidget.changeStatusInit();
//           },
//           child: Container(
//               width: 80 * ratio, height: 100 * ratio, child: mascotRiveWidget),
//         ));
//   }
//
//   Widget displayBackButton() {
//     return Container(
//       alignment: Alignment.topLeft,
//       child: HeaderGame(),
//     );
//   }
//
//   Widget displayBeginnerTarget() {
//     return Positioned(
//         top: bonusHeight,
//         left: screenWidth * 13 / 24 - 322 / 2 * ratio,
//         child: AppearAnimation(
//           child: Container(
//               height: 143 * ratio,
//               width: 322 * ratio,
//               // color: Colors.red,
//               child: Image.asset(
//                 SANTA_JIGSAW_IMAGE_0,
//                 fit: BoxFit.contain,
//               )),
//         ));
//   }
//
//   Widget displayFinishRive() {
//     return Positioned(
//         top: bonusHeight,
//         left: screenWidth * 13 / 24 - 322 / 2 * ratio,
//         child: Container(
//           // color:Colors.red,
//           height: 261 * ratio,
//           width: 322 * ratio,
//           child: Rive(
//             artboard: showResultArtboard,
//             fit: BoxFit.contain,
//           ),
//         ));
//   }
//
//   Widget displayTarget() {
//     return Stack(
//       children: keyAnimalDragTarget.map((id) {
//         ItemModel targetModel = animals[id].targetModel;
//         ItemModel sourceModel = animals[id].sourceModel;
//         List<String> data = [
//           'puzzle_1_result.png',
//           'puzzle_2_result.png',
//           'puzzle_3_result.png',
//           'puzzle_4_result.png'
//         ];
//         String path = 'assets/items/snows/santa_jigsaw/';
//         return animals[id].status == STATUS_MATCH
//             ? Positioned(
//             top: targetModel.position.dy * ratio + bonusHeight,
//             left: targetModel.position.dx * ratio,
//             child: AnimatedMatchedTarget(
//                 child: Container(
//                   height: targetModel.height * ratio,
//                   width: targetModel.width * ratio,
//                   child: Image.asset(path + data[id], fit: BoxFit.contain),
//                 )))
//             : Positioned(
//             top: targetModel.position.dy * ratio + bonusHeight,
//             left: targetModel.position.dx * ratio,
//             child: AppearAnimation(
//               delay: 2000,
//               child: DragTarget<int>(
//                 builder: (context, candidateData, rejectedData) {
//                   Widget target = targetModel.widget;
//                   if (target == null) {
//                     target = puzzleWidget(
//                         targetModel.width, targetModel.height, targetModel);
//                     // new AnimalTargetWidget(
//                     //   key: new Key(id.toString()),
//                     //   name: targetModel.urlImage,
//                     //   width: targetModel.width * ratio,
//                     //   height: targetModel.height * ratio,
//                     // );
//                     targetModel.widget = target;
//                   }
//                   return target;
//                 },
//                 onWillAccept: (data) {
//                   return data == id &&
//                       targetModel.correctRotateTime == rotateTime[id];
//                 },
//                 onLeave: (data) {
//                   setState(() {
//                     isWrongTarget = true;
//                   });
//                 },
//                 onAccept: (data) {
//                   animals[id].status = STATUS_MATCH;
//                   mascotRiveWidget.changeStatusSuccess();
//                   Timer(Duration(milliseconds: 1000), () {
//                     setState(() {
//                       count = count + 1;
//                     });
//                   });
//                   keyAnimalDragableTmp.remove(id);
//                   setState(() {});
//                   santaJigsawLogic.checkAndNextGame(_timer).then((value) {
//                     screenModel.releaseMusic();
//                     if (value != 0) {
//                       setState(() {});
//                     }
//                   });
//                 },
//               ),
//             ));
//       }).toList(),
//     );
//   }
//
//   Widget displayImageModel() {
//     return Positioned(
//         top: bonusHeight,
//         left: 119 * ratio,
//         child: Container(
//           height: 296 * ratio,
//           width: 296 * ratio,
//           child: Image.asset(
//             PUZZLE_IMAGE_MODEL_1,
//             fit: BoxFit.contain,
//           ),
//         ));
//   }
//
//   Widget genFirstFeedBack() {
//     List<String> name = [
//       'puzzle_1_90.png',
//       'puzzle_1_180.png',
//       'puzzle_1_270.png',
//       'puzzle_1_0.png'
//     ];
//     String path = 'assets/items/snows/santa_jigsaw/';
//     return Container(
//       height: 160 * ratio,
//       width: 160 * ratio,
//       child: Image.asset(path + name[rotateTime[0]], fit: BoxFit.contain),
//     );
//   }
//
//   Widget genSecondFeedBack() {
//     List<String> name = [
//       'puzzle_2_90.png',
//       'puzzle_2_180.png',
//       'puzzle_2_270.png',
//       'puzzle_2_0.png'
//     ];
//     String path = 'assets/items/snows/santa_jigsaw/';
//     return Container(
//       height: 129 * ratio,
//       width: 129 * ratio,
//       child: Image.asset(path + name[rotateTime[1]], fit: BoxFit.contain),
//     );
//   }
//
//   Widget genThirdFeedBack() {
//     List<String> name = [
//       'puzzle_3_180.png',
//       'puzzle_3_270.png',
//       'puzzle_3_0.png',
//       'puzzle_3_90.png',
//     ];
//     String path = 'assets/items/snows/santa_jigsaw/';
//     return Container(
//       height: 161 * ratio,
//       width: 161 * ratio,
//       child: Image.asset(path + name[rotateTime[2]], fit: BoxFit.contain),
//     );
//   }
//
//   Widget genFourthFeedBack() {
//     List<String> name = [
//       'puzzle_4_180.png',
//       'puzzle_4_270.png',
//       'puzzle_4_0.png',
//       'puzzle_4_90.png',
//     ];
//     String path = 'assets/items/snows/santa_jigsaw/';
//     return Container(
//       height: 101 * ratio,
//       width: 101 * ratio,
//       child: Image.asset(path + name[rotateTime[3]], fit: BoxFit.contain),
//     );
//   }
//
//   Widget genFeedBack(int id) {
//     switch (id) {
//       case 0:
//         return genFirstFeedBack();
//       case 1:
//         return genSecondFeedBack();
//       case 2:
//         return genThirdFeedBack();
//       case 3:
//         return genFourthFeedBack();
//       default:
//         return genFirstFeedBack();
//     }
//   }
//
//   Widget displayDraggable() {
//     return Stack(
//       children: keyAnimalDragable.map((id) {
//         ItemModel sourceModel = animals[id].sourceModel;
//         double topAlign = sourceModel.position.dy;
//         double leftAlign = sourceModel.position.dx;
//         return AnimatedPositioned(
//             key: Key(id.toString()),
//             top: topAlign * ratio + bonusHeight,
//             left: leftAlign * ratio,
//             duration: Duration(milliseconds: sourceModel.duration),
//             child: AppearAnimation(
//                 child: AnimationDraggableTap(
//                     buttonName: 'draggable_${sourceModel.id}',
//                     child: AnimationRotate(
//                       onTab: () {
//                         setState(() {
//                           rotateTime[id] = isFirstRotateTime[id]
//                               ? (rotateTime[id] + 2) % 4
//                               : (rotateTime[id] + 1) % 4;
//                           isFirstRotateTime[id] = false;
//                         });
//                       },
//                       child: Draggable(
//                         data: id,
//                         child: AnimationHitFail(
//                             isDisplayAnimation: isHitFail,
//                             child: puzzleWidget(
//                               sourceModel.width,
//                               sourceModel.height,
//                               animals[id].status == STATUS_MATCH
//                                   ? null
//                                   : sourceModel,
//                             )),
//                         feedback: genFeedBack(id),
//                         childWhenDragging: puzzleWidget(
//                             sourceModel.width, sourceModel.height, null),
//                         onDragEnd: (details) {
//                           santaJigsawLogic.totalDrag++;
//                           if (details.wasAccepted) {
//                           } else {}
//                         },
//                         onDragStarted: () {
//                           sourceModel.duration = 0;
//                         },
//                         maxSimultaneousDrags: 1,
//                         onDraggableCanceled: (velocity, offset) {
//                           if (isWrongTarget) {
//                             mascotRiveWidget.changeStatusFailure();
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
//   Widget displayCompletedImage() {
//     return Positioned(
//         top: bonusHeight,
//         left: 118 * ratio,
//         child: Container(
//           height: 296 * ratio,
//           width: 296 * ratio,
//           child: Image.asset(
//             PUZZLE_COMPLETED_IMAGE_1,
//             fit: BoxFit.contain,
//           ),
//         ));
//   }
//
//   Widget displaySkipButton() {
//     return Positioned(
//         top: 10 * ratio,
//         left: 700 * ratio,
//         child: tutorialCount >= 3
//             ? AppearAnimation(
//             child: AnimationButton(
//                 enable: !screenModel.isDisableSkipButton,
//                 onTab: () {
//                   if (!screenModel.isDisableSkipButton) {
//                     screenModel.logBasicEvent(
//                         'skip_game_${screenModel.currentGameScreen.id}',
//                         screenModel.currentGameScreen.id,
//                         'touch');
//                     screenModel.skipGame();
//                   }
//                 },
//                 child: Container(
//                   width: 100 * ratio,
//                   height: 42 * ratio,
//                   child: SvgPicture.asset(
//                     SKIP_BUTTON_IMAGE,
//                     fit: BoxFit.contain,
//                   ),
//                 )))
//             : Container());
//   }
//
//   List<Widget> displayScreen() {
//     List<Widget> widgets = [];
//     widgets.add(displayBackground());
//     widgets.add(displayBackButton());
//     widgets.add(displaySkipButton());
//
//     widgets.add(displayMascot());
//     // if (isShowRive) {
//     //   widgets.add(displayFinishRive());
//     // } else {
//     //   widgets.add(displayBeginnerTarget());
//     if (count < 4) {
//       widgets.add(displayImageModel());
//       widgets.add(displayTarget());
//       widgets.add(displayDraggable());
//     }
//     if (count == 4) {
//       widgets.add(displayCompletedImage());
//     }
//     // }
//     return widgets;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     screenWidth = screenModel.getScreenWidth();
//     screenHeight = screenModel.getScreenHeight();
//     ratio = screenModel.getRatio();
//     animals = santaJigsawLogic.animals;
//     bonusHeight = (screenHeight - 298 * ratio) / 2;
//     if (isFirstTime) {
//       draggableDirection = [
//         Offset(screenWidth * 13 / 24 - 220 * ratio, 150 * ratio + bonusHeight),
//         Offset(screenWidth * 13 / 24 - 13 * ratio, 125 * ratio + bonusHeight)
//       ];
//     }
//     setState(() {
//       isFirstTime = false;
//     });
//
//     return WillPopScope(
//         onWillPop: () async {
//           return false;
//         },
//         child: Listener(
//             onPointerDown: onPointerTap,
//             onPointerMove: onPointerTap,
//             onPointerUp: onPointerTap,
//             child: Scaffold(
//                 body: ScreenGestureDetector(
//                     child: Stack(children: displayScreen())))));
//   }
// }
