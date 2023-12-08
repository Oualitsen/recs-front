import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:universal_html/html.dart' as html;

class UploadService {
  static const locStorageKey = 'image';
  Dio dio;

  UploadService(this.dio);

  Future<String> delete(String imageId) async {
    var response = await dio.delete("/rest/image/$imageId");
    return response.data as String;
  }

  Future<String> upload(
    String uri,
    Uint8List data,
    String nameData, {
    Function(double percentage)? callBack,
    Map<String, String> otherFields = const {},
  }) async {
    FormData formData = FormData.fromMap({
      "data": await MultipartFile.fromBytes(
        data,
        filename: nameData,
      )
    });
    var response = await dio.post(
      uri,
      data: formData,
      onSendProgress: (received, total) {
        if (total != -1) {
          double progress = received / total * 100;
          if (callBack != null) {
            callBack(progress);
          }
        }
      },
    );
    return response.data.toString();
  }

  Future<dynamic> uploadFileDynamic(
    String uri,
    String path, {
    Function(double percentage)? callBack,
    Map<String, String> otherFields = const {},
  }) async {
    FormData formData;

    if (locStorageKey == path) {
      var data = html.window.localStorage[UploadService.locStorageKey];
      formData = FormData.fromMap({"base64": data, ...otherFields});
    } else {
      formData = FormData.fromMap(
          {"data": await MultipartFile.fromFile(path), ...otherFields});
    }

    var response = await dio.post(
      uri,
      data: formData,
      onSendProgress: (received, total) {
        if (total != -1) {
          double progress = received / total * 100;
          if (callBack != null) {
            callBack(progress);
          }
        }
      },
    );
    return response.data;
  }
}
