import 'dart:convert';

import 'package:dio/dio.dart' show Response;

import './api.dart';

import '../scoped-models/main.dart';

Future<Response> getProducts() {
  return client.get('/products.json?auth=${mainModel.token}');
}

Future<Response> createProduct(Map<String, dynamic> data) {
  return client.post(
    '/products.json?auth=${mainModel.token}',
    data: data,
  );
}

Future<Response> updateProduct(Map<String, dynamic> data, String id) {
  return client.put(
    '/products/$id.json?auth=${mainModel.token}',
    data: data,
  );
}

Future<Response> deleteProduct(String id) {
  return client.delete('/products/$id.json?auth=${mainModel.token}');
}
