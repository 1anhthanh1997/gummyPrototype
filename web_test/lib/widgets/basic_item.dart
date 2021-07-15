import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:web_test/prototype/general_screen/tutorial_animal.dart';
import 'package:web_test/provider/screen_model.dart';
import 'package:web_test/widgets/slider/custom_slider.dart';

import 'lite_rolling_switch.dart';

class BasicItem extends StatefulWidget {
  _BasicItemState createState() => _BasicItemState();
}

class _BasicItemState extends State<BasicItem> {
  ScreenModel screenModel;

  @override
  void initState() {
    screenModel = Provider.of<ScreenModel>(context, listen: false);
    screenModel.setContext(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        TutorialAnimals(
          tutorialImage: 'assets/images/common/dog.svg',
        ),
        CustomSlider()
      ],
    );
  }
}
