library removebg;

import 'dart:async';
import 'dart:ui';

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

/// A background removal and text rerenderer for images.
class Removebg {
  /// Removes the background from an image using ONNX model
  ///
  /// [imageProvider_] The input image provider to process
  /// Returns a Future of ImageProvider with background removed
  static Future<ImageProvider> removebg(ImageProvider imageProvider_) async {
    try {
      // Convert ImageProvider to Unint8List

      Uint8List? imageBytes = await _imageProviderToBytes(imageProvider_);
      return imageProvider_;
    } catch (e) {
      print('Background removal error: $e');
      return imageProvider_;
    }
  }

  /// Converts an [ImageProvider] to a [Uint8List] in PNG format.
  ///
  /// - Parameter [imageProvider]: The [ImageProvider] to be converted.
  /// - Returns: A [Future] that completes with the [Uint8List] representation
  ///   of the image.
  static Future<Uint8List?> _imageProviderToBytes(
      ImageProvider imageProvider) async {
    try {
      final completer = Completer<Uint8List>();

      imageProvider.resolve(const ImageConfiguration()).addListener(
            ImageStreamListener(
              (ImageInfo imageInfo, bool synchronousCall) async {
                final ByteData? byteData = await imageInfo.image.toByteData(
                  format: ImageByteFormat.png,
                );
                completer.complete(byteData?.buffer.asUint8List());
              },
              onError: (dynamic exception, StackTrace? stackTrace) {
                completer.completeError(exception, stackTrace);
              },
            ),
          );
      return completer.future;
    } catch (e) {
      pragma('Image conversion error: $e');
      return null;
    }
  }
}
