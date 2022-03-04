import 'package:flutter/material.dart';

class AppButtonAction extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  AppButtonAction({this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        onPressed?.call();
        Navigator.of(context).maybePop();
      },
      child: Text(label),
    );
  }
}
