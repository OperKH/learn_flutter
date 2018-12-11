import 'package:dio/dio.dart';

import '../scoped-models/main.dart';

class _Api {
  final _client = Dio(
    Options(
      baseUrl: 'https://flutter-products-552d4.firebaseio.com',
    ),
  );

  _Api() {
    _addErrorInterceptor();
  }

  _addErrorInterceptor() {
    _client.interceptor.response.onError = (DioError e) {
      switch (e.response.statusCode) {
        case 401:
          mainModel.logout();
          break;
      }
      return e;
    };
  }

  Dio get client {
    return _client;
  }
}

final api = _Api();
