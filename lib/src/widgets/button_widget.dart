import 'package:flutter/material.dart';

class ButtonWidget extends StatelessWidget {
  final String? text;
  final VoidCallback? onClicked;
  final Color color;
  final Color backgroundColor;

  const ButtonWidget({
    Key? key,
    this.text,
    this.onClicked,
    this.color = Colors.white,
    this.backgroundColor = Colors.black,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: backgroundColor,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          elevation: 18,
          shape: StadiumBorder(),
        ),
        child: Text(
          text!,
          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
        ),
        onPressed: onClicked,
      ),
    );
  }
}
