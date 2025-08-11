import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/subscription_service.dart';
import '../../model/subscription_model.dart';

class BannerWidget extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color? backgroundColor;
  final Color? textColor;
  final VoidCallback? onActionPressed;
  final String? actionText;

  const BannerWidget({
    Key? key,
    required this.title,
    required this.message,
    required this.icon,
    this.backgroundColor,
    this.textColor,
    this.onActionPressed,
    this.actionText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (backgroundColor ?? Theme.of(context).colorScheme.primaryContainer).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: textColor ?? Theme.of(context).colorScheme.onPrimaryContainer,
            size: 24,
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: textColor ?? Theme.of(context).colorScheme.onPrimaryContainer,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    color: (textColor ?? Theme.of(context).colorScheme.onPrimaryContainer).withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          if (onActionPressed != null && actionText != null)
            TextButton(
              onPressed: onActionPressed,
              child: Text(
                actionText!,
                style: TextStyle(
                  color: textColor ?? Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class SubscriptionUpgradeBanner extends StatelessWidget {
  final String feature;
  final String? customMessage;
  final VoidCallback? onUpgradePressed;

  const SubscriptionUpgradeBanner({
    Key? key,
    required this.feature,
    this.customMessage,
    this.onUpgradePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SubscriptionService>(
      builder: (context, subscriptionService, _) {
        // Don't show banner if user already has access
        if (subscriptionService.hasFeature(feature)) {
          return SizedBox.shrink();
        }

        final isTrial = subscriptionService.isTrialActive;
        final trialDaysRemaining = subscriptionService.trialDaysRemaining;

        return Container(
          margin: EdgeInsets.symmetric(vertical: 8),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary.withOpacity(0.1),
                Theme.of(context).colorScheme.secondary.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.lock,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Premium Feature Locked',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          customMessage ?? 'Upgrade to Pro to unlock $feature and many more premium features',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              if (isTrial) ...[
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.access_time,
                        color: Colors.blue,
                        size: 16,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Trial ends in $trialDaysRemaining days',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              SizedBox(height: 20),
              
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onUpgradePressed ?? () => Navigator.pushNamed(context, '/subscription'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        isTrial ? 'Upgrade Now' : 'Get Pro',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: () => Navigator.pushNamed(context, '/demo-features'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Learn More',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class TrialExpiryBanner extends StatelessWidget {
  const TrialExpiryBanner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SubscriptionService>(
      builder: (context, subscriptionService, _) {
        if (!subscriptionService.isTrialActive) return SizedBox.shrink();
        
        final trialDaysRemaining = subscriptionService.trialDaysRemaining;
        final isExpiringSoon = trialDaysRemaining <= 3;
        
        if (!isExpiringSoon) return SizedBox.shrink();
        
        return Container(
          margin: EdgeInsets.symmetric(vertical: 8),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.orange.withOpacity(0.1),
                Colors.red.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.orange.withOpacity(0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.warning,
                      color: Colors.orange,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Trial Ending Soon!',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.orange.shade800,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          trialDaysRemaining == 1 
                            ? 'Your free trial ends tomorrow. Upgrade now to keep all premium features!'
                            : 'Your free trial ends in $trialDaysRemaining days. Don\'t lose access to premium features!',
                          style: TextStyle(
                            color: Colors.orange.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 20),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/subscription'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Upgrade to Pro',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
