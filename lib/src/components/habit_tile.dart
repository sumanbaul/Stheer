import 'package:flutter/material.dart';
import 'package:path/path.dart';

class HabitTile extends StatelessWidget {
  final String habitName;
  final bool habitCompleted;
  final Function(bool?)? onChanged;

  const HabitTile({
    Key? key,
    required this.habitName,
    required this.habitCompleted,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            //checkbox
            Checkbox(
              value: habitCompleted,
              onChanged: onChanged,
            ),

            //habit name
            Text(habitName, style: TextStyle(color: Colors.black)),
          ],
        ),
      ),
    );
  }
}
