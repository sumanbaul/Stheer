import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/subscription_model.dart';

class SubscriptionService extends ChangeNotifier {
  static const String _subscriptionKey = 'user_subscription';
  static const String _trialStartKey = 'trial_start_date';
  static const String _purchaseHistoryKey = 'purchase_history';
  
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  UserSubscription? _currentSubscription;
  List<ProductDetails> _products = [];
  List<PurchaseDetails> _purchaseHistory = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  // Stream controllers
  final StreamController<UserSubscription?> _subscriptionController = 
      StreamController<UserSubscription?>.broadcast();
  final StreamController<List<PurchaseDetails>> _purchaseHistoryController = 
      StreamController<List<PurchaseDetails>>.broadcast();
  
  // Getters
  UserSubscription? get currentSubscription => _currentSubscription;
  List<ProductDetails> get products => _products;
  List<PurchaseDetails> get purchaseHistory => _purchaseHistory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Stream<UserSubscription?> get subscriptionStream => _subscriptionController.stream;
  Stream<List<PurchaseDetails>> get purchaseHistoryStream => _purchaseHistoryController.stream;
  
  // Subscription plans
  static const List<SubscriptionPlan> _subscriptionPlans = [
    SubscriptionPlan(
      id: 'pro_monthly',
      name: 'Pro Monthly',
      description: 'Unlock all premium features',
      price: 4.99,
      currency: 'USD',
      billingPeriod: 'monthly',
      features: ['Unlimited notifications', 'Advanced analytics', 'Voice commands'],
      tier: SubscriptionTier.pro,
    ),
    SubscriptionPlan(
      id: 'pro_yearly',
      name: 'Pro Yearly',
      description: 'Best value - Save 40%',
      price: 29.99,
      currency: 'USD',
      billingPeriod: 'yearly',
      features: ['Unlimited notifications', 'Advanced analytics', 'Voice commands'],
      isPopular: true,
      tier: SubscriptionTier.pro,
    ),
    SubscriptionPlan(
      id: 'enterprise',
      name: 'Enterprise',
      description: 'For teams and organizations',
      price: 99.99,
      currency: 'USD',
      billingPeriod: 'monthly',
      features: ['All Pro features', 'Team collaboration', 'API access'],
      tier: SubscriptionTier.enterprise,
    ),
  ];

  SubscriptionService() {
    _initializeSubscription();
    _loadProducts();
    _loadPurchaseHistory();
    _setupPurchaseStream();
  }

  void _setupPurchaseStream() {
    _inAppPurchase.purchaseStream.listen(
      (List<PurchaseDetails> purchaseDetailsList) {
        _handlePurchaseUpdates(purchaseDetailsList);
      },
      onDone: () {
        // Purchase stream is done
      },
      onError: (error) {
        _errorMessage = 'Purchase stream error: $error';
        notifyListeners();
      },
    );
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // Handle pending purchase
        _handlePendingPurchase(purchaseDetails);
      } else if (purchaseDetails.status == PurchaseStatus.purchased) {
        // Handle successful purchase
        _handleSuccessfulPurchase(purchaseDetails);
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        // Handle purchase error
        _handlePurchaseError(purchaseDetails);
      } else if (purchaseDetails.status == PurchaseStatus.canceled) {
        // Handle canceled purchase
        _handleCanceledPurchase(purchaseDetails);
      }
      
      if (purchaseDetails.pendingCompletePurchase) {
        _inAppPurchase.completePurchase(purchaseDetails);
      }
    }
  }

  void _handlePendingPurchase(PurchaseDetails purchaseDetails) {
    _isLoading = true;
    _errorMessage = 'Processing purchase...';
    notifyListeners();
  }

  void _handleSuccessfulPurchase(PurchaseDetails purchaseDetails) {
    try {
      // Verify the purchase
      if (_verifyPurchase(purchaseDetails)) {
        // Update subscription
        _updateSubscriptionFromPurchase(purchaseDetails);
        
        // Add to purchase history
        _addToPurchaseHistory(purchaseDetails);
        
        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
      } else {
        _errorMessage = 'Purchase verification failed';
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to process purchase: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  void _handlePurchaseError(PurchaseDetails purchaseDetails) {
    _errorMessage = 'Purchase failed: ${purchaseDetails.error?.message ?? 'Unknown error'}';
    _isLoading = false;
    notifyListeners();
  }

  void _handleCanceledPurchase(PurchaseDetails purchaseDetails) {
    _errorMessage = 'Purchase was canceled';
    _isLoading = false;
    notifyListeners();
  }

  bool _verifyPurchase(PurchaseDetails purchaseDetails) {
    // Basic verification - in production, you should implement server-side verification
    if (purchaseDetails.productID.isEmpty) return false;
    if (purchaseDetails.purchaseID?.isEmpty ?? true) return false;
    
    // Check if product ID matches our subscription plans
    final validProductIds = _subscriptionPlans.map((plan) => plan.id).toSet();
    return validProductIds.contains(purchaseDetails.productID);
  }

  void _updateSubscriptionFromPurchase(PurchaseDetails purchaseDetails) {
    final plan = _subscriptionPlans.firstWhere(
      (plan) => plan.id == purchaseDetails.productID,
      orElse: () => _subscriptionPlans.first,
    );

    final now = DateTime.now();
    DateTime? endDate;
    
    // Calculate subscription end date based on billing period
    if (plan.billingPeriod == 'monthly') {
      endDate = now.add(Duration(days: 30));
    } else if (plan.billingPeriod == 'yearly') {
      endDate = now.add(Duration(days: 365));
    }

    _currentSubscription = UserSubscription(
      userId: _auth.currentUser?.uid ?? 'anonymous',
      tier: plan.tier,
      status: SubscriptionStatus.active,
      startDate: now,
      endDate: endDate,
      transactionId: purchaseDetails.purchaseID,
      productId: purchaseDetails.productID,
    );

    _saveSubscription();
    _subscriptionController.add(_currentSubscription);
  }

  void _addToPurchaseHistory(PurchaseDetails purchaseDetails) {
    _purchaseHistory.add(purchaseDetails);
    _savePurchaseHistory();
    _purchaseHistoryController.add(_purchaseHistory);
  }

  Future<void> _loadPurchaseHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyData = prefs.getStringList(_purchaseHistoryKey) ?? [];
      
      // Note: In a real app, you'd want to store more detailed purchase information
      // This is a simplified version
      _purchaseHistory = [];
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load purchase history: $e';
      notifyListeners();
    }
  }

  Future<void> _savePurchaseHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Simplified storage - in production, store more detailed information
      final historyData = <String>[];
      await prefs.setStringList(_purchaseHistoryKey, historyData);
    } catch (e) {
      _errorMessage = 'Failed to save purchase history: $e';
      notifyListeners();
    }
  }

  Future<void> _initializeSubscription() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final subscriptionData = prefs.getString(_subscriptionKey);
      
      if (subscriptionData != null) {
        // Parse subscription data and set current subscription
        _currentSubscription = _parseSubscriptionFromString(subscriptionData);
        
        // Check if subscription has expired
        if (_currentSubscription != null && _currentSubscription!.hasExpired) {
          _currentSubscription = UserSubscription(
            userId: _currentSubscription!.userId,
            tier: SubscriptionTier.free,
            status: SubscriptionStatus.expired,
            startDate: _currentSubscription!.startDate,
            endDate: _currentSubscription!.endDate,
          );
          await _saveSubscription();
        }
      } else {
        // Check if user is eligible for trial
        await _checkTrialEligibility();
      }
      
      _subscriptionController.add(_currentSubscription);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to initialize subscription: $e';
      notifyListeners();
    }
  }

  Future<void> _checkTrialEligibility() async {
    final prefs = await SharedPreferences.getInstance();
    final trialStart = prefs.getString(_trialStartKey);
    
    if (trialStart == null) {
      // First time user - start trial
      final now = DateTime.now();
      await prefs.setString(_trialStartKey, now.toIso8601String());
      
      _currentSubscription = UserSubscription(
        userId: _auth.currentUser?.uid ?? 'anonymous',
        tier: SubscriptionTier.pro,
        status: SubscriptionStatus.trial,
        startDate: now,
        trialEndDate: now.add(Duration(days: 7)), // 7-day trial
      );
      
      await _saveSubscription();
    } else {
      // Check if trial has expired
      final trialStartDate = DateTime.parse(trialStart);
      final trialEndDate = trialStartDate.add(Duration(days: 7));
      
      if (DateTime.now().isAfter(trialEndDate)) {
        // Trial expired, set to free tier
        _currentSubscription = UserSubscription(
          userId: _auth.currentUser?.uid ?? 'anonymous',
          tier: SubscriptionTier.free,
          status: SubscriptionStatus.expired,
        );
        await _saveSubscription();
      } else {
        // Trial still active
        _currentSubscription = UserSubscription(
          userId: _auth.currentUser?.uid ?? 'anonymous',
          tier: SubscriptionTier.pro,
          status: SubscriptionStatus.trial,
          startDate: trialStartDate,
          trialEndDate: trialEndDate,
        );
        await _saveSubscription();
      }
    }
  }

  Future<void> _loadProducts() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final bool available = await _inAppPurchase.isAvailable();
      if (!available) {
        _errorMessage = 'Store not available';
        return;
      }

      final Set<String> productIds = {
        'pro_monthly',
        'pro_yearly',
        'enterprise',
      };

      final ProductDetailsResponse response = 
          await _inAppPurchase.queryProductDetails(productIds);

      if (response.notFoundIDs.isNotEmpty) {
        _errorMessage = 'Some products not found: ${response.notFoundIDs}';
      }

      _products = response.productDetails;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load products: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> purchaseSubscription(ProductDetails product) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: product,
      );
      
      bool success = false;
      
      // Handle different product types
      if (product.id.contains('subscription') || 
          product.id.contains('pro_') || 
          product.id.contains('enterprise')) {
        success = await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      } else {
        success = await _inAppPurchase.buyConsumable(purchaseParam: purchaseParam);
      }
      
      if (success) {
        return true;
      } else {
        _errorMessage = 'Purchase failed';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Purchase error: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> restorePurchases() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      await _inAppPurchase.restorePurchases();
    } catch (e) {
      _errorMessage = 'Restore failed: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cancelSubscription() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      // Note: In a real app, you'd need to implement server-side cancellation
      // for subscription management
      if (_currentSubscription != null) {
        _currentSubscription = UserSubscription(
          userId: _currentSubscription!.userId,
          tier: SubscriptionTier.free,
          status: SubscriptionStatus.cancelled,
          startDate: _currentSubscription!.startDate,
          endDate: DateTime.now(),
        );
        
        await _saveSubscription();
        _subscriptionController.add(_currentSubscription);
      }
    } catch (e) {
      _errorMessage = 'Failed to cancel subscription: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveSubscription() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final subscriptionString = _subscriptionToString(_currentSubscription);
      await prefs.setString(_subscriptionKey, subscriptionString);
    } catch (e) {
      _errorMessage = 'Failed to save subscription: $e';
      notifyListeners();
    }
  }

  String _subscriptionToString(UserSubscription? subscription) {
    if (subscription == null) return '';
    
    return '${subscription.userId}|${subscription.tier.index}|${subscription.status.index}|'
           '${subscription.startDate?.toIso8601String() ?? ""}|'
           '${subscription.endDate?.toIso8601String() ?? ""}|'
           '${subscription.trialEndDate?.toIso8601String() ?? ""}|'
           '${subscription.transactionId ?? ""}|${subscription.productId ?? ""}';
  }

  UserSubscription? _parseSubscriptionFromString(String data) {
    try {
      final parts = data.split('|');
      if (parts.length < 8) return null;
      
      return UserSubscription(
        userId: parts[0],
        tier: SubscriptionTier.values[int.parse(parts[1])],
        status: SubscriptionStatus.values[int.parse(parts[2])],
        startDate: parts[3].isNotEmpty ? DateTime.parse(parts[3]) : null,
        endDate: parts[4].isNotEmpty ? DateTime.parse(parts[4]) : null,
        trialEndDate: parts[5].isNotEmpty ? DateTime.parse(parts[5]) : null,
        transactionId: parts[6].isNotEmpty ? parts[6] : null,
        productId: parts[7].isNotEmpty ? parts[7] : null,
      );
    } catch (e) {
      return null;
    }
  }

  // Feature access control
  bool hasFeature(String feature) {
    if (_currentSubscription == null) return false;
    return SubscriptionFeatures.hasFeature(_currentSubscription!.tier, feature);
  }

  bool get isProUser => _currentSubscription?.isPro ?? false;
  bool get isTrialActive => _currentSubscription?.isTrial ?? false;
  bool get isSubscriptionActive => _currentSubscription?.isActive ?? false;
  bool get isTrialExpired => _currentSubscription?.isTrialExpired ?? false;

  // Get subscription plans
  List<SubscriptionPlan> get subscriptionPlans => _subscriptionPlans;

  // Get trial days remaining
  int get trialDaysRemaining {
    if (_currentSubscription?.trialEndDate == null) return 0;
    final remaining = _currentSubscription!.trialEndDate!.difference(DateTime.now()).inDays;
    return remaining > 0 ? remaining : 0;
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscriptionController.close();
    _purchaseHistoryController.close();
    super.dispose();
  }
}
