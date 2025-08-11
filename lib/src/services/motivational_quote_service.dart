import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class MotivationalQuoteService {
  // More reliable and free APIs
  static const String _quotableApiUrl = 'https://api.quotable.io/random';
  static const String _zenQuotesApiUrl = 'https://zenquotes.io/api/random';
  static const String _typeFitApiUrl = 'https://type.fit/api/quotes';
  
  // Fallback quotes if API fails
  static const List<String> _fallbackQuotes = [
    'The only way to do great work is to love what you do.',
    'Success is not final, failure is not fatal: it is the courage to continue that counts.',
    'Don\'t watch the clock; do what it does. Keep going.',
    'The future depends on what you do today.',
    'It always seems impossible until it\'s done.',
    'Small progress is still progress.',
    'Every expert was once a beginner.',
    'Make today amazing!',
    'The journey of a thousand miles begins with one step.',
    'Believe you can and you\'re halfway there.',
    'What you get by achieving your goals is not as important as what you become by achieving your goals.',
    'The only limit to our realization of tomorrow will be our doubts of today.',
    'Focus on being productive instead of busy.',
    'The secret of getting ahead is getting started.',
    'Your time is limited, don\'t waste it living someone else\'s life.',
    'The best way to predict the future is to create it.',
    'Success is walking from failure to failure with no loss of enthusiasm.',
    'The only person you are destined to become is the person you decide to be.',
    'Don\'t limit your challenges, challenge your limits.',
    'The harder you work for something, the greater you\'ll feel when you achieve it.',
  ];

  static Future<String> getDailyQuote() async {
    try {
      if (kDebugMode) {
        print('Fetching quote from Quotable API...');
      }
      
      // Try Quotable API first (more reliable)
      final response = await http.get(Uri.parse(_quotableApiUrl))
          .timeout(const Duration(seconds: 10));
      
      if (kDebugMode) {
        print('Quotable API response status: ${response.statusCode}');
      }
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['content'] != null) {
          if (kDebugMode) {
            print('Successfully fetched quote from Quotable: ${data['content']}');
          }
          return data['content'];
        }
      }
      
      if (kDebugMode) {
        print('Quotable API failed, trying TypeFit API...');
      }
      
      // Try TypeFit API as second option
      final typeFitResponse = await http.get(Uri.parse(_typeFitApiUrl))
          .timeout(const Duration(seconds: 10));
      
      if (typeFitResponse.statusCode == 200) {
        final typeFitData = json.decode(typeFitResponse.body);
        if (typeFitData.isNotEmpty && typeFitData[0]['text'] != null) {
          if (kDebugMode) {
            print('Successfully fetched quote from TypeFit: ${typeFitData[0]['text']}');
          }
          return typeFitData[0]['text'];
        }
      }
      
      if (kDebugMode) {
        print('TypeFit API failed, trying ZenQuotes API...');
      }
      
      // Fallback to ZenQuotes API
      final zenResponse = await http.get(Uri.parse(_zenQuotesApiUrl))
          .timeout(const Duration(seconds: 10));
      
      if (zenResponse.statusCode == 200) {
        final zenData = json.decode(zenResponse.body);
        if (zenData.isNotEmpty && zenData[0]['q'] != null) {
          if (kDebugMode) {
            print('Successfully fetched quote from ZenQuotes: ${zenData[0]['q']}');
          }
          return zenData[0]['q'];
        }
      }
      
      if (kDebugMode) {
        print('All APIs failed, using fallback quote');
      }
      
      // If all APIs fail, return a random fallback quote
      return _getRandomFallbackQuote();
      
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching motivational quote: $e');
      }
      return _getRandomFallbackQuote();
    }
  }

  static String _getRandomFallbackQuote() {
    final random = DateTime.now().millisecondsSinceEpoch % _fallbackQuotes.length;
    return _fallbackQuotes[random];
  }

  // Get quote with specific category/tag
  static Future<String> getQuoteByCategory(String category) async {
    try {
      if (kDebugMode) {
        print('Fetching quote by category: $category');
      }
      
      final response = await http.get(
        Uri.parse('$_quotableApiUrl?tags=$category')
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['content'] != null) {
          if (kDebugMode) {
            print('Successfully fetched category quote: ${data['content']}');
          }
          return data['content'];
        }
      }
      
      if (kDebugMode) {
        print('Category API failed, using fallback quote');
      }
      
      return _getRandomFallbackQuote();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching quote by category: $e');
      }
      return _getRandomFallbackQuote();
    }
  }

  // Get productivity-focused quotes
  static Future<String> getProductivityQuote() async {
    return getQuoteByCategory('productivity');
  }

  // Get motivational quotes
  static Future<String> getMotivationalQuote() async {
    return getQuoteByCategory('motivational');
  }

  // Get success-focused quotes
  static Future<String> getSuccessQuote() async {
    return getQuoteByCategory('success');
  }

  // Get wisdom quotes
  static Future<String> getWisdomQuote() async {
    return getQuoteByCategory('wisdom');
  }

  // Get random quote from multiple categories
  static Future<String> getRandomCategoryQuote() async {
    final categories = ['productivity', 'motivational', 'success', 'wisdom', 'leadership'];
    final randomCategory = categories[DateTime.now().millisecondsSinceEpoch % categories.length];
    return getQuoteByCategory(randomCategory);
  }

  // Get quote based on time of day
  static Future<String> getTimeBasedQuote() async {
    final hour = DateTime.now().hour;
    
    if (hour < 12) {
      // Morning - focus on productivity and starting the day
      return getQuoteByCategory('productivity');
    } else if (hour < 17) {
      // Afternoon - focus on motivation and persistence
      return getQuoteByCategory('motivational');
    } else {
      // Evening - focus on reflection and wisdom
      return getQuoteByCategory('wisdom');
    }
  }
}
