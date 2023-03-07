import 'package:flutter/material.dart';

class FloatingActionBtn extends StatelessWidget {
  const FloatingActionBtn({
    Key? key,
    required this.onPressed,
  }) : super(key: key);
  final Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      child: Icon(Icons.my_library_add_outlined),
      backgroundColor: Color.fromARGB(255, 89, 208, 230),
    );
  }
}
