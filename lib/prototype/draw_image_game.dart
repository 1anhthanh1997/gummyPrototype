import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:svg_path_parser/svg_path_parser.dart';
import 'package:web_test/model/color_model.dart';
import 'package:web_test/model/game_draw_model.dart';
import 'package:web_test/widgets/animation_color.dart';

class DrawImageGame extends StatefulWidget {
  _DrawImageGameState createState() => _DrawImageGameState();
}

class _DrawImageGameState extends State<DrawImageGame> {
  List<Path> _imagePath = [];
  List<String> imageLink = [];
  List<Offset> imagePosition = [];
  List<String> color = [];
  List<bool> canDraw = [];
  List<GameDrawModel> imageData = [];
  late List data = [];
  late List secondData = [];
  late List<ColorModel> colorData = [];
  String currentColor = '';
  double bonusHeight = (375 - 319) / 2 + 20;
  List<bool> isCompleted = [];

  void extractFile() async{
    final zipFile = File("assets/images_2.zip");
    final destinationDir = Directory("assets/images_2/");
    try {
      await ZipFile.extractToDirectory(
          zipFile: zipFile,
          destinationDir: destinationDir,
          onExtracting: (zipEntry, progress) {
            print('progress: ${progress.toStringAsFixed(1)}%');
            print('name: ${zipEntry.name}');
            print('isDirectory: ${zipEntry.isDirectory}');
            print(
                'modificationDate: ${zipEntry.modificationDate!.toLocal().toIso8601String()}');
            print('uncompressedSize: ${zipEntry.uncompressedSize}');
            print('compressedSize: ${zipEntry.compressedSize}');
            print('compressionMethod: ${zipEntry.compressionMethod}');
            print('crc: ${zipEntry.crc}');
            return ZipFileOperation.includeItem;
          });
    } catch (e) {
      print(e);
    }
  }

  Future<void> loadImageData() async {
    var jsonData = await rootBundle.loadString('assets/draw_turtle_data.json');
    var fullData = json.decode(jsonData);
    data = fullData['coloringImage'];
    secondData = fullData['colorItem'];
    imageData =
        data.map((imageInfo) => new GameDrawModel.fromJson(imageInfo)).toList();
    colorData = secondData
        .map((colorInfo) => new ColorModel.fromJson(colorInfo))
        .toList();

    for (int index = 0; index < imageData.length; index++) {
      setState(() {
        _imagePath.add(parseSvgPath(imageData[index].path));
        imageLink.add('assets/' + imageData[index].image);
        imagePosition.add(imageData[index].position);
        color.add(imageData[index].color);
        canDraw.add(imageData[index].canDraw);
        isCompleted.add(false);
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    this.loadImageData();
    extractFile();
    super.initState();
  }

  Widget displayImage() {
    List<int> imageIndex = Iterable<int>.generate(imageData.length).toList();
    imageIndex.sort((a, b) => b.compareTo(a));
    print(imageIndex);
    return Stack(
      children: imageIndex.map((index) {
        return canDraw[index]
            ? Positioned(
                top: imagePosition[index].dy + bonusHeight,
                left: imagePosition[index].dx,
                child: AnimationColor(
                  beginColor: Colors.white,
                  endColor: HexColor(color[index]),
                  isChangeColor: isCompleted[index],
                  pathString: '',
                  url: imageLink[index],
                ))
            : Positioned(
                top: imagePosition[index].dy + bonusHeight,
                left: imagePosition[index].dx,
                child: SvgPicture.asset(imageLink[index]));
      }).toList(),
    );
  }

  Widget displayColor() {
    List<int> colorIndex = Iterable<int>.generate(colorData.length).toList();
    print(colorIndex);
    return Stack(
        children: colorIndex.map((colorIndex) {
      ColorModel color = colorData[colorIndex];
      return Positioned(
          top: color.position.dy,
          left: color.position.dx,
          child: GestureDetector(
            onTap: () {
              setState(() {
                currentColor = color.color;
              });
            },
            child: Container(
              height: 50,
              width: 50,
              color: HexColor(color.color),
            ),
          ));
    }).toList());
  }

  List<Widget> displayScreen() {
    List<Widget> widgets = [];
    widgets.add(displayImage());
    widgets.add(displayColor());
    return widgets;
  }

  void onTapDown(Offset position) {
    for (int index = 0; index < _imagePath.length; index++) {
      Offset localOffset = Offset(position.dx - imagePosition[index].dx,
          position.dy - imagePosition[index].dy - bonusHeight);
      if (_imagePath[index].contains(localOffset) &&
          color[index] == currentColor) {
        setState(() {
          isCompleted[index] = true;
        });
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: imageData.length != 0
            ? Container(
                child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTapDown: (details) {
                      onTapDown(details.localPosition);
                    },
                    child: Stack(
                      children: displayScreen(),
                    )))
            : Container());
  }
}
