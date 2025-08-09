import 'package:flutter/material.dart';
import 'package:notifoo/src/model/habits_model.dart';

class ShowForm {
  final List<HabitsModel> habits;

  final BuildContext context;
  final VoidCallback? onEditCallback;
  final Function(String title, String type) onCreate;
  final Function(String title, String type) onEdit;

  final int? id;

  //private variables
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  int _repetitions = 1;
  String _selectedCategory = 'Health';
  final List<TimeOfDay> _times = [const TimeOfDay(hour: 9, minute: 0)];
  final List<Color> _palette = const [
    Color(0xFF7C83FF), Color(0xFF8B5CF6), Color(0xFF06B6D4),
    Color(0xFF10B981), Color(0xFFF59E0B), Color(0xFFEF4444)
  ];
  Color _selectedColor = const Color(0xFF7C83FF);
  int _daysPerWeek = 7;
  bool _reminders = true;

  ShowForm({
    required this.habits,
    required this.context,
    this.onEditCallback,
    required this.id,
    required this.onCreate,
    required this.onEdit,
  });
  // This function will be triggered when the floating button is pressed
  // It will also be triggered when you want to update an item
  Future<void> showForm(HabitsModel? habit, String title) async {
    if (habit != null) {
      // id == null -> create new item
      // id != null -> update an existing item
      //////Here is an issue, that needs to be fixed
      //final existingHabit = habits.firstWhere((element) => element.id == id);
      _titleController.text = habit.habitTitle!;
      _descriptionController.text = habit.habitType!;
    }

    return await showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
      elevation: 5,
      isScrollControlled: true,
      builder: (_) => Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
          color: Theme.of(context).colorScheme.surface,
        ),
        padding: EdgeInsets.only(
          top: 16,
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: StatefulBuilder(
          builder: (context, setState) => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.track_changes, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Habit title', hintText: 'e.g., Morning Run'),
              ),
              const SizedBox(height: 16),
              Text('Category', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _catChip('Health', Icons.favorite, setState),
                  _catChip('Study', Icons.menu_book, setState),
                  _catChip('Fitness', Icons.fitness_center, setState),
                  _catChip('Mindfulness', Icons.self_improvement, setState),
                  _catChip('Custom', Icons.category, setState),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Type/Notes', hintText: 'e.g., 5km or Yoga',
                  suffixText: _selectedCategory),
              ),
              const SizedBox(height: 16),
              Text('Color', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                children: _palette.map((c) => GestureDetector(
                  onTap: () => setState(() { _selectedColor = c; }),
                  child: Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: Border.all(color: c == _selectedColor ? Colors.white : Colors.transparent, width: 2),
                    ),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Days per week', style: Theme.of(context).textTheme.labelLarge),
                  Text('$_daysPerWeek/7'),
                ],
              ),
              Slider(
                value: _daysPerWeek.toDouble(), min: 1, max: 7, divisions: 6,
                onChanged: (v){ setState(() { _daysPerWeek = v.round(); }); },
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: Text('Reminders', style: Theme.of(context).textTheme.labelLarge)),
                  Switch(value: _reminders, onChanged: (v){ setState(() { _reminders = v; }); }),
                ],
              ),
              const SizedBox(height: 12),
              Row(children: [
                Text('Times per day', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(width: 12),
                DropdownButton<int>(
                  value: _repetitions,
                  items: [1,2,3,4,5].map((e)=>DropdownMenuItem(value: e, child: Text('$e'))).toList(),
                  onChanged: (v){
                    if (v==null) return;
                    setState(() {
                      _repetitions = v;
                      while (_times.length < v) { _times.add(const TimeOfDay(hour: 9, minute: 0)); }
                      while (_times.length > v) { _times.removeLast(); }
                    });
                  },
                )
              ]),
              const SizedBox(height: 8),
              Column(
                children: List.generate(_repetitions, (i) {
                  final t = _times[i];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.access_time),
                    title: Text('${t.hour.toString().padLeft(2,'0')}:${t.minute.toString().padLeft(2,'0')}'),
                    trailing: TextButton(
                      onPressed: () async {
                        final picked = await showTimePicker(context: context, initialTime: _times[i]);
                        if (picked != null) { setState(() { _times[i] = picked; }); }
                      },
                      child: const Text('Change'),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final colorHex = '#${_selectedColor.value.toRadixString(16).padLeft(8,'0')}';
                    final timesStr = _times.map((t)=>'${t.hour.toString().padLeft(2,'0')}:${t.minute.toString().padLeft(2,'0')}').join(',');
                    final encoded = '${_descriptionController.text}::rep=$_repetitions::cat=$_selectedCategory::times=$timesStr::days=$_daysPerWeek::rem=${_reminders?1:0}::color=$colorHex';
                    if (id == null) {
                      onCreate(_titleController.text, encoded);
                    } else {
                      onEdit(_titleController.text, encoded);
                    }
                    _titleController.clear();
                    _descriptionController.clear();
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.check),
                  label: Text(id == null ? 'Create Habit' : 'Update Habit'),
                ),
              ),
            ],
        ),
        ),
      ),
    ),
    ).whenComplete(() {
      print('Hey there, I\'m calling after hide bottomSheet');
    });
  }

  Widget _catChip(String label, IconData icon, void Function(void Function()) setState) {
    return ChoiceChip(
      selected: _selectedCategory == label,
      label: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 16), const SizedBox(width: 6), Text(label)]),
      onSelected: (_) { setState(() { _selectedCategory = label; }); },
    );
  }
}
