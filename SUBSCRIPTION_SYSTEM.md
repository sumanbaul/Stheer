# Subscription System Documentation

## Overview

The Notifoo app includes a comprehensive subscription system that provides different tiers of access to premium features. The system is built using Flutter's `in_app_purchase` plugin and integrates with both Google Play Store and Apple App Store.

## Features

### Subscription Tiers

1. **Free Tier**
   - Basic notification management
   - Up to 50 notifications per day
   - Basic analytics
   - Standard widgets
   - Email support

2. **Pro Tier** (Monthly: $4.99, Yearly: $29.99)
   - Unlimited notifications
   - Advanced analytics & insights
   - Premium widgets & customization
   - Voice commands
   - Calendar sync
   - Priority support
   - Data export
   - Advanced habit tracking
   - Custom themes
   - Ad-free experience

3. **Enterprise Tier** ($99.99/month)
   - All Pro features
   - Team collaboration
   - Advanced reporting
   - API access
   - Dedicated support
   - Custom integrations
   - White-label options

### Trial System

- New users get a 7-day free trial of all Pro features
- No credit card required to start trial
- Trial automatically converts to free tier when expired

## Implementation Details

### Core Components

1. **SubscriptionService** (`lib/src/services/subscription_service.dart`)
   - Manages subscription state and purchases
   - Handles trial eligibility and expiration
   - Integrates with in-app purchase system
   - Provides feature access control

2. **Subscription Models** (`lib/src/model/subscription_model.dart`)
   - Defines subscription tiers and statuses
   - Manages feature permissions
   - Handles subscription data

3. **Feature Gates** (`lib/src/widgets/feature_gate.dart`)
   - Controls access to premium features
   - Shows upgrade prompts for locked features
   - Provides easy feature checking

4. **Subscription UI** (`lib/src/pages/subscription_page.dart`)
   - Displays subscription plans
   - Handles purchase flow
   - Shows current subscription status

### Key Methods

#### SubscriptionService

```dart
// Check if user has access to a specific feature
bool hasFeature(String feature)

// Get current subscription status
UserSubscription? get currentSubscription

// Purchase a subscription
Future<bool> purchaseSubscription(ProductDetails product)

// Restore previous purchases
Future<void> restorePurchases()

// Cancel subscription
Future<void> cancelSubscription()

// Check trial status
bool get isTrialActive
int get trialDaysRemaining
```

#### Feature Gates

```dart
// Basic feature gate
FeatureGate(
  feature: 'voice_commands',
  child: VoiceCommandsWidget(),
  fallback: UpgradePrompt(),
)

// Feature gate with custom upgrade action
FeatureGate(
  feature: 'advanced_analytics',
  child: AdvancedAnalyticsWidget(),
  onUpgradePressed: () => navigateToSubscription(),
)

// Feature gate builder
FeatureGateBuilder(
  feature: 'custom_themes',
  builder: (context, hasAccess) => hasAccess 
    ? CustomThemesWidget() 
    : LockedFeatureWidget(),
)
```

## Usage Examples

### 1. Protecting Premium Features

```dart
class PremiumFeatureWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FeatureGate(
      feature: 'advanced_analytics',
      child: AdvancedAnalyticsChart(),
      fallback: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(Icons.lock, size: 48),
            Text('Upgrade to Pro to unlock this feature'),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/subscription'),
              child: Text('Upgrade Now'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 2. Checking Feature Access in Code

```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Using extension method
    if (context.hasFeature('voice_commands')) {
      return VoiceCommandsWidget();
    }
    
    // Using provider directly
    return Consumer<SubscriptionService>(
      builder: (context, service, child) {
        if (service.hasFeature('voice_commands')) {
          return VoiceCommandsWidget();
        }
        return UpgradePrompt();
      },
    );
  }
}
```

### 3. Subscription Status Display

```dart
class SubscriptionStatusWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SubscriptionService>(
      builder: (context, service, child) {
        final subscription = service.currentSubscription;
        
        if (subscription?.isTrial == true) {
          return TrialBanner(daysRemaining: service.trialDaysRemaining);
        }
        
        if (subscription?.isPro == true) {
          return ProUserBanner();
        }
        
        return FreeUserBanner();
      },
    );
  }
}
```

## Configuration

### Store Configuration

1. **Google Play Store**
   - Add products to Google Play Console
   - Configure subscription products with IDs: `pro_monthly`, `pro_yearly`, `enterprise`
   - Set up billing and pricing

2. **Apple App Store**
   - Add products to App Store Connect
   - Use same product IDs for consistency
   - Configure subscription groups and pricing

### Dependencies

The following dependencies are required:

```yaml
dependencies:
  in_app_purchase: ^3.1.11
  in_app_purchase_android: ^0.3.6+1
  in_app_purchase_storekit: ^0.3.6+1
  shared_preferences: ^2.2.2
  provider: ^6.0.2
```

## Testing

### Development Testing

1. **Android Testing**
   - Use test accounts in Google Play Console
   - Test with test products
   - Verify purchase flow and restoration

2. **iOS Testing**
   - Use sandbox accounts in App Store Connect
   - Test with sandbox products
   - Verify subscription management

### Test Scenarios

- [ ] New user trial activation
- [ ] Trial expiration handling
- [ ] Subscription purchase flow
- [ ] Purchase restoration
- [ ] Subscription cancellation
- [ ] Feature access control
- [ ] Upgrade/downgrade flows

## Security Considerations

### Purchase Verification

- Implement server-side receipt validation for production
- Verify purchase signatures and tokens
- Handle subscription status updates securely

### Data Protection

- Store sensitive subscription data securely
- Implement proper user authentication
- Protect against unauthorized access

## Troubleshooting

### Common Issues

1. **Products Not Loading**
   - Check store configuration
   - Verify product IDs match
   - Ensure store availability

2. **Purchase Failures**
   - Check network connectivity
   - Verify store account status
   - Review error messages

3. **Feature Access Issues**
   - Verify subscription status
   - Check feature permissions
   - Clear app data if needed

### Debug Information

Enable debug logging in the subscription service:

```dart
// Add to SubscriptionService constructor
if (kDebugMode) {
  print('Subscription service initialized');
  print('Current subscription: $_currentSubscription');
}
```

## Future Enhancements

### Planned Features

1. **Family Sharing**
   - Support for family subscription plans
   - Shared feature access across devices

2. **Promotional Offers**
   - Discount codes and promotions
   - Seasonal pricing

3. **Usage Analytics**
   - Track feature usage
   - Subscription conversion metrics

4. **Server-Side Management**
   - Web dashboard for subscription management
   - Advanced analytics and reporting

## Support

For technical support or questions about the subscription system:

1. Check the demo page (`/demo-features`) for examples
2. Review the subscription service implementation
3. Test with the provided feature gates
4. Consult the in-app purchase plugin documentation

## License

This subscription system is part of the Notifoo app and follows the same licensing terms.
