import 'package:flutter/material.dart';
import 'package:notifoo/model/habits_model.dart';

class ShowForm {
  final List<HabitsModel> habits;

  final BuildContext context;
  final VoidCallback? onEditCallback;
  final Function(String title, String type) onCreate;
  final Function(String title, String type)? onEdit;

  final int? id;

  //private variables
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  ShowForm({
    required this.habits,
    required this.context,
    this.onEditCallback,
    required this.id,
    required this.onCreate,
    this.onEdit,
  });
  // This function will be triggered when the floating button is pressed
  // It will also be triggered when you want to update an item
  Future<Widget> showForm(int? id) async {
    if (id != null) {
      // id == null -> create new item
      // id != null -> update an existing item
      //////Here is an issue, that needs to be fixed
      final existingHabit = habits.firstWhere((element) => element.id == id);
      _titleController.text = existingHabit.habitTitle!;
      _descriptionController.text = existingHabit.habitType!;
    }

    return await showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
      elevation: 5,
      isScrollControlled: true,
      builder: (_) => Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25), topRight: Radius.circular(25)),
            color: Color.fromARGB(235, 34, 32, 48)),
        padding: EdgeInsets.only(
          top: 15,
          left: 15,
          right: 15,
          // this will prevent the soft keyboard from covering the text fields
          bottom: MediaQuery.of(context).viewInsets.bottom + 120,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Center(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Add New Habit',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '🔥😎',
                    style: TextStyle(fontSize: 20),
                  )
                ],
              ),
            ),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(hintText: 'Habit Title'),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(hintText: 'Habit Type'),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () async {
                // Save new journal
                if (id == null) {
                  onCreate(_titleController.text, _descriptionController.text);
                  // onEditCallback(
                  //   onCreate()
                  // ); // _addItem();
                }

                if (id != null) {
                  //await _updateItem(id);
                  onEdit!(_titleController.text, _descriptionController.text);
                }

                // Clear the text fields
                _titleController.text = '';
                _descriptionController.text = '';

                // Close the bottom sheet
                Navigator.of(context).pop();
              },
              child: Text(id == null ? 'Create New' : 'Update'),
            )
          ],
        ),
      ),
    );
  }
}
