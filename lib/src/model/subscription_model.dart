enum SubscriptionTier {
  free,
  pro,
  enterprise,
}

enum SubscriptionStatus {
  active,
  expired,
  cancelled,
  pending,
  trial,
}

class SubscriptionPlan {
  final String id;
  final String name;
  final String description;
  final double price;
  final String currency;
  final String billingPeriod; // monthly, yearly
  final List<String> features;
  final bool isPopular;
  final SubscriptionTier tier;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.currency,
    required this.billingPeriod,
    required this.features,
    this.isPopular = false,
    required this.tier,
  });
}

class UserSubscription {
  final String userId;
  final SubscriptionTier tier;
  final SubscriptionStatus status;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? trialEndDate;
  final String? transactionId;
  final String? productId;

  const UserSubscription({
    required this.userId,
    required this.tier,
    required this.status,
    this.startDate,
    this.endDate,
    this.trialEndDate,
    this.transactionId,
    this.productId,
  });

  bool get isActive => status == SubscriptionStatus.active || status == SubscriptionStatus.trial;
  bool get isPro => tier == SubscriptionTier.pro || tier == SubscriptionTier.enterprise;
  bool get isTrial => status == SubscriptionStatus.trial;
  
  bool get hasExpired {
    if (endDate == null) return false;
    return DateTime.now().isAfter(endDate!);
  }

  bool get isTrialExpired {
    if (trialEndDate == null) return false;
    return DateTime.now().isAfter(trialEndDate!);
  }
}

class SubscriptionFeatures {
  static const Map<SubscriptionTier, List<String>> features = {
    SubscriptionTier.free: [
      'Basic notification management',
      'Up to 50 notifications per day',
      'Basic analytics',
      'Standard widgets',
      'Email support',
    ],
    SubscriptionTier.pro: [
      'Unlimited notifications',
      'Advanced analytics & insights',
      'Premium widgets & customization',
      'Voice commands',
      'Calendar sync',
      'Priority support',
      'Data export',
      'Advanced habit tracking',
      'Custom themes',
      'Ad-free experience',
    ],
    SubscriptionTier.enterprise: [
      'All Pro features',
      'Team collaboration',
      'Advanced reporting',
      'API access',
      'Dedicated support',
      'Custom integrations',
      'White-label options',
    ],
  };

  static List<String> getFeaturesForTier(SubscriptionTier tier) {
    return features[tier] ?? [];
  }

  static bool hasFeature(SubscriptionTier userTier, String feature) {
    final userFeatures = getFeaturesForTier(userTier);
    return userFeatures.contains(feature);
  }
}
