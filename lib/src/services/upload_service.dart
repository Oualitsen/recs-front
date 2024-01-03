import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:recs_ymal/src/db_services/token_db_service.dart';
import 'package:recs_ymal/src/init.dart';
import 'package:universal_html/html.dart' as html;
import 'package:http/http.dart' as http;

class UploadService {
  final tokenService = GetIt.instance.get<TokenDbService>();
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
      formData = FormData.fromMap({"data": await MultipartFile.fromFile(path), ...otherFields});
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

  Future<List<Uint8List>?> imageSearch(String data) async {
    final String apiUrl = '$URL_BASE/api/index/image-search';
    final token = await tokenService.getToken();
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: data,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        List<Map<String, dynamic>> searchResults =
            List<Map<String, dynamic>>.from(json.decode(response.body));

        List<dynamic> imageList = searchResults.map((e) => e["bytes"]).toList();
        List<Uint8List> resultList = [];

        for (var imageData in imageList) {
          resultList.add(Uint8List.fromList(base64Decode(imageData)));
        }

        return resultList;
      } else {
        print('Request failed with status: ${response.statusCode}');
        return null;
      }
    } catch (error) {
      print('Request failed with error: $error');
      return null;
    }
  }

  Future<List<Uint8List>?> textSearch(String data) async {
    final String apiUrl = '$URL_BASE/api/index/search';
    final token = await tokenService.getToken();
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: data,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        List<Map<String, dynamic>> searchResults =
            List<Map<String, dynamic>>.from(json.decode(response.body));

        List<dynamic> imageList = searchResults.map((e) => e["bytes"]).toList();
        List<Uint8List> resultList = [];

        for (var imageData in imageList) {
          resultList.add(Uint8List.fromList(base64Decode(imageData)));
        }

        return resultList;
      } else {
        print('Request failed with status: ${response.statusCode}');
        return null;
      }
    } catch (error) {
      print('Request failed with error: $error');
      return null;
    }
  }
}
