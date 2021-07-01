import 'package:flutter/material.dart';

class ScreenModel extends ChangeNotifier {
  double screenWidth;
  double screenHeight;
  double ratio;
  BuildContext currentContext;

  void setContext(BuildContext context) {
    currentContext = context;
  }

  double getScreenWidth() {
    screenWidth = MediaQuery.of(currentContext).size.width;
    return screenWidth;
  }

  double getScreenHeight() {
    screenHeight = MediaQuery.of(currentContext).size.height;
    return screenHeight;
  }

  double getRatio() {
    double heightRatio = getScreenHeight() / 375;
    double widthRatio = getScreenWidth() / 812;
    ratio = heightRatio > widthRatio ? widthRatio : heightRatio;
    return ratio;
  }

  Path scalePath(Path path) {
    final Matrix4 matrix4 = Matrix4.identity();
    matrix4.scale(ratio, ratio);
    return path.transform(matrix4.storage);
  }
}
