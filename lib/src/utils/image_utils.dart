import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http_error_handler/error_handler.dart';
import 'package:image_picker/image_picker.dart';

class ImageUtils {
  static const double _maxRadius = 0xFFFFFFFFFF;

  static Widget fromMemory(Uint8List bytes,
      {double radius = 0.0, double? height, double? width, BoxFit? fit, double scale = 1.0}) {
    var widget = Image.memory(
      bytes,
      height: height,
      width: width,
      fit: fit,
      scale: scale,
    );
    return _setItInContainer(_addRadius(widget, radius, width, height), width, height);
  }

  static Widget fromMemoryRounded(Uint8List bytes,
      {double? height, double? width, BoxFit? fit, double scale = 1.0}) {
    return fromMemory(bytes, height: height, width: width, fit: fit, scale: scale, radius: _maxRadius);
  }

  static Widget fromNetwork(
    String? url, {
    double radius = 0.0,
    double? height,
    double? width,
    BoxFit? fit,
    String? placeHolder,
    Widget? placeHolderWidget,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    FilterQuality filterQuality = FilterQuality.low,
    scale = 1.0,
    String? semanticLabel,
    Map<String, String>? headers,
    Widget Function(
      BuildContext context,
      Widget child,
      ImageChunkEvent? loadingProgress,
    )? loadingBuilder,
  }) {
    if (url == null) {
      return _setItInContainer(
          placeHolderWidget ?? Image.asset(placeHolder ?? 'assets/noimage.png'), width, height);
    }

    var image = Image.network(
      url,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return _setItInContainer(
            placeHolderWidget ?? Image.asset(placeHolder ?? 'assets/noimage.png'), width, height);
      },
      headers: headers,
      scale: scale,
      height: height,
      width: width,
      repeat: repeat,
      filterQuality: filterQuality,
      semanticLabel: semanticLabel,
      loadingBuilder: loadingBuilder ??
          (context, child, loadingProgress) {
            if (loadingProgress != null && loadingProgress.expectedTotalBytes != null) {
              var percent = loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!;

              return Center(
                child: CircularProgressIndicator(
                  value: percent,
                ),
              );
            }
            return child;
          },
    );
    return _setItInContainer(_addRadius(image, radius, width, height), width, height);
  }

  static Widget fromNetworkRounded(
    String? url, {
    double height = 55,
    double width = 55,
    String? placeHolder,
    Widget? placeHolderWidget,
    scale = 1.0,
    Map<String, String>? headers,
    Widget Function(
      BuildContext context,
      Widget child,
      ImageChunkEvent? loadingProgress,
    )? loadingBuilder,
  }) {
    return ClipOval(
      child: fromNetwork(
        url,
        width: width,
        height: height,
        radius: _maxRadius,
        fit: BoxFit.cover,
        scale: scale,
        placeHolder: placeHolder,
        placeHolderWidget: placeHolderWidget,
        headers: headers,
        loadingBuilder: loadingBuilder,
      ),
    );
  }

  static Widget roundedAvatar({
    required BuildContext context,
    required Widget child,
    double size = 55,
    Color? backgroundColor,
  }) {
    return ClipOval(
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor ?? Theme.of(context).colorScheme.inversePrimary,
        ),
        height: size,
        width: size,
        child: child,
      ),
    );
  }

  static Widget fromAsset(
    String asset, {
    double radius = 0.0,
    double? height,
    double? width,
    BoxFit? fit,
    scale = 1.0,
  }) {
    var widget = Image.asset(
      asset,
      scale: scale,
      fit: fit,
      width: width,
      height: height,
    );

    return _setItInContainer(_addRadius(widget, radius, width, height), width, height);
  }

  static Widget fromAssetRounded(
    String asset, {
    double? height,
    double? width,
    BoxFit? fit,
    scale = 1.0,
  }) {
    return fromAsset(asset, width: width, height: height, fit: fit, scale: scale, radius: _maxRadius);
  }

  static Widget fromFile(
    File file, {
    double radius = 0.0,
    double? height,
    double? width,
    BoxFit? fit,
    scale = 1.0,
  }) {
    var widget = Image.file(
      file,
      scale: scale,
      fit: fit,
      width: width,
      height: height,
    );
    return _setItInContainer(_addRadius(widget, radius, width, height), width, height);
  }

  static Widget fromFileRounded(
    File file, {
    double radius = 0.0,
    double? height,
    double? width,
    BoxFit? fit,
    scale = 1.0,
  }) {
    return fromFile(file, radius: _maxRadius, height: height, width: width, fit: fit, scale: scale);
  }

  static Widget _addRadius(Widget widget, double radius, double? width, double? height) {
    if (radius == 0) {
      return widget;
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: widget,
      );
    }
  }

  static Widget _setItInContainer(Widget child, double? width, double? height) {
    if (width == null && height == null) {
      return child;
    }
    return Container(
      width: width,
      height: height,
      child: child,
    );
  }

  static Future<Uint8List?> imagePicker(BuildContext context) async {
    try {
      var platformFiles = await ImagePicker();
      final XFile? pickedFiles = await platformFiles.pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFiles != null) {
        var data = pickedFiles;
        var bytes = await data.readAsBytes();
        return bytes;
      }
    } catch (e) {
      showServerError(context, error: e);
      print("[ERROR]${e}");
    }
    return null;
  }
}
