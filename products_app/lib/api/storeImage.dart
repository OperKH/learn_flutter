import 'dart:io';
import 'package:dio/dio.dart' show Response, FormData, UploadFileInfo, Options;

import '../scoped-models/main.dart';

import './api.dart';

Future<Response> storeImage(File file, [String imagePath]) {
  FormData formData = new FormData.from({
    'image': UploadFileInfo(file, file.uri.pathSegments.last)
  });
  if (imagePath != null) {
    formData.add('formData', imagePath);
  }
  return client.post(
    'https://us-central1-flutter-products-552d4.cloudfunctions.net/storeImage',
    data: formData,
    options: Options(
      headers: {'Authorization': 'Bearer ${mainModel.token}'},
    ),
  );
}
