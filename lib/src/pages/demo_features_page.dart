import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/subscription_service.dart';
import '../widgets/feature_gate.dart';
import '../model/subscription_model.dart';

class DemoFeaturesPage extends StatefulWidget {
  const DemoFeaturesPage({Key? key}) : super(key: key);

  @override
  _DemoFeaturesPageState createState() => _DemoFeaturesPageState();
}

class _DemoFeaturesPageState extends State<DemoFeaturesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text('Subscription Demo'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => Navigator.of(context).pushNamed('/subscription'),
          ),
        ],
      ),
      body: Consumer<SubscriptionService>(
        builder: (context, subscriptionService, child) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Current subscription status
                _buildSubscriptionStatusCard(context, subscriptionService),
                
                SizedBox(height: 30),
                
                // Feature demonstrations
                _buildFeatureDemos(context, subscriptionService),
                
                SizedBox(height: 30),
                
                // Trial information
                if (subscriptionService.isTrialActive)
                  _buildTrialInfo(context, subscriptionService),
                
                SizedBox(height: 30),
                
                // Subscription actions
                _buildSubscriptionActions(context, subscriptionService),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSubscriptionStatusCard(BuildContext context, SubscriptionService subscriptionService) {
    final subscription = subscriptionService.currentSubscription;
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                subscription?.isPro == true ? Icons.star : Icons.person,
                color: Colors.white,
                size: 32,
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subscription?.tier.name.toUpperCase() ?? 'FREE',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      subscription?.status.name.toUpperCase() ?? 'ACTIVE',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          SizedBox(height: 20),
          
          if (subscription?.isTrial == true)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${subscriptionService.trialDaysRemaining} days left in trial',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeatureDemos(BuildContext context, SubscriptionService subscriptionService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Feature Demonstrations',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 20),
        
        // Basic feature (available to all)
        _buildFeatureCard(
          context,
          'Basic Notifications',
          'Manage up to 50 notifications per day',
          Icons.notifications,
          Colors.green,
          true,
        ),
        
        SizedBox(height: 16),
        
        // Pro feature
        FeatureGate(
          feature: 'Unlimited notifications',
          child: _buildFeatureCard(
            context,
            'Unlimited Notifications',
            'No limits on notification management',
            Icons.notifications_active,
            Colors.blue,
            true,
          ),
          fallback: _buildFeatureCard(
            context,
            'Unlimited Notifications',
            'Upgrade to Pro to unlock unlimited notifications',
            Icons.lock,
            Colors.grey,
            false,
          ),
        ),
        
        SizedBox(height: 16),
        
        // Advanced analytics feature
        FeatureGate(
          feature: 'Advanced analytics & insights',
          child: _buildFeatureCard(
            context,
            'Advanced Analytics',
            'Detailed insights and productivity metrics',
            Icons.analytics,
            Colors.purple,
            true,
          ),
          fallback: _buildFeatureCard(
            context,
            'Advanced Analytics',
            'Get Pro to access advanced analytics',
            Icons.lock,
            Colors.grey,
            false,
          ),
        ),
        
        SizedBox(height: 16),
        
        // Voice commands feature
        FeatureGate(
          feature: 'Voice commands',
          child: _buildFeatureCard(
            context,
            'Voice Commands',
            'Control the app with your voice',
            Icons.mic,
            Colors.orange,
            true,
          ),
          fallback: _buildFeatureCard(
            context,
            'Voice Commands',
            'Pro feature - upgrade to unlock',
            Icons.lock,
            Colors.grey,
            false,
          ),
        ),
        
        SizedBox(height: 16),
        
        // Enterprise feature
        FeatureGate(
          feature: 'API access',
          child: _buildFeatureCard(
            context,
            'API Access',
            'Integrate with external services',
            Icons.api,
            Colors.red,
            true,
          ),
          fallback: _buildFeatureCard(
            context,
            'API Access',
            'Enterprise feature - contact sales',
            Icons.lock,
            Colors.grey,
            false,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    bool isAvailable,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isAvailable 
          ? color.withOpacity(0.1)
          : Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAvailable ? color : Colors.grey.withOpacity(0.3),
          width: isAvailable ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isAvailable ? color : Colors.grey,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
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
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isAvailable 
                      ? Theme.of(context).colorScheme.onSurface
                      : Colors.grey,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: isAvailable 
                      ? Theme.of(context).colorScheme.onSurface.withOpacity(0.7)
                      : Colors.grey.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            isAvailable ? Icons.check_circle : Icons.lock,
            color: isAvailable ? Colors.green : Colors.grey,
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildTrialInfo(BuildContext context, SubscriptionService subscriptionService) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.access_time, color: Colors.blue, size: 24),
              SizedBox(width: 12),
              Text(
                'Free Trial Active',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            'You\'re currently enjoying a free trial of all Pro features!',
            style: TextStyle(
              color: Colors.blue.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Trial expires in ${subscriptionService.trialDaysRemaining} days',
            style: TextStyle(
              color: Colors.blue.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pushNamed('/subscription'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Upgrade Now'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionActions(BuildContext context, SubscriptionService subscriptionService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Subscription Actions',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 20),
        
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pushNamed('/subscription'),
                icon: Icon(Icons.upgrade),
                label: Text('Upgrade'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: subscriptionService.isLoading 
                  ? null 
                  : () => subscriptionService.restorePurchases(),
                icon: Icon(Icons.restore),
                label: Text('Restore'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
        
        SizedBox(height: 16),
        
        if (subscriptionService.isSubscriptionActive && !subscriptionService.isTrialActive)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: subscriptionService.isLoading 
                ? null 
                : () => _showCancelDialog(context, subscriptionService),
              icon: Icon(Icons.cancel, color: Colors.red),
              label: Text('Cancel Subscription', style: TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(color: Colors.red),
              ),
            ),
          ),
      ],
    );
  }

  void _showCancelDialog(BuildContext context, SubscriptionService subscriptionService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cancel Subscription'),
        content: Text('Are you sure you want to cancel your subscription? You\'ll lose access to Pro features at the end of your current billing period.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Keep Subscription'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await subscriptionService.cancelSubscription();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Subscription cancelled successfully'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Cancel Subscription'),
          ),
        ],
      ),
    );
  }
}
