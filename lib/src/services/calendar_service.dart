import 'dart:io';
import 'package:flutter/material.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:notifoo/src/helper/DatabaseHelper.dart';
import 'package:notifoo/src/model/tasks.dart';
import 'package:notifoo/src/model/habits_model.dart';

class CalendarService {
  static final CalendarService _instance = CalendarService._internal();
  factory CalendarService() => _instance;
  CalendarService._internal();

  DeviceCalendarPlugin? _deviceCalendarPlugin;
  bool _hasPermissions = false;
  List<Calendar> _calendars = [];
  Calendar? _focusFlukeCalendar;

  /// Initialize calendar service
  Future<bool> initialize() async {
    try {
      _deviceCalendarPlugin = DeviceCalendarPlugin();
      
      // Request permissions
      var permissionsGranted = await _deviceCalendarPlugin!.hasPermissions();
      if (permissionsGranted.isSuccess && !permissionsGranted.data!) {
        permissionsGranted = await _deviceCalendarPlugin!.requestPermissions();
      }
      
      _hasPermissions = permissionsGranted.isSuccess && permissionsGranted.data!;
      
      if (_hasPermissions) {
        await _loadCalendars();
        await _createOrFindFocusFlukeCalendar();
        print('Calendar service initialized successfully');
        return true;
      } else {
        print('Calendar permissions not granted');
        return false;
      }
    } catch (e) {
      print('Failed to initialize calendar service: $e');
      return false;
    }
  }

  /// Load available calendars
  Future<void> _loadCalendars() async {
    try {
      final calendarsResult = await _deviceCalendarPlugin!.retrieveCalendars();
      if (calendarsResult.isSuccess) {
        _calendars = calendarsResult.data ?? [];
      }
    } catch (e) {
      print('Failed to load calendars: $e');
    }
  }

  /// Create or find FocusFluke calendar
  Future<void> _createOrFindFocusFlukeCalendar() async {
    try {
      // Look for existing FocusFluke calendar
      _focusFlukeCalendar = _calendars.firstWhere(
        (calendar) => calendar.name == 'FocusFluke',
        orElse: () => Calendar(id: ''),
      );

      // Create calendar if it doesn't exist
      if (_focusFlukeCalendar?.id?.isEmpty ?? true) {
        final calendarResult = await _deviceCalendarPlugin!.createCalendar(
          'FocusFluke',
          calendarColor: Color(0xFF6366F1),
          localAccountName: Platform.isAndroid ? 'FocusFluke' : null,
        );
        
        if (calendarResult.isSuccess) {
          await _loadCalendars(); // Reload to get the new calendar
          _focusFlukeCalendar = _calendars.firstWhere(
            (calendar) => calendar.name == 'FocusFluke',
            orElse: () => Calendar(id: ''),
          );
          print('FocusFluke calendar created successfully');
        }
      }
    } catch (e) {
      print('Failed to create/find FocusFluke calendar: $e');
    }
  }

  /// Sync tasks to calendar
  Future<void> syncTasksToCalendar() async {
    if (!_hasPermissions || _focusFlukeCalendar?.id?.isEmpty != false) return;

    try {
      final tasks = await DatabaseHelper.instance.getAllTasks();
      final pendingTasks = tasks.where((task) => task.isCompleted == 0).toList();

      for (final task in pendingTasks) {
        await _createTaskEvent(task);
      }
      
      print('Tasks synced to calendar successfully');
    } catch (e) {
      print('Failed to sync tasks to calendar: $e');
    }
  }

  /// Create calendar event for task
  Future<void> _createTaskEvent(Tasks task) async {
    try {
      // Schedule task for tomorrow at 9 AM if no specific time
      final tomorrow = DateTime.now().add(Duration(days: 1));
      final startTime = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 9, 0);
      final endTime = startTime.add(Duration(hours: 1));

      final event = Event(
        _focusFlukeCalendar!.id,
        title: '📋 ${task.title}',
        description: 'FocusFluke Task - Type: ${task.taskType}',
        start: TZDateTime.from(startTime, local),
        end: TZDateTime.from(endTime, local),
        allDay: false,
        reminders: [
          Reminder(minutes: 15), // 15 minutes before
          Reminder(minutes: 60), // 1 hour before
        ],
      );

      final result = await _deviceCalendarPlugin!.createOrUpdateEvent(event);
      if (result?.isSuccess == true) {
        print('Task event created: ${task.title}');
      }
    } catch (e) {
      print('Failed to create task event: $e');
    }
  }

  /// Create calendar events for habits
  Future<void> syncHabitsToCalendar() async {
    if (!_hasPermissions || _focusFlukeCalendar?.id?.isEmpty != false) return;

    try {
      final habits = await DatabaseHelper.instance.getHabits();
      final pendingHabits = habits.where((habit) => habit.isCompleted == 0).toList();

      for (final habit in pendingHabits) {
        await _createHabitEvent(habit);
      }
      
      print('Habits synced to calendar successfully');
    } catch (e) {
      print('Failed to sync habits to calendar: $e');
    }
  }

  /// Create calendar event for habit
  Future<void> _createHabitEvent(HabitsModel habit) async {
    try {
      // Schedule habit reminder for today at 8 AM
      final today = DateTime.now();
      final startTime = DateTime(today.year, today.month, today.day, 8, 0);
      final endTime = startTime.add(Duration(minutes: 30));

      // Skip if time has already passed
      if (startTime.isBefore(DateTime.now())) {
        return;
      }

      final event = Event(
        _focusFlukeCalendar!.id,
        title: '🎯 ${habit.habitTitle}',
        description: 'FocusFluke Habit - Type: ${habit.habitType}',
        start: TZDateTime.from(startTime, local),
        end: TZDateTime.from(endTime, local),
        allDay: false,
        reminders: [
          Reminder(minutes: 5), // 5 minutes before
        ],
      );

      final result = await _deviceCalendarPlugin!.createOrUpdateEvent(event);
      if (result?.isSuccess == true) {
        print('Habit event created: ${habit.habitTitle}');
      }
    } catch (e) {
      print('Failed to create habit event: $e');
    }
  }

  /// Create focus session events
  Future<void> scheduleFocusSession(DateTime startTime, int durationMinutes, String? taskName) async {
    if (!_hasPermissions || _focusFlukeCalendar?.id?.isEmpty != false) return;

    try {
      final endTime = startTime.add(Duration(minutes: durationMinutes));
      
      final event = Event(
        _focusFlukeCalendar!.id,
        title: '🍅 Focus Session${taskName != null ? ': $taskName' : ''}',
        description: 'FocusFluke Pomodoro Session - $durationMinutes minutes',
        start: TZDateTime.from(startTime, local),
        end: TZDateTime.from(endTime, local),
        allDay: false,
        reminders: [
          Reminder(minutes: 5), // 5 minutes before
        ],
      );

      final result = await _deviceCalendarPlugin!.createOrUpdateEvent(event);
      if (result?.isSuccess == true) {
        print('Focus session scheduled: ${startTime.toString()}');
      }
    } catch (e) {
      print('Failed to schedule focus session: $e');
    }
  }

  /// Get calendar events for today
  Future<List<Event>> getTodayEvents() async {
    if (!_hasPermissions) return [];

    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(Duration(days: 1));

      final eventsResult = await _deviceCalendarPlugin!.retrieveEvents(
        _focusFlukeCalendar!.id!,
        RetrieveEventsParams(
          startDate: startOfDay,
          endDate: endOfDay,
        ),
      );

      return eventsResult.data ?? [];
    } catch (e) {
      print('Failed to get today events: $e');
      return [];
    }
  }

  /// Get upcoming events for the week
  Future<List<Event>> getUpcomingEvents() async {
    if (!_hasPermissions) return [];

    try {
      final today = DateTime.now();
      final weekFromNow = today.add(Duration(days: 7));

      final eventsResult = await _deviceCalendarPlugin!.retrieveEvents(
        _focusFlukeCalendar!.id!,
        RetrieveEventsParams(
          startDate: today,
          endDate: weekFromNow,
        ),
      );

      return eventsResult.data ?? [];
    } catch (e) {
      print('Failed to get upcoming events: $e');
      return [];
    }
  }

  /// Block time for focus sessions
  Future<void> blockFocusTime(DateTime startTime, int sessionCount, int sessionLength, int breakLength) async {
    if (!_hasPermissions || _focusFlukeCalendar?.id?.isEmpty != false) return;

    try {
      DateTime currentTime = startTime;
      
      for (int i = 0; i < sessionCount; i++) {
        // Schedule focus session
        await scheduleFocusSession(
          currentTime,
          sessionLength,
          'Session ${i + 1} of $sessionCount',
        );
        
        currentTime = currentTime.add(Duration(minutes: sessionLength));
        
        // Add break time (except after last session)
        if (i < sessionCount - 1) {
          final breakEvent = Event(
            _focusFlukeCalendar!.id,
            title: '☕ Break Time',
            description: 'FocusFluke Break - $breakLength minutes',
            start: TZDateTime.from(currentTime, local),
            end: TZDateTime.from(currentTime.add(Duration(minutes: breakLength)), local),
            allDay: false,
          );

          await _deviceCalendarPlugin!.createOrUpdateEvent(breakEvent);
          currentTime = currentTime.add(Duration(minutes: breakLength));
        }
      }
      
      print('Focus time blocked: $sessionCount sessions starting at ${startTime.toString()}');
    } catch (e) {
      print('Failed to block focus time: $e');
    }
  }

  /// Check for calendar conflicts
  Future<bool> hasConflicts(DateTime startTime, DateTime endTime) async {
    if (!_hasPermissions) return false;

    try {
      final eventsResult = await _deviceCalendarPlugin!.retrieveEvents(
        _focusFlukeCalendar!.id!,
        RetrieveEventsParams(
          startDate: startTime,
          endDate: endTime,
        ),
      );

      final events = eventsResult.data ?? [];
      return events.isNotEmpty;
    } catch (e) {
      print('Failed to check conflicts: $e');
      return false;
    }
  }

  /// Get calendar integration summary
  Future<Map<String, dynamic>> getIntegrationSummary() async {
    try {
      final todayEvents = await getTodayEvents();
      final upcomingEvents = await getUpcomingEvents();
      
      return {
        'permissions_granted': _hasPermissions,
        'calendar_name': _focusFlukeCalendar?.name ?? 'Not created',
        'events_today': todayEvents.length,
        'events_upcoming': upcomingEvents.length,
        'available_calendars': _calendars.length,
        'last_sync': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {
        'permissions_granted': false,
        'error': e.toString(),
      };
    }
  }

  /// Getters
  bool get hasPermissions => _hasPermissions;
  List<Calendar> get calendars => _calendars;
  Calendar? get focusFlukeCalendar => _focusFlukeCalendar;
}