import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/subscription_service.dart';
import '../model/subscription_model.dart';

class FeatureGate extends StatelessWidget {
  final String feature;
  final Widget child;
  final Widget? fallback;
  final bool showUpgradePrompt;
  final VoidCallback? onUpgradePressed;

  const FeatureGate({
    Key? key,
    required this.feature,
    required this.child,
    this.fallback,
    this.showUpgradePrompt = true,
    this.onUpgradePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SubscriptionService>(
      builder: (context, subscriptionService, _) {
        final hasAccess = subscriptionService.hasFeature(feature);
        
        if (hasAccess) {
          return child;
        }
        
        if (fallback != null) {
          return fallback!;
        }
        
        if (showUpgradePrompt) {
          return _buildUpgradePrompt(context, subscriptionService);
        }
        
        return SizedBox.shrink();
      },
    );
  }

  Widget _buildUpgradePrompt(BuildContext context, SubscriptionService subscriptionService) {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.lock,
            size: 48,
            color: Theme.of(context).colorScheme.primary,
          ),
          SizedBox(height: 16),
          Text(
            'Premium Feature',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'This feature requires a Pro subscription',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8),
            ),
          ),
          SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onUpgradePressed ?? () {
                Navigator.of(context).pushNamed('/subscription');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Upgrade to Pro',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          SizedBox(height: 12),
          TextButton(
            onPressed: () {
              // Show trial info or dismiss
            },
            child: Text(
              'Start Free Trial',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FeatureGateBuilder extends StatelessWidget {
  final String feature;
  final Widget Function(BuildContext context, bool hasAccess) builder;
  final Widget? fallback;

  const FeatureGateBuilder({
    Key? key,
    required this.feature,
    required this.builder,
    this.fallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SubscriptionService>(
      builder: (context, subscriptionService, _) {
        final hasAccess = subscriptionService.hasFeature(feature);
        
        if (hasAccess) {
          return builder(context, true);
        }
        
        if (fallback != null) {
          return fallback!;
        }
        
        return builder(context, false);
      },
    );
  }
}

class SubscriptionStatusWidget extends StatelessWidget {
  final Widget Function(BuildContext context, SubscriptionTier tier) builder;
  final Widget? fallback;

  const SubscriptionStatusWidget({
    Key? key,
    required this.builder,
    this.fallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SubscriptionService>(
      builder: (context, subscriptionService, _) {
        final tier = subscriptionService.currentSubscription?.tier ?? SubscriptionTier.free;
        
        if (subscriptionService.isSubscriptionActive) {
          return builder(context, tier);
        }
        
        if (fallback != null) {
          return fallback!;
        }
        
        return builder(context, SubscriptionTier.free);
      },
    );
  }
}

// Utility extension for easy feature checking
extension FeatureGateExtension on BuildContext {
  bool hasFeature(String feature) {
    return read<SubscriptionService>().hasFeature(feature);
  }
  
  bool get isProUser => read<SubscriptionService>().isProUser;
  bool get isTrialActive => read<SubscriptionService>().isTrialActive;
  bool get isSubscriptionActive => read<SubscriptionService>().isSubscriptionActive;
}

// Subscription onboarding widget for new users
class SubscriptionOnboardingWidget extends StatelessWidget {
  final VoidCallback? onGetStarted;
  final VoidCallback? onSkip;

  const SubscriptionOnboardingWidget({
    Key? key,
    this.onGetStarted,
    this.onSkip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
            Theme.of(context).colorScheme.secondary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.rocket_launch,
              color: Theme.of(context).colorScheme.primary,
              size: 32,
            ),
          ),
          
          SizedBox(height: 20),
          
          Text(
            'Unlock Your Full Potential',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: 12),
          
          Text(
            'Start your 7-day free trial and experience all premium features',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: 24),
          
          // Features preview
          _buildFeatureRow(context, 'Unlimited notifications', Icons.notifications),
          _buildFeatureRow(context, 'Advanced analytics', Icons.analytics),
          _buildFeatureRow(context, 'Voice commands', Icons.mic),
          _buildFeatureRow(context, 'Premium widgets', Icons.widgets),
          
          SizedBox(height: 24),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onSkip,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Maybe Later',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: onGetStarted ?? () => Navigator.pushNamed(context, '/subscription'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Start Free Trial',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16),
          
          Text(
            'No credit card required • Cancel anytime',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(BuildContext context, String feature, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 20,
          ),
          SizedBox(width: 12),
          Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 18,
          ),
          SizedBox(width: 8),
          Text(
            feature,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}

// Premium feature showcase widget
class PremiumFeatureShowcase extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final String feature;
  final VoidCallback? onUpgrade;

  const PremiumFeatureShowcase({
    Key? key,
    required this.title,
    required this.description,
    required this.icon,
    required this.feature,
    this.onUpgrade,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SubscriptionService>(
      builder: (context, subscriptionService, _) {
        final hasAccess = subscriptionService.hasFeature(feature);
        
        if (hasAccess) {
          return Container(
            margin: EdgeInsets.symmetric(vertical: 8),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: Theme.of(context).colorScheme.primary,
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
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 24,
                ),
              ],
            ),
          );
        }
        
        return Container(
          margin: EdgeInsets.symmetric(vertical: 8),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Colors.grey,
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
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onUpgrade ?? () => Navigator.pushNamed(context, '/subscription'),
                icon: Icon(
                  Icons.lock,
                  color: Colors.grey,
                  size: 20,
                ),
                tooltip: 'Upgrade to unlock',
              ),
            ],
          ),
        );
      },
    );
  }
}
