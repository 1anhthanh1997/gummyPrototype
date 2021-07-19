import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:provider/provider.dart';
import 'package:web_test/prototype/general_screen/home_screen.dart';
import 'package:web_test/provider/screen_model.dart';
import 'package:web_test/widgets/fade_animation.dart';

class CustomSlider extends StatefulWidget {
  _CustomSliderState createState() => _CustomSliderState();
}

class _CustomSliderState extends State<CustomSlider> {
  ScreenModel screenModel;
  double screenWidth;
  double screenHeight;
  double ratio;
  double value = 7;
  double valueTmp = 7;
  bool isDisplayArrow = false;

  @override
  void initState() {
    screenModel = Provider.of<ScreenModel>(context, listen: false);
    screenModel.setContext(context);
    super.initState();
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
    return Stack(
      children: [
        Positioned(
            top: 9,
            left: 10,
            child: Opacity(
                opacity: isDisplayArrow ? 1.0 : 0.6,
                child: Container(
                  height: 35,
                  width: 89,
                  child: SvgPicture.asset(
                    'assets/images/common/back_ray.svg',
                    fit: BoxFit.contain,
                  ),
                ))),
        !isDisplayArrow
            ? Positioned(
                top: 24,
                left: 26,
                child: Container(
                  height: 7,
                  width: 7,
                  child: SvgPicture.asset(
                    'assets/images/common/back_dot.svg',
                    fit: BoxFit.contain,
                  ),
                ),
              )
            : Container(),
        Positioned(
            top: 14,
            left: 18,
            child: FadeAnimation(
              // time: 500,
              isFade: isDisplayArrow,
              child: Container(
                height: 26,
                width: 70,
                child: SvgPicture.asset(
                  'assets/images/common/back_arrow.svg',
                  fit: BoxFit.contain,
                ),
              ),
            )),
        Positioned(
            top: 9,
            left: 10,
            child: Opacity(
                opacity: isDisplayArrow ? 1.0 : 0.8,
                child: Container(
                    height: 35,
                    width: 89,
                    child: FlutterSlider(
                      values: [value],
                      max: 39,
                      min: 7,
                      maximumDistance: 300,
                      rtl: true,
                      handlerWidth: 40,
                      handler: FlutterSliderHandler(
                        decoration: BoxDecoration(),
                        child: Container(
                          height: 32,
                          width: 33,
                          color: Colors.transparent,
                          child: SvgPicture.asset(
                            'assets/images/common/thumb_image.svg',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      handlerAnimation: FlutterSliderHandlerAnimation(
                          curve: Curves.elasticOut,
                          reverseCurve: Curves.bounceIn,
                          duration: Duration(milliseconds: 500),
                          scale: 1.1),
                      trackBar: FlutterSliderTrackBar(
                        inactiveTrackBar: BoxDecoration(
                          color: Colors.transparent,
                        ),
                        activeTrackBar:
                            BoxDecoration(color: Colors.transparent),
                      ),
                      tooltip: FlutterSliderTooltip(disabled: true),
                      onDragStarted: (handlerIndex, lowerValue, upperValue) {
                        setState(() {
                          isDisplayArrow = true;
                        });
                      },
                      onDragging: (handlerIndex, lowerValue, upperValue) {
                        setState(() {
                          value = lowerValue;
                        });
                      },
                      onDragCompleted: (handlerIndex, lowerValue, upperValue) {
                        setState(() {
                          isDisplayArrow = false;
                        });
                        if (lowerValue < 23) {
                          setState(() {
                            value = 7;
                          });
                        } else {
                          setState(() {
                            value = 39;
                          });
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => HomeScreen()),
                              ModalRoute.withName("/Home"));
                        }
                      },
                    )))),
      ],
    );
  }
}
