import 'dart:convert';
import '../../core/utils/error_mapper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../../Repos/store_repo.dart';
import 'store_state.dart';

class StoreCubit extends Cubit<StoreState> {
  final StoreRepo repo;
  
  List<dynamic> products = [];
  List<Map<String, dynamic>> cart = [];

  StoreCubit(this.repo) : super(StoreInitial());

  void getProducts() async {
    emit(StoreLoading());
    try {
      products = await repo.getProducts();
      emit(StoreLoaded(products));
    } catch (e) {
      final failure = ErrorMapper.map(e);
      emit(StoreError(failure.message));
    }
  }

  void addToCart(dynamic product, int quantity) {
    // Check if product already in cart
    int index = cart.indexWhere((item) => item['id'] == product['id']);
    
    if (index != -1) {
      cart[index]['quantity'] += quantity;
    } else {
      cart.add({
        'id': product['id'],
        'name': product['name'],
        'price': product['price'],
        'image': product['image'],
        'quantity': quantity
      });
    }
    
    emitCartUpdate();
  }

  void removeFromCart(int productId) {
    cart.removeWhere((item) => item['id'] == productId);
    emitCartUpdate();
  }

  void updateQuantity(int productId, int quantity) {
    int index = cart.indexWhere((item) => item['id'] == productId);
    if (index != -1) {
      if (quantity <= 0) {
        removeFromCart(productId);
      } else {
        cart[index]['quantity'] = quantity;
        emitCartUpdate();
      }
    }
  }

  void emitCartUpdate() {
    double total = 0;
    for (var item in cart) {
      total += (double.parse(item['price'].toString()) * item['quantity']);
    }
    emit(StoreCartUpdated(cart, total));
  }

  Future<bool> placeOrder({
    required String address,
    required String phone,
    required String receiverName,
    required String paymentMethod, // 'cash', 'card', 'apple_pay', or 'google_pay'
    Map<String, dynamic>? paymentToken, // optional for digital payments
  }) async {
    emit(StoreLoading());
    try {
      double total = 0;
      for (var item in cart) {
        total += (double.parse(item['price'].toString()) * item['quantity']);
      }

      final orderData = {
        'items': jsonEncode(cart), 
        'total_price': total,
        'address': address,
        'phone': phone,
        'receiver_name': receiverName,
        'payment_method': paymentMethod,
      };

      // Add payment token if available (though usually handled by backend for web/iframe)
      if (paymentToken != null) {
        orderData['payment_token'] = jsonEncode(paymentToken);
      }
      
      // Determine platform
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        orderData['platform'] = 'ios';
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        orderData['platform'] = 'android';
      } else {
        orderData['platform'] = 'web';
      }

      final response = await repo.createOrder(orderData);
      
      if (response['status'] == 'Success') {
        final data = response['data'] ?? {};
        
        // Helper to extract value from data or root response
        dynamic getValue(String key) {
          if (data is Map && data.containsKey(key)) return data[key];
          if (response.containsKey(key)) return response[key];
          return null;
        }

        final int orderId = int.tryParse(getValue('order_id').toString()) ?? 0;
        
        // Handle different payment methods
        if (paymentMethod == 'cash') {
          cart.clear();
          emit(StoreOrderSuccess(response));
          return true;
        } else if (paymentMethod == 'card') {
          print("🔍 [STORE] Card payment response: $response");
          print("🔍 [STORE] Data object: $data");
          
          final String? paymentUrl = getValue('payment_url');
          print("🔍 [STORE] Payment URL extracted: $paymentUrl");
          
          if (paymentUrl != null && paymentUrl.isNotEmpty) {
            print("✅ [STORE] Emitting StorePaymentRequired with URL: $paymentUrl");
            emit(StorePaymentRequired(paymentUrl, orderId));
            return true;
          } else {
            print("🔴 [STORE] Payment URL is null or empty!");
            emit(StoreOrderError("فشل في الحصول على رابط الدفع"));
            return false;
          }
        } else if (paymentMethod == 'apple_pay') {
           final String? clientSecret = getValue('client_secret');
           final double amount = double.tryParse(getValue('amount').toString()) ?? total;
           final String currency = getValue('currency') ?? 'SAR';
           
           if (clientSecret != null) {
             emit(StoreApplePayRequired(
               clientSecret: clientSecret,
               orderId: orderId,
               amount: amount,
               currency: currency
             ));
             return true;
           }
        }

        // Fallback for success without specific payment flow
        cart.clear();
        emit(StoreOrderSuccess(response));
        return true;
      } else {
        emit(StoreOrderError(response['message'] ?? "Failed to place order"));
        return false;
      }
    } catch (e) {
      final failure = ErrorMapper.map(e);
      emit(StoreOrderError(failure.message));
      return false;
    }
  }

  // Poll for payment status
  void verifyPayment(int orderId) async {
    // Don't emit loading here to avoid disrupting the UI if the user is looking at something
    // Or emit a subtle loading state if needed.
    // For now, let's just check silently and emit success if done.
    
    int retries = 0;
    const int maxRetries = 10;
    
    while (retries < maxRetries) {
      await Future.delayed(Duration(seconds: 3)); // Poll every 3 seconds
      
      try {
        final response = await repo.checkOrderStatus(orderId);
        if (response['status'] == 'Success') {
          final data = response['data'];
          final status = data['status'];
          
          if (status == 'processing' || status == 'completed') {
            cart.clear();
            emit(StorePaymentSuccess(orderId));
            return;
          } else if (status == 'cancelled') {
             emit(StoreOrderError("Payment was cancelled or failed."));
             return;
          }
           // if pending_payment, continue polling
        }
      } catch (e) {
        print("Polling error: $e");
      }
      retries++;
    }
    
    // If we reach here, we timed out or stopped polling
    // Don't necessarily emit error, user might verify manually later
  }

  Future<bool> addProduct(String name, String? desc, double price, dynamic imageFile, int stock) async {
    emit(StoreLoading());
    try {
      final Map<String, dynamic> map = {
        'name': name,
        'description': desc ?? "",
        'price': price,
        'stock': stock,
      };

      if (imageFile != null) {
        if (kIsWeb) {
          final bytes = await imageFile.readAsBytes();
          map['image'] = MultipartFile.fromBytes(bytes, filename: 'upload.jpg');
        } else {
          map['image'] = await MultipartFile.fromFile(imageFile.path, filename: imageFile.path.split('/').last);
        }
      }

      final formData = FormData.fromMap(map);
      
      final success = await repo.addProduct(formData);
      if (success) {
        getProducts(); // Refresh list
        return true;
      } else {
        emit(StoreError("Failed to add product"));
        return false;
      }
    } catch (e) {
      emit(StoreError("Error adding product: $e"));
      return false;
    }
  }

  Future<bool> editProduct(int id, String name, String? desc, double price, dynamic imageFile, int stock) async {
    emit(StoreLoading());
    try {
      final map = {
        'id': id,
        'name': name,
        'description': desc ?? "",
        'price': price,
        'stock': stock,
      };

      if (imageFile != null && imageFile is! String) {
        if (kIsWeb) {
          final bytes = await imageFile.readAsBytes();
          map['image'] = MultipartFile.fromBytes(bytes, filename: 'upload.jpg');
        } else {
          map['image'] = await MultipartFile.fromFile(imageFile.path, filename: imageFile.path.split('/').last);
        }
      }

      final formData = FormData.fromMap(map);
      
      final success = await repo.editProduct(formData);
      if (success) {
        getProducts(); // Refresh list
        return true;
      } else {
        emit(StoreError("Failed to edit product"));
        return false;
      }
    } catch (e) {
      emit(StoreError("Error editing product: $e"));
      return false;
    }
  }

  Future<bool> deleteProduct(int id) async {
    emit(StoreLoading());
    try {
      final success = await repo.deleteProduct(id);
      if (success) {
        getProducts(); // Refresh list
        return true;
      } else {
        emit(StoreError("Failed to delete product"));
        return false;
      }
    } catch (e) {
      emit(StoreError("Error deleting product: $e"));
      return false;
    }
  }
}
