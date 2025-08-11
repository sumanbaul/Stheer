import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/subscription_service.dart';
import '../model/subscription_model.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({Key? key}) : super(key: key);

  @override
  _SubscriptionPageState createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text('Upgrade to Pro'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.read<SubscriptionService>().restorePurchases();
            },
            child: Text('Restore'),
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
                // Header
                _buildHeader(context, subscriptionService),
                SizedBox(height: 30),
                
                // Current subscription status
                if (subscriptionService.currentSubscription != null)
                  _buildCurrentSubscriptionCard(context, subscriptionService),
                
                SizedBox(height: 30),
                
                // Subscription plans
                _buildSubscriptionPlans(context, subscriptionService),
                
                SizedBox(height: 30),
                
                // Features comparison
                _buildFeaturesComparison(context),
                
                SizedBox(height: 30),
                
                // FAQ section
                _buildFAQSection(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, SubscriptionService subscriptionService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose Your Plan',
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Unlock premium features and take control of your notifications',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentSubscriptionCard(BuildContext context, SubscriptionService subscriptionService) {
    final subscription = subscriptionService.currentSubscription!;
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
            Theme.of(context).colorScheme.secondary.withOpacity(0.1),
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
              Icon(
                Icons.star,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              SizedBox(width: 12),
              Text(
                'Current Plan',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subscription.tier.name.toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  Text(
                    _getStatusText(subscription.status),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: _getStatusColor(subscription.status),
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(subscription.status),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  subscription.status.name.toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          if (subscription.startDate != null) ...[
            SizedBox(height: 12),
            Text(
              'Started: ${_formatDate(subscription.startDate!)}',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
          if (subscription.trialEndDate != null && subscription.status == SubscriptionStatus.trial) ...[
            SizedBox(height: 8),
            Text(
              'Trial ends in ${_getDaysRemaining(subscription.trialEndDate!)} days',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          if (subscription.endDate != null && subscription.status == SubscriptionStatus.active) ...[
            SizedBox(height: 8),
            Text(
              'Renews: ${_formatDate(subscription.endDate!)}',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSubscriptionPlans(BuildContext context, SubscriptionService subscriptionService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Plans',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 20),
        
        if (subscriptionService.isLoading)
          Center(child: CircularProgressIndicator())
        else
          ...subscriptionService.subscriptionPlans.map((plan) => 
            _buildPlanCard(context, plan, subscriptionService)
          ),
      ],
    );
  }

  Widget _buildPlanCard(BuildContext context, SubscriptionPlan plan, SubscriptionService subscriptionService) {
    final isCurrentPlan = subscriptionService.currentSubscription?.productId == plan.id;
    final isPopular = plan.isPopular;
    
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isCurrentPlan 
          ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
          : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrentPlan 
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.outline.withOpacity(0.2),
          width: isCurrentPlan ? 2 : 1,
        ),
        boxShadow: isPopular ? [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ] : null,
      ),
      child: Stack(
        children: [
          if (isPopular)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
                child: Text(
                  'MOST POPULAR',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plan.name,
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            plan.description,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${plan.price.toStringAsFixed(2)}',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        Text(
                          plan.billingPeriod,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                SizedBox(height: 16),
                
                // Features list
                ...plan.features.take(3).map((feature) => 
                  Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 20,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            feature,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: 20),
                
                // Action button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isCurrentPlan 
                      ? null 
                      : () => _purchasePlan(context, plan, subscriptionService),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCurrentPlan 
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                        : Theme.of(context).colorScheme.primary,
                      foregroundColor: isCurrentPlan 
                        ? Theme.of(context).colorScheme.onSurface
                        : Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      isCurrentPlan ? 'Current Plan' : 'Choose Plan',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesComparison(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Feature Comparison',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 20),
        
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Column(
            children: [
              _buildFeatureRow(context, 'Feature', 'Free', 'Pro', 'Enterprise'),
              Divider(height: 1),
              _buildFeatureRow(context, 'Notifications per day', '50', 'Unlimited', 'Unlimited'),
              Divider(height: 1),
              _buildFeatureRow(context, 'Advanced Analytics', '❌', '✅', '✅'),
              Divider(height: 1),
              _buildFeatureRow(context, 'Voice Commands', '❌', '✅', '✅'),
              Divider(height: 1),
              _buildFeatureRow(context, 'Calendar Sync', '❌', '✅', '✅'),
              Divider(height: 1),
              _buildFeatureRow(context, 'Custom Themes', '❌', '✅', '✅'),
              Divider(height: 1),
              _buildFeatureRow(context, 'Priority Support', '❌', '✅', '✅'),
              Divider(height: 1),
              _buildFeatureRow(context, 'API Access', '❌', '❌', '✅'),
              Divider(height: 1),
              _buildFeatureRow(context, 'Team Collaboration', '❌', '❌', '✅'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureRow(BuildContext context, String feature, String free, String pro, String enterprise) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              feature,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              free,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Expanded(
            child: Text(
              pro,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              enterprise,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Frequently Asked Questions',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 20),
        
        _buildFAQItem(
          context,
          'Can I cancel my subscription anytime?',
          'Yes, you can cancel your subscription at any time. Your access will continue until the end of your current billing period.',
        ),
        _buildFAQItem(
          context,
          'What happens after my trial ends?',
          'After your 7-day trial, you\'ll automatically be moved to the free tier. You can upgrade to Pro anytime to continue enjoying premium features.',
        ),
        _buildFAQItem(
          context,
          'How do I restore my purchases?',
          'Tap the "Restore" button in the top-right corner to restore any previous purchases you\'ve made.',
        ),
        _buildFAQItem(
          context,
          'Is my data safe?',
          'Absolutely! Your data is stored locally on your device and synced securely with your account. We never share your personal information.',
        ),
      ],
    );
  }

  Widget _buildFAQItem(BuildContext context, String question, String answer) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            answer,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _purchasePlan(BuildContext context, SubscriptionPlan plan, SubscriptionService subscriptionService) async {
    try {
      // Find the corresponding product
      final product = subscriptionService.products.firstWhere(
        (p) => p.id == plan.id,
        orElse: () => throw Exception('Product not found'),
      );
      
      final success = await subscriptionService.purchaseSubscription(product);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Purchase successful! Welcome to ${plan.name}!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Purchase failed. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _getDaysRemaining(DateTime trialEndDate) {
    final now = DateTime.now();
    final difference = trialEndDate.difference(now).inDays;
    return difference > 0 ? difference.toString() : '0';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _getStatusColor(SubscriptionStatus status) {
    switch (status) {
      case SubscriptionStatus.active:
        return Colors.green;
      case SubscriptionStatus.trial:
        return Colors.blue;
      case SubscriptionStatus.expired:
        return Colors.red;
      case SubscriptionStatus.cancelled:
        return Colors.orange;
      case SubscriptionStatus.pending:
        return Colors.yellow.shade700;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(SubscriptionStatus status) {
    switch (status) {
      case SubscriptionStatus.active:
        return 'Active Subscription';
      case SubscriptionStatus.trial:
        return 'Free Trial Active';
      case SubscriptionStatus.expired:
        return 'Subscription Expired';
      case SubscriptionStatus.cancelled:
        return 'Subscription Cancelled';
      case SubscriptionStatus.pending:
        return 'Payment Pending';
      default:
        return 'Unknown Status';
    }
  }
}
