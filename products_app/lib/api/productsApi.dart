import 'package:dio/dio.dart' show Response;

import './api.dart';

import '../scoped-models/main.dart';

Future<Response> getProducts() {
  return api.client.get('/products.json?auth=${mainModel.token}');
}

Future<Response> createProduct(Map<String, dynamic> data) {
  return api.client.post(
    '/products.json?auth=${mainModel.token}',
    data: data,
  );
}

Future<Response> updateProduct(Map<String, dynamic> data, String id) {
  return api.client.put(
    '/products/$id.json?auth=${mainModel.token}',
    data: data,
  );
}

Future<Response> deleteProduct(String id) {
  return api.client.delete('/products/$id.json?auth=${mainModel.token}');
}

Future<Response> likeProduct(String id, String userId) {
  return api.client.put(
      '/products/$id/wishlistUsers/$userId.json?auth=${mainModel.token}',
      data: true);
}

Future<Response> unlikeProduct(String id, String userId) {
  return api.client.delete(
      '/products/$id/wishlistUsers/$userId.json?auth=${mainModel.token}');
}
