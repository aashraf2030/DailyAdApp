import 'dart:convert';
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
      emit(StoreError("Failed to load products"));
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
    required String paymentMethod, // 'cash', 'apple_pay', or 'google_pay'
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

      // Add payment token if available
      if (paymentToken != null) {
        orderData['payment_token'] = jsonEncode(paymentToken);
      }

      final success = await repo.createOrder(orderData);
      
      if (success) {
        cart.clear();
        emit(StoreOrderSuccess());
        return true;
      } else {
        emit(StoreOrderError("Failed to place order"));
        return false;
      }
    } catch (e) {
      emit(StoreOrderError("Error placing order: $e"));
      return false;
    }
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
