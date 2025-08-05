import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:notifoo/src/model/tasks.dart';
import 'package:notifoo/src/services/push_notification_service.dart';

var _taskType = ["Growth", "Daily", "Projects", "Shopping", "Timer", "Work", "Personal", "Health"];

final TextEditingController _taskNameController = TextEditingController();
final TextEditingController _repeatitionController = TextEditingController();
final Map<dynamic, dynamic> _task = {};
final rnd = math.Random();

String _taskTypeText = "Growth";

class AddTask extends StatefulWidget {
  final Function(String?) onChanged;
  final VoidCallback onPressed;
  final taskNameController;
  final repeatitionController;
  
  AddTask({
    key,
    required this.onChanged,
    required this.onPressed,
    this.repeatitionController,
    this.taskNameController,
  });

  @override
  _AddTaskState createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String _selectedTaskType = "Growth";
  int _repeatitions = 1;

  @override
  void initState() {
    super.initState();
    _repeatitionController.text = "1";
    _taskTypeText = _selectedTaskType;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text('Add New Task'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _isLoading ? null : _submitTask,
            tooltip: 'Save Task',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                margin: EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create New Task',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Add a new task to your productivity list',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),

              // Task Name Field
              Container(
                margin: EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Task Name',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _taskNameController,
                      decoration: InputDecoration(
                        hintText: 'Enter task name...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                        prefixIcon: Icon(
                          Icons.task,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a task name';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              // Task Type Field
              Container(
                margin: EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Task Type',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                        ),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: _selectedTaskType,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          prefixIcon: Icon(
                            Icons.category,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        items: _taskType.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedTaskType = newValue!;
                            _taskTypeText = newValue;
                          });
                        },
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Repetitions Field
              Container(
                margin: EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Repetitions',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _repeatitionController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'Number of repetitions',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.surface,
                              prefixIcon: Icon(
                                Icons.repeat,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter repetitions';
                              }
                              int? repetitions = int.tryParse(value);
                              if (repetitions == null || repetitions < 1) {
                                return 'Please enter a valid number';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              _repeatitions = int.tryParse(value) ?? 1;
                            },
                          ),
                        ),
                        SizedBox(width: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                _repeatitions++;
                                _repeatitionController.text = _repeatitions.toString();
                              });
                            },
                            icon: Icon(Icons.add),
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            onPressed: () {
                              if (_repeatitions > 1) {
                                setState(() {
                                  _repeatitions--;
                                  _repeatitionController.text = _repeatitions.toString();
                                });
                              }
                            },
                            icon: Icon(Icons.remove),
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Color Picker
              Container(
                margin: EdgeInsets.only(bottom: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Task Color',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 12),
                    Container(
                      height: 60,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 8,
                        itemBuilder: (context, index) {
                          final colors = [
                            Colors.red,
                            Colors.orange,
                            Colors.yellow,
                            Colors.green,
                            Colors.blue,
                            Colors.indigo,
                            Colors.purple,
                            Colors.pink,
                          ];
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                // Store selected color
                              });
                            },
                            child: Container(
                              width: 50,
                              height: 50,
                              margin: EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                color: colors[index],
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitTask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.save),
                            SizedBox(width: 8),
                            Text(
                              'Save Task',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitTask() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simulate API call
      Future.delayed(Duration(milliseconds: 500), () async {
        var _randomColor = rnd.nextInt(0xffffffff);

        _task['id'] = int.parse(DateTime.now().day.toString() +
            DateTime.now().hour.toString() +
            DateTime.now().minute.toString());
        _task['title'] = _taskNameController.text;
        _task['repeatitions'] = int.parse(_repeatitionController.text);
        _task['isCompleted'] = int.parse("0");
        _task['taskType'] = _taskTypeText;
        _task['color'] = _randomColor.toString();
        _task['createdDate'] = DateTime.now().toString();
        _task['modifiedDate'] = DateTime.now().toString();

        Map<String, dynamic> taskMap = Map<String, dynamic>.from(_task);

        List<Tasks> tasks = [Tasks.fromMap(taskMap)];
        
        // Schedule push notification for the new task
        try {
          DateTime deadline = DateTime.now().add(Duration(days: 1)); // Default deadline: tomorrow
          await PushNotificationService().scheduleTaskReminder(
            _task['id'].toString(),
            _task['title'],
            deadline,
          );
          print('Task reminder scheduled successfully');
        } catch (e) {
          print('Failed to schedule task reminder: $e');
        }
        
        setState(() {
          _isLoading = false;
        });

        Navigator.of(context).pop(tasks);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task created successfully!'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      });
    }
  }
}
