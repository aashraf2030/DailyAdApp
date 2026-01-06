import 'package:dio/dio.dart';
import '../Web/store_web.dart';
import '../core/utils/error_mapper.dart';

class StoreRepo {
  final StoreServices services;

  StoreRepo(this.services);

  Future<List<dynamic>> getProducts() async {
    try {
      final response = await services.getProducts();
      return response;
    } catch (e) {
      print("StoreRepo Error: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> orderData) async {
    try {
      return await services.createOrder(orderData);
    } catch (e) {
      final failure = ErrorMapper.map(e);
      return {'status': 'Error', 'message': failure.message};
    }
  }

  Future<Map<String, dynamic>> checkOrderStatus(int orderId) async {
    try {
      return await services.checkOrderStatus(orderId);
    } catch (e) {
      print("StoreRepo Check Status Error: $e");
      return {'status': 'Error', 'message': e.toString()};
    }
  }

  Future<bool> addProduct(FormData productData) async {
    try {
      return await services.addProduct(productData);
    } catch (e) {
      print("StoreRepo Add Product Error: $e");
      return false;
    }
  }

  Future<bool> editProduct(FormData productData) async {
    try {
      return await services.editProduct(productData);
    } catch (e) {
      print("StoreRepo Edit Product Error: $e");
      return false;
    }
  }

  Future<bool> deleteProduct(int id) async {
    try {
      return await services.deleteProduct(id);
    } catch (e) {
      print("StoreRepo Delete Product Error: $e");
      return false;
    }
  }
}
