import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../API/base.dart';

class AdViewingHelper {
  static const int MAX_DAILY_VIEWS = 10;
  
  /// Check if user can view ad today (daily limit not exceeded)
  static Future<bool> canViewAd(int adId) async {
    final prefs = await SharedPreferences.getInstance();
    
    final today = DateTime.now();
    final todayStr = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
    
    // Get last view date for this ad
    final lastViewDate = prefs.getString('last_view_date_$adId');
    
    // Get view count for this ad today
    int viewCount = prefs.getInt('daily_view_count_$adId') ?? 0;
    
    // If it's a new day, reset counter
    if (lastViewDate != todayStr) {
      viewCount = 0;
      await prefs.setInt('daily_view_count_$adId', 0);
      await prefs.setString('last_view_date_$adId', todayStr);
    }
    
    // Check if under limit
    return viewCount < MAX_DAILY_VIEWS;
  }
  
  /// Increment daily view count for ad
  static Future<void> incrementViewCount(int adId) async {
    final prefs = await SharedPreferences.getInstance();
    
    final today = DateTime.now();
    final todayStr = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
    
    int viewCount = prefs.getInt('daily_view_count_$adId') ?? 0;
    viewCount++;
    
    await prefs.setInt('daily_view_count_$adId', viewCount);
    await prefs.setString('last_view_date_$adId', todayStr);
    
    print("✅ [AD VIEW] Incremented view count for ad $adId: $viewCount/$MAX_DAILY_VIEWS");
  }
  
  /// Get remaining views for ad today
  static Future<int> getRemainingViews(int adId) async {
    final prefs = await SharedPreferences.getInstance();
    
    final today = DateTime.now();
    final todayStr = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
    
    final lastViewDate = prefs.getString('last_view_date_$adId');
    int viewCount = prefs.getInt('daily_view_count_$adId') ?? 0;
    
    // If it's a new day, count is 0
    if (lastViewDate != todayStr) {
      viewCount = 0;
    }
    
    return MAX_DAILY_VIEWS - viewCount;
  }
  
  /// Call backend API to record ad view and get points
  static Future<Map<String, dynamic>> recordAdView(int adId, String userId, String session) async {
    try {
      print("📡 [API] Calling view_ad API for ad $adId...");
      
      final response = await http.post(
        Uri.parse(BackendAPI.view_ad),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $session',
        },
        body: jsonEncode({
          'ad_id': adId,
        }),
      );
      
      print("📡 [API] Response status: ${response.statusCode}");
      print("📡 [API] Response body: ${response.body}");
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': data['success'] ?? false,
          'points_awarded': data['points_awarded'] ?? false,
          'points_given': data['points_given'] ?? 0,
          'total_points': data['total_points'] ?? 0,
          'message': data['message'] ?? '',
        };
      } else {
        return {
          'success': false,
          'points_awarded': false,
          'points_given': 0,
          'total_points': 0,
          'message': 'فشل تسجيل المشاهدة',
        };
      }
    } catch (e) {
      print("🔴 [API ERROR] Failed to record ad view: $e");
      return {
        'success': false,
        'points_awarded': false,
        'points_given': 0,
        'total_points': 0,
        'message': 'خطأ في الاتصال',
      };
    }
  }
}
