import 'dart:convert';

import 'package:http/http.dart' as http;

const String BASE_API_URL = 'https://flutter-products-552d4.firebaseio.com';
final _client = http.Client();

Future<http.Response> getProducts() {
  return _client.get('$BASE_API_URL/products.json');
}

Future<http.Response> createProduct(Map<String, dynamic> data) {
  return _client.post(
    '$BASE_API_URL/products.json',
    body: json.encode(data),
  );
}

Future<http.Response> updateProduct(Map<String, dynamic> data, String id) {
  return _client.put(
    '$BASE_API_URL/products/$id.json',
    body: json.encode(data),
  );
}

Future<http.Response> deleteProduct(String id) {
  return _client.delete('$BASE_API_URL/products/$id.json');
}
