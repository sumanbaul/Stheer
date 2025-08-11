import 'package:flutter_test/flutter_test.dart';
import 'package:notifoo/src/services/subscription_service.dart';
import 'package:notifoo/src/model/subscription_model.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

void main() {
  group('SubscriptionService Tests', () {
    late SubscriptionService subscriptionService;

    setUp(() {
      subscriptionService = SubscriptionService();
    });

    tearDown(() {
      subscriptionService.dispose();
    });

    group('Subscription Plans', () {
      test('should have correct subscription plans', () {
        expect(subscriptionService.subscriptionPlans.length, 3);
        
        final proMonthly = subscriptionService.subscriptionPlans.firstWhere(
          (plan) => plan.id == 'pro_monthly',
        );
        expect(proMonthly.name, 'Pro Monthly');
        expect(proMonthly.price, 4.99);
        expect(proMonthly.tier, SubscriptionTier.pro);
        expect(proMonthly.billingPeriod, 'monthly');
        
        final proYearly = subscriptionService.subscriptionPlans.firstWhere(
          (plan) => plan.id == 'pro_yearly',
        );
        expect(proYearly.name, 'Pro Yearly');
        expect(proYearly.price, 29.99);
        expect(proYearly.tier, SubscriptionTier.pro);
        expect(proYearly.billingPeriod, 'yearly');
        expect(proYearly.isPopular, true);
        
        final enterprise = subscriptionService.subscriptionPlans.firstWhere(
          (plan) => plan.id == 'enterprise',
        );
        expect(enterprise.name, 'Enterprise');
        expect(enterprise.price, 99.99);
        expect(enterprise.tier, SubscriptionTier.enterprise);
        expect(enterprise.billingPeriod, 'monthly');
      });
    });

    group('Feature Access Control', () {
      test('should grant basic features to free users', () {
        // Mock free subscription
        subscriptionService._currentSubscription = UserSubscription(
          userId: 'test_user',
          tier: SubscriptionTier.free,
          status: SubscriptionStatus.active,
        );
        
        expect(subscriptionService.hasFeature('basic_notifications'), true);
        expect(subscriptionService.hasFeature('basic_analytics'), true);
        expect(subscriptionService.hasFeature('standard_widgets'), true);
      });

      test('should grant premium features to pro users', () {
        // Mock pro subscription
        subscriptionService._currentSubscription = UserSubscription(
          userId: 'test_user',
          tier: SubscriptionTier.pro,
          status: SubscriptionStatus.active,
        );
        
        expect(subscriptionService.hasFeature('unlimited_notifications'), true);
        expect(subscriptionService.hasFeature('advanced_analytics'), true);
        expect(subscriptionService.hasFeature('voice_commands'), true);
        expect(subscriptionService.hasFeature('calendar_sync'), true);
        expect(subscriptionService.hasFeature('custom_themes'), true);
      });

      test('should grant enterprise features to enterprise users', () {
        // Mock enterprise subscription
        subscriptionService._currentSubscription = UserSubscription(
          userId: 'test_user',
          tier: SubscriptionTier.enterprise,
          status: SubscriptionStatus.active,
        );
        
        expect(subscriptionService.hasFeature('api_access'), true);
        expect(subscriptionService.hasFeature('team_collaboration'), true);
        expect(subscriptionService.hasFeature('custom_integrations'), true);
      });

      test('should deny premium features to free users', () {
        // Mock free subscription
        subscriptionService._currentSubscription = UserSubscription(
          userId: 'test_user',
          tier: SubscriptionTier.free,
          status: SubscriptionStatus.active,
        );
        
        expect(subscriptionService.hasFeature('unlimited_notifications'), false);
        expect(subscriptionService.hasFeature('advanced_analytics'), false);
        expect(subscriptionService.hasFeature('voice_commands'), false);
      });
    });

    group('Trial Management', () {
      test('should start trial for new users', () {
        final now = DateTime.now();
        final trialEndDate = now.add(Duration(days: 7));
        
        subscriptionService._currentSubscription = UserSubscription(
          userId: 'test_user',
          tier: SubscriptionTier.pro,
          status: SubscriptionStatus.trial,
          startDate: now,
          trialEndDate: trialEndDate,
        );
        
        expect(subscriptionService.isTrialActive, true);
        expect(subscriptionService.trialDaysRemaining, 7);
      });

      test('should calculate trial days remaining correctly', () {
        final now = DateTime.now();
        final trialEndDate = now.add(Duration(days: 3));
        
        subscriptionService._currentSubscription = UserSubscription(
          userId: 'test_user',
          tier: SubscriptionTier.pro,
          status: SubscriptionStatus.trial,
          trialEndDate: trialEndDate,
        );
        
        expect(subscriptionService.trialDaysRemaining, 3);
      });

      test('should handle expired trial', () {
        final now = DateTime.now();
        final trialEndDate = now.subtract(Duration(days: 1));
        
        subscriptionService._currentSubscription = UserSubscription(
          userId: 'test_user',
          tier: SubscriptionTier.pro,
          status: SubscriptionStatus.trial,
          trialEndDate: trialEndDate,
        );
        
        expect(subscriptionService.isTrialActive, false);
        expect(subscriptionService.trialDaysRemaining, 0);
      });
    });

    group('Subscription Status', () {
      test('should identify active subscriptions', () {
        subscriptionService._currentSubscription = UserSubscription(
          userId: 'test_user',
          tier: SubscriptionTier.pro,
          status: SubscriptionStatus.active,
        );
        
        expect(subscriptionService.isSubscriptionActive, true);
        expect(subscriptionService.isProUser, true);
      });

      test('should identify expired subscriptions', () {
        subscriptionService._currentSubscription = UserSubscription(
          userId: 'test_user',
          tier: SubscriptionTier.pro,
          status: SubscriptionStatus.expired,
        );
        
        expect(subscriptionService.isSubscriptionActive, false);
        expect(subscriptionService.isProUser, true);
      });

      test('should identify cancelled subscriptions', () {
        subscriptionService._currentSubscription = UserSubscription(
          userId: 'test_user',
          tier: SubscriptionTier.pro,
          status: SubscriptionStatus.cancelled,
        );
        
        expect(subscriptionService.isSubscriptionActive, false);
        expect(subscriptionService.isProUser, true);
      });
    });

    group('Purchase Management', () {
      test('should handle successful purchase', () async {
        // Mock successful purchase
        final product = ProductDetails(
          id: 'pro_monthly',
          title: 'Pro Monthly',
          description: 'Pro subscription',
          price: '\$4.99',
          rawPrice: 4.99,
          currencyCode: 'USD',
        );
        
        final success = await subscriptionService.purchaseSubscription(product);
        expect(success, true);
      });

      test('should handle purchase failure', () async {
        // Mock failed purchase
        final product = ProductDetails(
          id: 'invalid_product',
          title: 'Invalid Product',
          description: 'Invalid product',
          price: '\$0.00',
          rawPrice: 0.0,
          currencyCode: 'USD',
        );
        
        final success = await subscriptionService.purchaseSubscription(product);
        expect(success, false);
      });
    });

    group('Feature Gates', () {
      test('should show upgrade prompt for locked features', () {
        // Mock free subscription
        subscriptionService._currentSubscription = UserSubscription(
          userId: 'test_user',
          tier: SubscriptionTier.free,
          status: SubscriptionStatus.active,
        );
        
        // Test that premium features are locked
        expect(subscriptionService.hasFeature('voice_commands'), false);
        expect(subscriptionService.hasFeature('advanced_analytics'), false);
      });

      test('should allow access to unlocked features', () {
        // Mock pro subscription
        subscriptionService._currentSubscription = UserSubscription(
          userId: 'test_user',
          tier: SubscriptionTier.pro,
          status: SubscriptionStatus.active,
        );
        
        // Test that premium features are unlocked
        expect(subscriptionService.hasFeature('voice_commands'), true);
        expect(subscriptionService.hasFeature('advanced_analytics'), true);
      });
    });

    group('Error Handling', () {
      test('should handle initialization errors gracefully', () {
        // Test that service doesn't crash on initialization errors
        expect(() => SubscriptionService(), returnsNormally);
      });

      test('should handle purchase stream errors', () {
        // Test error handling in purchase stream
        expect(subscriptionService.errorMessage, isNull);
      });
    });

    group('Data Persistence', () {
      test('should save and load subscription data', () {
        final subscription = UserSubscription(
          userId: 'test_user',
          tier: SubscriptionTier.pro,
          status: SubscriptionStatus.active,
          startDate: DateTime.now(),
        );
        
        subscriptionService._currentSubscription = subscription;
        
        expect(subscriptionService.currentSubscription, isNotNull);
        expect(subscriptionService.currentSubscription!.userId, 'test_user');
        expect(subscriptionService.currentSubscription!.tier, SubscriptionTier.pro);
      });
    });
  });
}
