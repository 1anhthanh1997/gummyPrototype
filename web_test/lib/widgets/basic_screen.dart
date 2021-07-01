import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:web_test/provider/screen_model.dart';

class BasicLogic extends StatefulWidget {
  BuildContext context;
  int totalDrag = 0;
  ScreenModel screenModel;

  BasicLogic(_context) {
    context = _context;
    screenModel = Provider.of<ScreenModel>(context, listen: false);
    screenModel.setContext(context);
  }

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    throw UnimplementedError();
  }


}
