import 'package:dio/dio.dart';

Options _options = Options(
  baseUrl: 'https://flutter-products-552d4.firebaseio.com',
);

final Dio client = Dio(_options);
