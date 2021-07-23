import 'package:flutter/material.dart';

showResultDialog(
    BuildContext parentContext, int totalDrag, int totalItem) async {
  await Future.delayed(Duration(seconds: 1));
  showGeneralDialog(
      barrierColor: Colors.black.withOpacity(0.5),
      transitionBuilder: (context, a1, a2, widget) {
        return WinningScreen(parentContext);
      },
      transitionDuration: Duration(milliseconds: 300),
      barrierDismissible: true,
      barrierLabel: '',
      context: parentContext,
      pageBuilder: (context, animation1, animation2) {});

}


class WinningScreen extends StatefulWidget{
  final BuildContext parentContext;
  
  WinningScreen(this.parentContext);
  
  _WinningScreenState createState()=> _WinningScreenState();
}

class _WinningScreenState extends State<WinningScreen>{

  List<Widget> displayScreen(){

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child:Stack(
          children: displayScreen(),
        )
      ),
    );
  }

}