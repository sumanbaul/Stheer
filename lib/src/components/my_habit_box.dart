import 'package:flutter/material.dart';

class MyHabitBox extends StatelessWidget {
  const MyHabitBox({
    Key? key,
    required this.habitTextController,
    required this.onSave,
    required this.onCancel,
  }) : super(key: key);
  final habitTextController;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey[900],
      content: TextField(
        controller: habitTextController,
        decoration: const InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
              borderRadius: BorderRadius.all(Radius.circular(8)),
            )),
      ),
      actions: [
        //Cancel button
        MaterialButton(
          onPressed: onCancel,
          child: Text(
            "Cancel",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          color: Colors.black,
        ),

        //Save button
        MaterialButton(
          onPressed: onSave,
          child: Text(
            "Save",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          color: Colors.black,
        ),
      ],
    );
  }
}
