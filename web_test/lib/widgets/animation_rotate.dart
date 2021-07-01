

import 'package:flutter/material.dart';


class AnimationRotate extends StatefulWidget {
  final Widget child;
  final VoidCallback onTab;


  // String state;
  AnimationRotate({  this.child,  this.onTab}) : super();
  _AnimationRotateState myAppState = new _AnimationRotateState();

  @override
  _AnimationRotateState createState() => myAppState;

  void playAnimation() {
    myAppState.playAnimation();
  }

  void playReserveAnimation() {
    myAppState.playReserveAnimation();
  }
}

class _AnimationRotateState extends State<AnimationRotate>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _animation;

  int dir = 0;

  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 800));
    super.initState();
  }

  @override
  void dispose() {
    if(_controller!=null){
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void playAnimation() {
    _controller.forward(from: 0);
    setState(() {
      dir = dir + 1;
    });
  }

  void playReserveAnimation() {
    // //print('Ok');
    _controller.forward(from: 0);
    setState(() {
      dir = dir-1;
    });
  }

  double getBeginPosition() {
    switch (dir % 4) {
      case 0:
        {
          return 0.0;
        }
        break;
      case 1:
        {
          return 0.25;
        }
        break;
      case 2:
        {
          return 0.5;
        }
        break;
      case 3:
        {
          return 0.75;
        }
        break;
      default:
        return 0.0;
        break;
    }
  }

  double getEndPosition() {
    switch (dir % 4) {
      case 0:
        {
          return 0.25;
        }
        break;
      case 1:
        {
          return 0.5;
        }
        break;
      case 2:
        {
          return 0.75;
        }
        break;
      case 3:
        {
          return 1.0;
        }
        break;
      default:
        return 1.0;
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    //print(dir);
    //print(getBeginPosition());
    //print(getEndPosition());
    _animation = Tween<double>(begin: getBeginPosition(), end: getEndPosition())
        .animate(_controller);
    return Container(
        child: RotationTransition(
            turns: _animation,
            child: GestureDetector(
                child: widget.child,
                onTap: () {
                  _controller.forward(from: 0.0);
                  setState(() {
                    dir=dir+1;
                  });
                  widget.onTab();
                  // });
                })));

  }
}
