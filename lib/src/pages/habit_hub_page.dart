import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notifoo/src/widgets/habits/habit_lister.dart';
import 'package:notifoo/src/widgets/habits/show_form.dart';
import 'package:notifoo/src/widgets/headers/subHeader.dart';
import 'package:notifoo/src/services/push_notification_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../helper/DatabaseHelper.dart';
import '../model/habits_model.dart';
import '../widgets/habits/data/habit_card_menu_items.dart';
import '../widgets/habits/habit_card_menu_item.dart';
import '../widgets/navigation/nav_drawer_widget.dart';

class HabitHubPage extends StatefulWidget {
  HabitHubPage({
    Key? key, 
    this.title, 
    this.openNavigationDrawer,
    this.showAppBar = true,
  }) : super(key: key);
  final String? title;
  final VoidCallback? openNavigationDrawer;
  final bool showAppBar;

  @override
  State<HabitHubPage> createState() => _HabitHubPage();
}

class _HabitHubPage extends State<HabitHubPage> {
  bool _isLoading = true;
  int _completedHabits = 0;
  int _totalHabits = 0;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // All habits
  List<HabitsModel> _habits = [];

  // This function is used to fetch all data from the database
  void _refreshHabits() async {
    final data = await DatabaseHelper.instance.getHabits();
    setState(() {
      _habits = data;
      _totalHabits = data.length;
      _completedHabits = data.where((habit) => habit.isCompleted == 1).length;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshHabits();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: widget.showAppBar ? AppBar(
        title: Text('Habits'),
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: widget.openNavigationDrawer,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _showAddHabitForm(),
            tooltip: 'Add New Habit',
          ),
        ],
      ) : null,
      body: Column(
        children: [
          // Header Section
          Container(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Habit Tracker',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Build positive habits and track your progress',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                SizedBox(height: 16),
                
                // Progress Card
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.track_changes,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Today\'s Progress',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '$_completedHabits of $_totalHabits habits completed',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                              ),
                            ),
                            SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: _totalHabits > 0 ? _completedHabits / _totalHabits : 0,
                              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Habits List
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _habits.isEmpty
                    ? _buildEmptyState()
                    : _buildHabitsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'habit_add_button',
        onPressed: () => _showAddHabitForm(),
        child: Icon(Icons.add),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.track_changes_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          SizedBox(height: 16),
          Text(
            'No habits yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Start building positive habits by adding your first one',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddHabitForm(),
            icon: Icon(Icons.add),
            label: Text('Add First Habit'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitsList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20),
      itemCount: _habits.length,
      itemBuilder: (context, index) {
        final habit = _habits[index];
        return Card(
          margin: EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: habit.isCompleted == 1 
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: habit.isCompleted == 1 
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                ),
              ),
              child: Icon(
                habit.isCompleted == 1 ? Icons.check : Icons.circle_outlined,
                color: habit.isCompleted == 1 
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            title: Text(
              habit.habitTitle ?? '',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                decoration: habit.isCompleted == 1 
                    ? TextDecoration.lineThrough
                    : null,
              ),
            ),
            subtitle: Text(
              habit.habitType ?? '',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) => _handleHabitAction(value, habit),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'toggle',
                  child: Row(
                    children: [
                      Icon(
                        habit.isCompleted == 1 ? Icons.undo : Icons.check,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text(habit.isCompleted == 1 ? 'Mark Incomplete' : 'Mark Complete'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 18),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
            onTap: () => _toggleHabitCompletion(habit),
          ),
        );
      },
    );
  }

  void _showAddHabitForm() {
    ShowForm(
      habits: _habits,
      context: context,
      onCreate: (String title, String type) {
        _titleController.text = title;
        _descriptionController.text = type;
        _addItem();
      },
      onEdit: (String title, String type) {
        print("on edit pressed: $title");
      },
      id: null,
    ).showForm(null, 'Add New Habit');
  }

  void _handleHabitAction(String action, HabitsModel habit) {
    switch (action) {
      case 'toggle':
        _toggleHabitCompletion(habit);
        break;
      case 'edit':
        _editHabit(habit);
        break;
      case 'delete':
        _deleteHabit(habit);
        break;
    }
  }

  void _toggleHabitCompletion(HabitsModel habit) async {
    final updatedHabit = HabitsModel(
      id: habit.id,
      habitTitle: habit.habitTitle,
      habitType: habit.habitType,
      isCompleted: habit.isCompleted == 1 ? 0 : 1,
      color: habit.color,
    );
    
    await DatabaseHelper.instance.updateHabitItem(
      habit.id!,
      habit.habitTitle!,
      habit.habitType!,
    );
    _refreshHabits();
  }

  void _editHabit(HabitsModel habit) {
    ShowForm(
      context: context,
      habits: _habits,
      id: habit.id,
      onCreate: (String title, String type) {},
      onEdit: (String title, String type) {
        _titleController.text = title;
        _descriptionController.text = type;
        _updateItem(habit.id!);
      },
    ).showForm(habit, 'Edit Habit');
  }

  void _deleteHabit(HabitsModel habit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Habit'),
        content: Text('Are you sure you want to delete "${habit.habitTitle}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteItem(habit.id!);
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Insert a new habit to the database
  Future<void> _addItem() async {
    HabitsModel _habit = new HabitsModel(
        habitTitle: _titleController.text,
        habitType: _descriptionController.text,
        isCompleted: 0,
        color: Colors.pink.toString());
    await DatabaseHelper.instance.createHabit(_habit);
    
    // Schedule push notification for the new habit
    try {
      await PushNotificationService().scheduleHabitReminder(
        _habit.id.toString(),
        _habit.habitTitle ?? 'New Habit',
        9, 0, // Default reminder at 9 AM
      );
      print('Habit reminder scheduled successfully');
    } catch (e) {
      print('Failed to schedule habit reminder: $e');
    }
    
    _refreshHabits();
  }

  // Update an existing habit
  Future<void> _updateItem(int id) async {
    await DatabaseHelper.instance.updateHabitItem(
        id, _titleController.text, _descriptionController.text);
    _refreshHabits();
  }

  // Delete an item
  void _deleteItem(int id) async {
    await DatabaseHelper.instance.deleteHabitItem(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Habit deleted successfully!'),
    ));
    _refreshHabits();
  }
}
