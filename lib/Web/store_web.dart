import 'package:dio/dio.dart';
import '../API/base.dart';

class StoreServices {
  final Dio dio;

  StoreServices(this.dio);

  Future<List<dynamic>> getProducts() async {
    try {
      final response = await dio.get("${BackendAPI.base}store/products");
      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      }
      return [];
    } catch (e) {
      throw e;
    }
  }

  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> data) async {
    try {
      final response = await dio.post("${BackendAPI.base}store/order", data: data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      }
      return {'status': 'Error', 'message': 'Failed to create order'};
    } catch (e) {
      if (e is DioException && e.response != null) {
        return e.response!.data is Map 
            ? e.response!.data as Map<String, dynamic>
            : {'status': 'Error', 'message': e.response!.statusMessage};
      }
      throw e;
    }
  }

  Future<Map<String, dynamic>> checkOrderStatus(int orderId) async {
    try {
      final response = await dio.post("${BackendAPI.base}store/order/status", data: {'order_id': orderId});
      if (response.statusCode == 200) {
        return response.data;
      }
      return {'status': 'Error', 'message': 'Failed to check status'};
    } catch (e) {
      if (e is DioException && e.response != null) {
        return e.response!.data is Map 
            ? e.response!.data as Map<String, dynamic>
            : {'status': 'Error', 'message': e.response!.statusMessage};
      }
      print("Check Order Status Error: $e");
      return {'status': 'Error', 'message': 'Connection error'};
    }
  }

  Future<bool> addProduct(FormData data) async {
    try {
      final response = await dio.post("${BackendAPI.base}store/add_product", data: data);
      return response.statusCode == 200;
    } catch (e) {
      throw e;
    }
  }

  Future<bool> editProduct(FormData data) async {
    try {
      final response = await dio.post("${BackendAPI.base}store/edit_product", data: data);
      return response.statusCode == 200;
    } catch (e) {
      throw e;
    }
  }

  Future<bool> deleteProduct(int id) async {
    try {
      final response = await dio.post("${BackendAPI.base}store/delete_product", data: {'id': id});
      return response.statusCode == 200;
    } catch (e) {
      throw e;
    }
  }
}
