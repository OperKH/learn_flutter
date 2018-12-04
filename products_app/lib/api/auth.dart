import 'dart:convert';

import 'package:dio/dio.dart';

import './api.dart';

Future<Response> signupNewUser(Map<String, dynamic> data) {
  return client.post(
    'https://www.googleapis.com/identitytoolkit/v3/relyingparty/signupNewUser?key=AIzaSyAZLuJjoDTocGbUpoe8dcoZqqer-ZxvCtk',
    data: data,
  );
}

Future<Response> loginUser(Map<String, dynamic> data) {
  return client.post(
    'https://www.googleapis.com/identitytoolkit/v3/relyingparty/verifyPassword?key=AIzaSyAZLuJjoDTocGbUpoe8dcoZqqer-ZxvCtk',
    data: data,
  );
}
