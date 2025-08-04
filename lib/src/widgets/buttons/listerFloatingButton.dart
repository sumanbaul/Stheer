import 'package:flutter/material.dart';

class ListerFloatingButton extends StatelessWidget {
  const ListerFloatingButton({Key? key, this.onClicked, this.floaterIcon})
      : super(key: key);
  final VoidCallback? onClicked;
  final Icon? floaterIcon;
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'lister_floating_button',
      //backgroundColor: Color(0xffeeaeca),
      splashColor: Color(0xff94bbe9),
      hoverColor: Color(0xffeeaeca),
      focusColor: Color(0xff94bbe9),
      onPressed: onClicked, //started ? stopListening : startListening,
      tooltip: 'Start/Stop sensing',
      child: floaterIcon,
      // child: _loading
      //     ? Icon(Icons.close)
      //     : (started ? Icon(Icons.close) : Icon(Icons.play_arrow)),
    );
  }
}
