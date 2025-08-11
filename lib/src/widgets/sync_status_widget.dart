import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/subscription_service.dart';
import '../model/subscription_model.dart';

class SyncStatusWidget extends StatelessWidget {
  final bool showDetails;
  
  const SyncStatusWidget({Key? key, this.showDetails = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SubscriptionService>(
      builder: (context, subscriptionService, _) {
        return Column(
          children: [
            // Subscription Status Banner
            if (subscriptionService.currentSubscription != null)
              _buildSubscriptionBanner(context, subscriptionService),
            
            // Existing sync status content
            _buildSyncStatus(context),
          ],
        );
      },
    );
  }

  Widget _buildSubscriptionBanner(BuildContext context, SubscriptionService subscriptionService) {
    final subscription = subscriptionService.currentSubscription!;
    final isTrial = subscription.status == SubscriptionStatus.trial;
    final isExpired = subscription.status == SubscriptionStatus.expired;
    
    if (isExpired) return SizedBox.shrink(); // Don't show banner for expired subscriptions
    
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isTrial 
            ? [Colors.blue.withOpacity(0.1), Colors.blue.withOpacity(0.05)]
            : [Theme.of(context).colorScheme.primary.withOpacity(0.1), Theme.of(context).colorScheme.secondary.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isTrial 
            ? Colors.blue.withOpacity(0.3)
            : Theme.of(context).colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isTrial ? Icons.access_time : Icons.star,
            color: isTrial ? Colors.blue : Theme.of(context).colorScheme.primary,
            size: 20,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isTrial ? 'Free Trial Active' : 'Pro Subscription Active',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isTrial ? Colors.blue : Theme.of(context).colorScheme.primary,
                    fontSize: 14,
                  ),
                ),
                if (isTrial && subscription.trialEndDate != null)
                  Text(
                    'Expires in ${_getTrialDaysRemaining(subscription.trialEndDate!)} days',
                    style: TextStyle(
                      color: Colors.blue.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/subscription'),
            child: Text(
              isTrial ? 'Upgrade' : 'Manage',
              style: TextStyle(
                color: isTrial ? Colors.blue : Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncStatus(BuildContext context) {
    // Your existing sync status implementation here
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.sync,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: 20,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'All data synced',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
              ),
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 20,
              ),
            ],
          ),
          if (showDetails) ...[
            SizedBox(height: 8),
            Text(
              'Last sync: ${_getLastSyncTime()}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Next sync: ${_getNextSyncTime()}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  int _getTrialDaysRemaining(DateTime trialEndDate) {
    final now = DateTime.now();
    final difference = trialEndDate.difference(now).inDays;
    return difference > 0 ? difference : 0;
  }

  String _getLastSyncTime() {
    // For now, return a placeholder. You can implement actual sync time logic
    return '2 minutes ago';
  }

  String _getNextSyncTime() {
    // For now, return a placeholder. You can implement actual sync time logic
    return 'in 3 minutes';
  }
} 
