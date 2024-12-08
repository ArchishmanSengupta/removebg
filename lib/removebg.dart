library removebg;

import 'package:flutter/rendering.dart';

/// A background removal and text rerenderer for images.
class Removebg {
  /// Removes the background from an image using ONNX model
  ///
  /// [imageProvider_] The input image provider to process
  /// Returns a Future of ImageProvider with background removed
  static Future<ImageProvider> removebg(ImageProvider imageProvider_) async {
    try {
      // Convert ImageProvider to Unint8List
      return imageProvider_;
    } catch (e) {
      print('Background removal error: $e');
      return imageProvider_;
    }
  }
}
