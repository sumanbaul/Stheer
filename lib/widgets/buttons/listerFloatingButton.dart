import 'package:flutter/material.dart';

class ListerFloatingButton extends StatelessWidget {
  const ListerFloatingButton({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      //backgroundColor: Color(0xffeeaeca),
      splashColor: Color(0xff94bbe9),
      hoverColor: Color(0xffeeaeca),
      focusColor: Color(0xff94bbe9),
      // onPressed: started ? stopListening : startListening,
      // tooltip: 'Start/Stop sensing',
      // child: _loading
      //     ? Icon(Icons.close)
      //     : (started ? Icon(Icons.close) : Icon(Icons.play_arrow)),
    );
  }
}
