import 'dart:convert';

import 'package:http/http.dart' as http;

import './api.dart';

Future<http.Response> getProducts() {
  return client.get('$BASE_API_URL/products.json');
}

Future<http.Response> createProduct(Map<String, dynamic> data) {
  return client.post(
    '$BASE_API_URL/products.json',
    body: json.encode(data),
  );
}

Future<http.Response> updateProduct(Map<String, dynamic> data, String id) {
  return client.put(
    '$BASE_API_URL/products/$id.json',
    body: json.encode(data),
  );
}

Future<http.Response> deleteProduct(String id) {
  return client.delete('$BASE_API_URL/products/$id.json');
}
