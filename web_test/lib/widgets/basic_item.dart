import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:web_test/prototype/general_screen/tutorial_animal.dart';
import 'package:web_test/provider/screen_model.dart';

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
        Positioned(
          top: 9,
          left: 10,
          child: Container(
            height: 50,
            width: 150,
            child: LiteRollingSwitch(
              //initial value
              value: true,
              textOn: 'disponible',
              textOff: 'ocupado',
              colorOn: Colors.greenAccent[700],
              colorOff: Colors.redAccent[700],
              iconOn: Icons.done,
              iconOff: Icons.remove_circle_outline,
              textSize: 16.0,
              onChanged: (bool state) {
                //Use it to manage the different states
                print('Current State of SWITCH IS: $state');
              },
            ),
          ),
        ),

      ],
    );
  }
}
