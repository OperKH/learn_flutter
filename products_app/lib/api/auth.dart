import 'package:dio/dio.dart';

import '../config.dart';
import './api.dart';

Future<Response> signupNewUser(Map<String, dynamic> data) {
  return client.post(
    'https://www.googleapis.com/identitytoolkit/v3/relyingparty/signupNewUser?key=$FIREBASE_API_KEY',
    data: data,
  );
}

Future<Response> loginUser(Map<String, dynamic> data) {
  return client.post(
    'https://www.googleapis.com/identitytoolkit/v3/relyingparty/verifyPassword?key=$FIREBASE_API_KEY',
    data: data,
  );
}
