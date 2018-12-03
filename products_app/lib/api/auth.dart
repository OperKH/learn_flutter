import 'dart:convert';

import 'package:http/http.dart' as http;

import './api.dart';

Future<http.Response> signupNewUser(Map<String, dynamic> data) {
  return client.post(
    'https://www.googleapis.com/identitytoolkit/v3/relyingparty/signupNewUser?key=AIzaSyAZLuJjoDTocGbUpoe8dcoZqqer-ZxvCtk',
    body: json.encode(data),
    headers: {'Content-Type': 'application/json'},
  );
}

Future<http.Response> loginUser(Map<String, dynamic> data) {
  return client.post(
    'https://www.googleapis.com/identitytoolkit/v3/relyingparty/verifyPassword?key=AIzaSyAZLuJjoDTocGbUpoe8dcoZqqer-ZxvCtk',
    body: json.encode(data),
    headers: {'Content-Type': 'application/json'},
  );
}
