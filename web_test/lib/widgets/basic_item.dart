import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:web_test/prototype/general_screen/tutorial_animal.dart';
import 'package:web_test/provider/screen_model.dart';

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
        Positioned(
            top: 9,
            left: 10,
            child: Container(
              height: 35,
              width: 89,
              child: SvgPicture.asset(
                'assets/images/common/back_button.svg',
                fit: BoxFit.contain,
              ),
            )),
      ],
    );
  }
}
