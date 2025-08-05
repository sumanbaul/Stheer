import 'package:flutter/material.dart';
import 'package:notifoo/src/helper/DatabaseHelper.dart';
import 'package:notifoo/src/helper/provider/task_api_provider.dart';
import 'package:notifoo/src/model/tasks.dart';
import 'package:notifoo/src/pages/add_task.dart';
import 'package:notifoo/src/services/push_notification_service.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({
    Key? key, 
    this.openNavigationDrawer,
    this.showAppBar = true,
  }) : super(key: key);
  final VoidCallback? openNavigationDrawer;
  final bool showAppBar;

  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  //Controllers
  final _repeatitionController = TextEditingController();
  final _taskNameController = TextEditingController();

  // A field value to capture from the child widget
  String taskName = '';
  String taskType = '';
  int repeatitions = 0;

  var isLoading = false;
  Tasks fieldValues = Tasks();
  
  // Task statistics
  int _totalTasks = 0;
  int _completedTasks = 0;
  int _pendingTasks = 0;
  String _selectedFilter = 'all'; // all, completed, pending

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });
    
    try {
      final tasks = await DatabaseHelper.instance.getAllTasks();
      if (mounted) {
        setState(() {
          _totalTasks = tasks.length;
          _completedTasks = tasks.where((task) => task.isCompleted == 1).length;
          _pendingTasks = _totalTasks - _completedTasks;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: widget.showAppBar ? AppBar(
        title: Text('Tasks'),
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: widget.openNavigationDrawer,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(),
            tooltip: 'Filter Tasks',
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _showAddTaskForm(),
            tooltip: 'Add New Task',
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
                  'Task Manager',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Organize and complete your tasks efficiently',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                SizedBox(height: 16),
                
                // Stats Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Total',
                        _totalTasks.toString(),
                        Icons.assignment,
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Completed',
                        _completedTasks.toString(),
                        Icons.check_circle,
                        Colors.green,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Pending',
                        _pendingTasks.toString(),
                        Icons.pending,
                        Colors.orange,
                      ),
                    ),
                  ],
                ),
                
                // Filter Chips
                SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All', 'all'),
                      SizedBox(width: 8),
                      _buildFilterChip('Pending', 'pending'),
                      SizedBox(width: 8),
                      _buildFilterChip('Completed', 'completed'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Tasks List
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : _buildTasksListView(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'task_add_button',
        onPressed: () => _showAddTaskForm(),
        child: Icon(Icons.add),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
      selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
      checkmarkColor: Theme.of(context).colorScheme.primary,
    );
  }

  Widget _buildTasksListView() {
    return FutureBuilder<List<Tasks>>(
      future: DatabaseHelper.instance.getAllTasks(),
      builder: (BuildContext context, AsyncSnapshot<List<Tasks>> snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState();
        }

        List<Tasks> filteredTasks = _filterTasks(snapshot.data!);
        
        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 20),
          itemCount: filteredTasks.length,
          itemBuilder: (BuildContext context, int index) {
            final task = filteredTasks[index];
            return _buildTaskCard(task, index);
          },
        );
      },
    );
  }

  List<Tasks> _filterTasks(List<Tasks> tasks) {
    switch (_selectedFilter) {
      case 'completed':
        return tasks.where((task) => task.isCompleted == 1).toList();
      case 'pending':
        return tasks.where((task) => task.isCompleted == 0).toList();
      default:
        return tasks;
    }
  }

  Widget _buildTaskCard(Tasks task, int index) {
    final isCompleted = task.isCompleted == 1;
    final taskColor = _parseTaskColor(task.color);
    
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isCompleted ? Colors.green : taskColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isCompleted ? Colors.green : taskColor,
            ),
          ),
          child: Icon(
            isCompleted ? Icons.check : Icons.task,
            color: isCompleted ? Colors.white : taskColor,
          ),
        ),
        title: Text(
          task.title ?? '',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            decoration: isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.taskType ?? '',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.repeat,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
                SizedBox(width: 4),
                Text(
                  '${task.repeatitions ?? 0} times',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleTaskAction(value, task),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'toggle',
              child: Row(
                children: [
                  Icon(
                    isCompleted ? Icons.undo : Icons.check,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Text(isCompleted ? 'Mark Incomplete' : 'Mark Complete'),
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
        onTap: () => _toggleTaskCompletion(task),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.task_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          SizedBox(height: 16),
          Text(
            'No tasks yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Start organizing your work by adding your first task',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddTaskForm(),
            icon: Icon(Icons.add),
            label: Text('Add First Task'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Color _parseTaskColor(String? colorString) {
    if (colorString == null || colorString.isEmpty) {
      return Theme.of(context).colorScheme.primary;
    }
    
    try {
      if (colorString.contains("#")) {
        final hex = colorString.split("#").last;
        return Color(int.parse('0xFF$hex'));
      } else if (colorString.length > 6) {
        return Color(int.parse(colorString));
      } else {
        return Color(0xFF6366F1);
      }
    } catch (e) {
      return Theme.of(context).colorScheme.primary;
    }
  }

  void _showAddTaskForm() {
    Navigator.of(context)
        .push(_createRouteToAddTask())
        .then((value) async {
      if (value != null) {
        List<Tasks> taskData = value;
        setState(() {
          isLoading = true;
        });

        await DatabaseHelper.instance.insertTask(taskData.first);
        await _loadTasks();
      }
    });
  }

  void _handleTaskAction(String action, Tasks task) {
    switch (action) {
      case 'toggle':
        _toggleTaskCompletion(task);
        break;
      case 'edit':
        _editTask(task);
        break;
      case 'delete':
        _deleteTask(task);
        break;
    }
  }

  void _toggleTaskCompletion(Tasks task) async {
    final updatedTask = Tasks(
      id: task.id,
      title: task.title,
      isCompleted: task.isCompleted == 1 ? 0 : 1,
      taskType: task.taskType,
      color: task.color,
      createdDate: task.createdDate,
      modifiedDate: DateTime.now(),
      repeatitions: task.repeatitions,
    );
    
    await DatabaseHelper.instance.insertTask(updatedTask);
    if (mounted) {
      await _loadTasks();
    }
  }

  void _editTask(Tasks task) {
    // For now, we'll use the add task form for editing
    _showAddTaskForm();
  }

  void _deleteTask(Tasks task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Task'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteData();
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Filter Tasks'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Show All'),
              leading: Radio<String>(
                value: 'all',
                groupValue: _selectedFilter,
                onChanged: (value) {
                  setState(() {
                    _selectedFilter = value!;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: Text('Show Pending'),
              leading: Radio<String>(
                value: 'pending',
                groupValue: _selectedFilter,
                onChanged: (value) {
                  setState(() {
                    _selectedFilter = value!;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: Text('Show Completed'),
              leading: Radio<String>(
                value: 'completed',
                groupValue: _selectedFilter,
                onChanged: (value) {
                  setState(() {
                    _selectedFilter = value!;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  //When loading from API
  _loadFromApi() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });

    var apiProvider = TasksApiProvider();
    await apiProvider.getAllTasks();

    // wait for 2 seconds to simulate loading of data
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  //Delete Data
  _deleteData() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });

    await DatabaseHelper.instance.deleteAllTasks();

    // wait for 1 second to simulate loading of data
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }

    print('All tasks deleted');
  }

  //To Add Task Page
  Route _createRouteToAddTask() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => AddTask(
        repeatitionController: _repeatitionController,
        taskNameController: _taskNameController,
        onPressed: () => {},
        onChanged: (newValue) {
          setState(() {
            taskType = newValue ?? '';
          });
        },
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}
