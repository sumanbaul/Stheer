import 'package:flutter/material.dart';

class MyAlertBox extends StatelessWidget {
  const MyAlertBox({
    Key? key,
    required this.habitTextController,
    required this.onSave,
    required this.onCancel,
    required this.hintText,
  }) : super(key: key);
  final String hintText;
  final habitTextController;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey[900],
      content: TextField(
        controller: habitTextController,
        style: const TextStyle(
          color: Colors.white,
        ),
        decoration: InputDecoration(
            hintText: hintText,
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
