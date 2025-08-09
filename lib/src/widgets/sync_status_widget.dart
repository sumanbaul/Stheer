import 'package:flutter/material.dart';
import 'package:notifoo/src/services/firebase_service.dart';

class SyncStatusWidget extends StatefulWidget {
  final bool showDetails;

  const SyncStatusWidget({
    Key? key,
    this.showDetails = false,
  }) : super(key: key);

  @override
  _SyncStatusWidgetState createState() => _SyncStatusWidgetState();
}

class _SyncStatusWidgetState extends State<SyncStatusWidget> {
  bool _isSyncing = false;
  String _lastSyncTime = 'Never';
  String _syncStatus = 'Offline';

  @override
  void initState() {
    super.initState();
    _checkSyncStatus();
  }

  Future<void> _checkSyncStatus() async {
    // This is a placeholder implementation
    // In a real app, you would check actual sync status
    setState(() {
      _syncStatus = 'Online';
      _lastSyncTime = 'Just now';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _syncStatus == 'Online' ? Icons.cloud_done : Icons.cloud_off,
                  color: _syncStatus == 'Online' 
                      ? Colors.green 
                      : Colors.orange,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  'Sync Status',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _syncStatus == 'Online' 
                        ? Colors.green.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _syncStatus,
                    style: TextStyle(
                      color: _syncStatus == 'Online' 
                          ? Colors.green 
                          : Colors.orange,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            if (widget.showDetails) ...[
              SizedBox(height: 12),
              Text(
                'Last sync: $_lastSyncTime',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              SizedBox(height: 8),
              LinearProgressIndicator(
                value: _isSyncing ? null : 1.0,
                backgroundColor: Colors.grey.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(
                  _syncStatus == 'Online' ? Colors.green : Colors.orange,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 
