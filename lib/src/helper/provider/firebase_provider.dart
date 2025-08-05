import 'package:flutter/foundation.dart';
import 'package:notifoo/src/services/firebase_service.dart';

class FirebaseProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  
  bool _isOnline = true;
  bool _isSyncing = false;
  String _syncMessage = '';
  String _lastError = '';

  // Getters
  bool get isOnline => _isOnline;
  bool get isSyncing => _isSyncing;
  String get syncMessage => _syncMessage;
  String get lastError => _lastError;

  FirebaseProvider() {
    _initialize();
  }

  void _initialize() {
    // Listen to sync status changes
    _firebaseService.syncStatusStream.listen((isOnline) {
      _isOnline = isOnline;
      notifyListeners();
    });

    // Listen to sync messages
    _firebaseService.syncMessageStream.listen((message) {
      _syncMessage = message;
      notifyListeners();
    });
  }

  // Manual sync
  Future<void> manualSync() async {
    try {
      _isSyncing = true;
      _lastError = '';
      notifyListeners();

      await _firebaseService.manualSync();
      
      _isSyncing = false;
      notifyListeners();
    } catch (e) {
      _isSyncing = false;
      _lastError = e.toString();
      notifyListeners();
    }
  }

  // Get sync status
  String getSyncStatusText() {
    if (_isSyncing) {
      return 'Syncing...';
    } else if (_isOnline) {
      return 'Online';
    } else {
      return 'Offline';
    }
  }

  // Get status color
  int getStatusColor() {
    if (_isSyncing) {
      return 0xFFFF9800; // Orange
    } else if (_isOnline) {
      return 0xFF4CAF50; // Green
    } else {
      return 0xFFF44336; // Red
    }
  }

  // Check if sync is available
  bool get canSync => _isOnline && !_isSyncing;

  @override
  void dispose() {
    super.dispose();
  }
} 