import 'package:flutter/material.dart';

class MyAlertBox extends StatelessWidget {
  const MyAlertBox({
    Key? key,
    required this.habitTextController,
    required this.onSave,
    required this.onCancel,
    required this.hintText,
    required this.onSelectIcon,
    required this.selectedIcon,
  }) : super(key: key);
  final String hintText;
  final habitTextController;
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final VoidCallback onSelectIcon;
  final Icon selectedIcon;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey[800],
      content: Container(
        height: 130,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              habitTextController.text == '' ? 'Add Habit' : 'Edit Habit',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
            ),
            Row(
              children: [
                MaterialButton(
                  onPressed: onSelectIcon,
                  child: Text('Select Icon'),
                ),
                //selectedIcon != null ? Icon(selectedIcon.icon) : Text('blank'),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: selectedIcon ?? Container(),
                ),
              ],
            ),
            TextField(
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
          ],
        ),
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
          color: Color.fromARGB(255, 183, 95, 95),
          elevation: 5,
        ),

        //Save button
        MaterialButton(
          onPressed: onSave,
          child: Text(
            habitTextController.text == "" ? 'Save' : 'Update',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          color: Color.fromARGB(255, 151, 110, 204),
        ),
      ],
    );
  }
}
