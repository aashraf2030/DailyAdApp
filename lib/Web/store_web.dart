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

  Future<bool> createOrder(Map<String, dynamic> data) async {
    try {
      final response = await dio.post("${BackendAPI.base}store/order", data: data);
      return response.statusCode == 200;
    } catch (e) {
      throw e;
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
