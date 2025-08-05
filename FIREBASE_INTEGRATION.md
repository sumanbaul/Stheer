# Firebase Integration Documentation

## Overview

Notifoo implements an **offline-first architecture** with Firebase Cloud Firestore integration. This ensures that users can continue using the app even when offline, with automatic synchronization when connectivity is restored.

## Architecture

### Offline-First Design

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Local SQLite  │◄──►│  Firebase Sync  │◄──►│  Cloud Firestore│
│   (Primary DB)  │    │   Service       │    │   (Backup)      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### Key Features

- **Local-First**: All data is stored locally in SQLite
- **Offline Support**: App works completely offline
- **Automatic Sync**: Background synchronization when online
- **Conflict Resolution**: Smart conflict detection and resolution
- **Real-time Status**: Live sync status indicators

## Components

### 1. FirebaseService (`lib/src/services/firebase_service.dart`)

**Main sync orchestrator** that handles:
- Connectivity monitoring
- Periodic sync (every 30 seconds)
- Conflict detection and resolution
- Data upload/download between local and cloud

#### Key Methods:

```dart
// Initialize the service
await FirebaseService().initialize();

// Manual sync trigger
await FirebaseService().manualSync();

// Check sync status
bool isOnline = FirebaseService().isOnline;
bool isSyncing = FirebaseService().isSyncing;
```

#### Streams:
- `syncStatusStream`: Real-time online/offline status
- `syncMessageStream`: Sync progress messages

### 2. FirebaseProvider (`lib/src/helper/provider/firebase_provider.dart`)

**State management** for Firebase sync status across the app.

#### Usage:
```dart
// Access in widgets
final firebaseProvider = Provider.of<FirebaseProvider>(context);
bool isOnline = firebaseProvider.isOnline;
String status = firebaseProvider.getSyncStatusText();
```

### 3. SyncStatusWidget (`lib/src/widgets/sync_status_widget.dart`)

**UI component** that displays sync status and allows manual sync.

#### Features:
- Compact status indicator
- Detailed sync information
- Manual sync button
- Real-time status updates

## Data Flow

### 1. Local Operations
```
User Action → Local SQLite → UI Update
```

### 2. Sync Process
```
Local Changes → Upload to Cloud → Download Cloud Changes → Merge → Update Local
```

### 3. Conflict Resolution
```
Detect Conflicts → Compare Timestamps → Local Wins (Configurable) → Resolve
```

## Database Schema

### Cloud Firestore Structure

```
users/
  {userId}/
    tasks/
      {taskId}/
        title: string
        isCompleted: number
        taskType: string
        color: string
        createdDate: timestamp
        modifiedDate: timestamp
        repeatitions: number
        lastSync: timestamp
    
    habits/
      {habitId}/
        habitTitle: string
        habitType: string
        isCompleted: number
        color: string
        lastSync: timestamp
```

### Local SQLite Structure

```sql
-- Tasks table
CREATE TABLE Tasks(
  id INTEGER PRIMARY KEY,
  title TEXT,
  isCompleted INTEGER,
  taskType TEXT,
  color TEXT,
  createdDate TEXT,
  modifiedDate TEXT,
  repeatitions INTEGER
);

-- Habits table
CREATE TABLE tblhabits (
  id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
  habitTitle TEXT,
  isCompleted INTEGER,
  habitType TEXT,
  color TEXT,
  createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
```

## Sync Logic

### 1. Connectivity Check
```dart
Future<void> _checkConnectivity() async {
  try {
    await _firestore.collection('test').doc('test').get();
    _isOnline = true;
  } catch (e) {
    _isOnline = false;
  }
}
```

### 2. Periodic Sync
```dart
Timer.periodic(Duration(seconds: 30), (timer) {
  if (_isOnline && _auth.currentUser != null) {
    syncData();
  }
});
```

### 3. Conflict Detection
```dart
bool _hasTaskConflict(Tasks local, Tasks cloud) {
  return local.modifiedDate != cloud.modifiedDate ||
         local.isCompleted != cloud.isCompleted ||
         local.title != cloud.title;
}
```

### 4. Data Upload
```dart
Future<void> _uploadTaskToCloud(Tasks task, String userId) async {
  final taskData = {
    'title': task.title,
    'isCompleted': task.isCompleted,
    'taskType': task.taskType,
    'color': task.color,
    'createdDate': task.createdDate?.toIso8601String(),
    'modifiedDate': task.modifiedDate?.toIso8601String(),
    'repeatitions': task.repeatitions,
    'lastSync': FieldValue.serverTimestamp(),
  };

  await _firestore
      .collection('users')
      .doc(userId)
      .collection('tasks')
      .doc(task.id.toString())
      .set(taskData, SetOptions(merge: true));
}
```

## Error Handling

### 1. Network Errors
- Graceful fallback to offline mode
- Automatic retry when connectivity restored
- User notification of sync status

### 2. Authentication Errors
- Continue in offline mode
- Prompt user to sign in when online
- Preserve local data

### 3. Data Conflicts
- Local-first resolution (configurable)
- Logging of conflicts for analysis
- Option for manual conflict resolution

## Usage Examples

### 1. Adding a Task (Offline)
```dart
// Task is saved locally immediately
await DatabaseHelper.instance.insertTask(newTask);

// Will sync to cloud when online
// No user action required
```

### 2. Manual Sync
```dart
// Trigger manual sync
await FirebaseService().manualSync();

// Or through provider
await Provider.of<FirebaseProvider>(context, listen: false).manualSync();
```

### 3. Check Sync Status
```dart
// In widget
final firebaseProvider = Provider.of<FirebaseProvider>(context);
if (firebaseProvider.isOnline) {
  // Show online indicator
} else {
  // Show offline indicator
}
```

## Configuration

### 1. Firebase Setup
```dart
// In main.dart
await Firebase.initializeApp(
  options: const FirebaseOptions(
    apiKey: "your-api-key",
    authDomain: "your-project.firebaseapp.com",
    projectId: "your-project",
    storageBucket: "your-project.appspot.com",
    messagingSenderId: "your-sender-id",
    appId: "your-app-id",
  ),
);
```

### 2. Sync Intervals
```dart
// In FirebaseService
Timer.periodic(Duration(seconds: 30), (timer) {
  // Adjust interval as needed
});
```

### 3. Conflict Resolution
```dart
// In FirebaseService
Future<void> _resolveTaskConflict(TaskConflict conflict, String userId) async {
  // Currently: Local wins
  // Can be customized for different strategies
  await _uploadTaskToCloud(conflict.local, userId);
}
```

## Security Rules

### Firestore Security Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Testing

### 1. Offline Testing
1. Enable airplane mode
2. Add/edit tasks and habits
3. Verify data is saved locally
4. Disable airplane mode
5. Verify sync occurs automatically

### 2. Conflict Testing
1. Make changes on multiple devices
2. Ensure conflicts are resolved
3. Verify data consistency

### 3. Performance Testing
1. Large dataset sync
2. Network interruption handling
3. Memory usage monitoring

## Troubleshooting

### Common Issues

1. **Sync Not Working**
   - Check Firebase configuration
   - Verify user authentication
   - Check network connectivity

2. **Data Conflicts**
   - Review conflict resolution logic
   - Check timestamp accuracy
   - Verify data integrity

3. **Performance Issues**
   - Optimize sync frequency
   - Implement pagination for large datasets
   - Add data compression

### Debug Logging
```dart
// Enable debug logging
print('FirebaseService: Online status confirmed');
print('FirebaseService: Offline - $e');
print('Task sync error: $e');
print('Upload task error: $e');
```

## Future Enhancements

### 1. Advanced Conflict Resolution
- Merge strategies for different data types
- User choice in conflict resolution
- Conflict history tracking

### 2. Performance Optimizations
- Incremental sync
- Data compression
- Background sync optimization

### 3. Additional Features
- Multi-device sync
- Data export/import
- Sync analytics
- Custom sync rules

## Dependencies

```yaml
dependencies:
  cloud_firestore: ^4.8.4
  firebase_storage: ^11.2.6
  firebase_core: ^2.8.0
  firebase_auth: ^4.2.6
```

## Best Practices

1. **Always test offline functionality**
2. **Handle sync errors gracefully**
3. **Provide clear user feedback**
4. **Monitor sync performance**
5. **Implement proper error logging**
6. **Use appropriate security rules**
7. **Test with real network conditions**

---

*This documentation covers the complete Firebase integration implementation for Notifoo's offline-first architecture.* 