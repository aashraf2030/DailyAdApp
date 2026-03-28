import 'package:ads_app/Repos/ad_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

part 'operational_state.dart';


class OperationalCubit extends Cubit<OperationalState>{

  final SharedPreferences prefs;
  final AdsRepo repo;

  OperationalCubit(super.initialState, this.prefs, this.repo);

  bool isGuest()
  {
    return prefs.getBool("guest") ?? false;
  }

  
  bool isMyAd(String? adUserId) {
    if (isGuest() || adUserId == null) {
      return false;
    }
    final currentUserId = prefs.getString("id");
    return currentUserId != null && currentUserId == adUserId;
  }

  Future<bool> createNewAd(String name, String image, String imName,
      String path, String type, int targetViews, int category,String keywords) async
  {
    final String id = prefs.getString("id")?? "";
    final String session = prefs.getString("session")?? "";

    try {
      final imageFile = XFile(image);
      final bytes = await imageFile.readAsBytes();
      
      final response = await repo.createAdWithBytes(
        session, id, name, bytes, imName, path, type, targetViews, category, keywords
      );

      emit(DoneOperational());

      return response == "Success";
    } catch (e) {
      print("Error creating ad: $e");
      emit(DoneOperational());
      return false;
    }
  }

  Future<bool> editAd(String ad, String name, String? image, String imName,
      String path, String type, int targetViews, int category,String keywords)
  async {
    final String id = prefs.getString("id")?? "";
    final String session = prefs.getString("session")?? "";

    final response = await repo.editAd(session, id, ad, name, type, targetViews, image, imName, path
        , category, keywords);

    emit(DoneOperational());

    return response == "Success";
  }

  Future<bool> watchAd(String ad)
  async {
    final String id = prefs.getString("id")?? "";
    final String session = prefs.getString("session")?? "";

    final response = await repo.watch(session, id, ad);

    emit(DoneOperational());

    return response == "Success";
  }

  Future<bool> renewAd(String ad, String tier)
  async
  {
      emit(InitialOperational());
      final String id = prefs.getString("id")?? "";
      final String session = prefs.getString("session")?? "";

      final response = await repo.renew(session, id, ad, tier);

      print("Response : $response");

      emit(DoneOperational());

      return response == "Success";
  }

  
  
  

  
  
  
  
  
  Future<int> checkAdViewAvailability(String adId) async {
    const String prefsKey = "ad_view_limits";
    final int now = DateTime.now().millisecondsSinceEpoch;
    final int oneHourMs = 1 * 60 * 60 * 1000;

    String? jsonString = prefs.getString(prefsKey);
    Map<String, dynamic> limitsMap = {};

    if (jsonString != null) {
      try {
        limitsMap = jsonDecode(jsonString);
      } catch (e) {
        limitsMap = {};
      }
    }

    
    Map<String, dynamic> adData = limitsMap[adId] ?? {
      "count": 0,
      "start_time": now
    };

    int count = adData["count"];
    int startTime = adData["start_time"];

    
    if (now - startTime > oneHourMs) {
      
      count = 1;
      startTime = now;
      
      
      adData["count"] = count;
      adData["start_time"] = startTime;
      limitsMap[adId] = adData;
      await prefs.setString(prefsKey, jsonEncode(limitsMap));
      
      return 0; 
    } else {
      
      if (count < 10) {
        
        count++;
        adData["count"] = count;
        limitsMap[adId] = adData;
        await prefs.setString(prefsKey, jsonEncode(limitsMap));
        
        
        
        
        
        
        
        
        
        
        
        
        return 0; 
      } else {
        return 2; 
      }
    }
  }

  
  Future<int> recordLocalView(String adId) async {
    const String prefsKey = "ad_view_limits";
    final int now = DateTime.now().millisecondsSinceEpoch;
    final int oneHourMs = 1 * 60 * 60 * 1000;

    String? jsonString = prefs.getString(prefsKey);
    Map<String, dynamic> limitsMap = {};
    if (jsonString != null) {
      try {
        limitsMap = jsonDecode(jsonString);
      } catch (e) {
        limitsMap = {};
      }
    }

    
    if (!limitsMap.containsKey(adId)) {
      
      limitsMap[adId] = {"count": 1, "start_time": now};
      await prefs.setString(prefsKey, jsonEncode(limitsMap));
      return 0; 
    }

    Map<String, dynamic> adData = limitsMap[adId];
    int count = adData["count"];
    int startTime = adData["start_time"];

    if (now - startTime > oneHourMs) {
      
      limitsMap[adId] = {"count": 1, "start_time": now};
      await prefs.setString(prefsKey, jsonEncode(limitsMap));
      return 0; 
    } else {
      
      if (count >= 10) {
        return 2; 
      } else {
        
        adData["count"] = count + 1;
        limitsMap[adId] = adData;
        await prefs.setString(prefsKey, jsonEncode(limitsMap));
        return 0; 
      }
    }
  }

  
  

  

  Future<void> initializeAdPayment({
    required String name,
    required String imagePath,
    required String imageName,
    required String adLink,
    required String type,
    required int targetViews,
    required int category,
    required String keywords,
    required String paymentMethod,
    required String platform,
    String? couponCode,
  }) async {
    emit(AdPaymentLoading());

    try {
      final response = await repo.initializeAdPayment(
        name: name,
        imagePath: imagePath,
        imageName: imageName,
        adLink: adLink,
        type: type,
        targetViews: targetViews,
        category: category,
        keywords: keywords,
        paymentMethod: paymentMethod,
        platform: platform,
        couponCode: couponCode,
      );

      if (response['status'] == 'Success') {
        final data = response['data'];
        
        if (paymentMethod == 'apple_pay') {
          emit(AdApplePayRequired(
            orderId: data['order_id'],
            paymentId: data['payment_id'].toString(),
            clientSecret: data['client_secret'],
            amount: (data['amount'] as num).toDouble(),
            currency: data['currency'],
          ));
        } else if (paymentMethod == 'card') {
          
          
          emit(AdPaymentRequired(
            data['payment_url'],
            data['order_id'],
          ));
        } else {
            
            
             emit(AdPaymentSuccess("تم إنشاء الطلب بنجاح"));
        }
      } else {
        String errorMsg = response['message'] ?? "حدث خطأ غير معروف";
        if (errorMsg == "Error" || errorMsg.contains("Exception")) {
             errorMsg = "فشل في بدء عملية الدفع";
        }
        emit(AdPaymentFailure(errorMsg));
      }
    } catch (e) {
      print("Error initializing ad payment: $e");
      emit(AdPaymentFailure("حدث خطأ أثناء الاتصال بالخادم"));
    }
  }

  Future<void> confirmAdApplePay(String paymentId, String paymentToken) async {
    emit(AdPaymentLoading());
    try {
      final response = await repo.confirmAdApplePay(paymentId, paymentToken);
      
      if (response['status'] == 'Success') {
        final data = response['data'] ?? {};
        
        
        
        
        emit(AdPaymentSuccess("تم الدفع وإنشاء الإعلان بنجاح"));
      } else {
        emit(AdPaymentFailure(response['message'] ?? "فشلت عملية الدفع"));
      }
    } catch (e) {
      emit(AdPaymentFailure("حدث خطأ أثناء معالجة الدفع: $e"));
    }
  }

  Future<void> verifyAdPayment(String paymentId) async {
    
    
    
    
    int retries = 0;
    const maxRetries = 10;
    
    while (retries < maxRetries) {
      await Future.delayed(Duration(seconds: 3));
      try {
        final response = await repo.checkAdPaymentStatus(paymentId);
        
        if (response['status'] == 'Success') {
           final data = response['data'];
           if (data['status'] == 'successful') {
             emit(AdPaymentSuccess("تم الدفع وإنشاء الإعلان بنجاح"));
             return; 
           } else if (data['status'] == 'failed') {
             emit(AdPaymentFailure("فشلت عملية الدفع"));
             return;
           }
        }
      } catch (e) {
         print("Polling error: $e");
      }
      retries++;
    }
    
    
    
    
    
  }

  Future<void> validateCoupon(String code, double amount) async {
    emit(AdCouponLoading());
    try {
      final response = await repo.validateCode(code, amount);

      if (response['status'] == 'Success') {
        final data = response['data'];
         
        double discount = double.tryParse(data['discount_amount'].toString()) ?? 0.0;
        double newTotal = double.tryParse(data['new_total'].toString()) ?? amount;
        
        emit(AdCouponValid(discount, newTotal, code));
      } else {
        emit(AdCouponInvalid(response['message'] ?? 'الكود غير صالح'));
      }
    } catch (e) {
      emit(AdCouponInvalid("حدث خطأ أثناء التحقق"));
    }
  }
}
