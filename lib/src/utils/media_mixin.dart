import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http_error_handler/error_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rxdart/rxdart.dart';
import 'package:recs_front/src/services/upload_service.dart';
import 'package:recs_front/src/utils/lang.dart';

mixin MediaMixin<T extends StatefulWidget> on State<T> {
  final uploadProgress = BehaviorSubject<double?>();
  final uploadService = GetIt.instance.get<UploadService>();

  String? _currentPath;
  String? _currentUri;

  Stream<ImageSource> _imageSource(BuildContext context) {
    final lang = getLang(context);
    return showModalBottomSheet<ImageSource>(
      context: context,
      builder: (_) => ListView(
        children: [
          ListTile(
            title: Text(lang.camera.toUpperCase()),
            onTap: () => Navigator.of(context).pop(ImageSource.camera),
          ),
          ListTile(
            title: Text(lang.gallery.toUpperCase()),
            onTap: () => Navigator.of(context).pop(ImageSource.gallery),
          ),
        ],
      ),
    ).asStream().where((event) => event != null).map((event) => event!);
  }

  Stream<String> readImagePath(BuildContext context) {
    return _imageSource(context).flatMap((value) => _readImagePath(context: context, source: value)
        .asStream()
        .where((event) => event != null)
        .map((event) => event!));
  }

  Stream<String> readVideoPath(BuildContext context) {
    return _imageSource(context).flatMap((value) =>
        _readImagePath(context: context, source: value, image: false)
            .asStream()
            .where((event) => event != null)
            .map((event) => event!));
  }

  Stream<String> uploadFile(String uri, String path, BuildContext context) {
    return uploadFileDynamic(uri, path, context).map((event) => event as String);
  }

  Stream<dynamic> uploadFileDynamic(String uri, String path, BuildContext context,
      {Map<String, String> otherFields = const {}}) {
    _currentUri = uri;
    _currentPath = path;
    return uploadService
        .uploadFileDynamic(uri, path, otherFields: otherFields, callBack: uploadProgress.add)
        .asStream()
        .doOnListen(() => uploadProgress.add(0))
        .doOnDone(() => uploadProgress.add(null))
        .doOnError((p0, p1) {
      uploadProgress.addError(p0);
      showServerError(context, error: p0);
    });
  }

  Stream<String> upload(String uri, BuildContext context) {
    return uploadDynamic(uri, context).map((event) => event as String);
  }

  Stream<dynamic> uploadDynamic(String uri, BuildContext context) {
    return readImagePath(context).flatMap((path) => uploadFileDynamic(uri, path, context));
  }

  Stream<dynamic> uploadVideoDynamic(String uri, BuildContext context) {
    return readVideoPath(context).flatMap((path) => uploadFileDynamic(uri, path, context));
  }

  Stream<String> uploadVideo(String uri, BuildContext context) {
    return uploadVideoDynamic(uri, context).map((event) => event as String);
  }

  Stream<String> retryUpload(BuildContext context) {
    return uploadFile(_currentUri!, _currentPath!, context);
  }

  Widget retryButton(BuildContext context) {
    return IconButton(
      onPressed: () => retryUpload(context),
      icon: Icon(
        Icons.refresh,
        color: Theme.of(context).colorScheme.error,
      ),
    );
  }

  Widget progressWidget(BuildContext context, double progress) {
    return Text("${progress.toInt()} %");
  }

  Widget progressBarWidget() {
    return StreamBuilder<double?>(
        stream: uploadProgress,
        initialData: uploadProgress.valueOrNull,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return retryButton(context);
          }

          if (snapshot.hasData) {
            final value = snapshot.data!;
            return Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: value,
                  ),
                ),
                SizedBox(
                  width: 70,
                  child: Text("${value.toInt()} %"),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        });
  }

  Future<String?> _readImagePath({
    required context,
    ImageSource source = ImageSource.camera,
    bool image = true,
  }) async {
    if (image) {
      return ImagePicker()
          .pickImage(source: source)
          .asStream()
          .where((event) => event != null)
          .map((event) => event!)
          .map((event) => event.path)
          .first;
    } else {
      return ImagePicker()
          .pickVideo(source: source)
          .asStream()
          .where((event) => event != null)
          .map((event) => event!)
          .map((event) => event.path)
          .first;
    }
  }

  Future<dynamic> uploadImage(Uint8List? bytes, bool kIsWeb) async {
    if (bytes != null) {
      try {
        if (kIsWeb) {
          return await uploadService.upload("/image/upload", bytes, "");
        }
      } catch (error, stacktrace) {
        print(stacktrace);
        showServerError(context, error: error);
      }
    }
    return null;
  }
}
