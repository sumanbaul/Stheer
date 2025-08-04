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
      heroTag: 'floating_action_btn',
      onPressed: onPressed,
      child: Icon(
        Icons.my_library_add_outlined,
        color: Colors.white,
      ),
      backgroundColor: Color.fromARGB(235, 34, 32, 48),
      elevation: 10,
      tooltip: 'Add New Habit', // Color.fromARGB(255, 89, 208, 230),
    );
  }
}
