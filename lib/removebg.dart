library removebg;

import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:onnxruntime/onnxruntime.dart';

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

      if (imageBytes == null) {
        throw Exception('Invalid Image');
      }

      // load the ONNX model for background segmentation
      final sessionOptions = OrtSessionOptions();
      const rawAssetFileName = 'assets/isnet_quint8.onnx';
      final modelBytes = await rootBundle.load(rawAssetFileName);
      final bytes = modelBytes.buffer.asUint8List();
      final session = OrtSession.fromBuffer(bytes, sessionOptions);

      // Preprocess the image
      final preprocessedImage = _preprocessImage(imageBytes);

      // Run inference
      final inputs = {
        'input': preprocessedImage,
      };
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

  /// Preprocesses image for ONNX model input
  static Uint8List _preprocessImage(Uint8List imageBytes) {
    // Decode the image
    final image = img.decodeImage(imageBytes);

    if (image == null) {
      throw Exception('Invalid Image');
    }

    // Resize image to model input size (512 x 512)
    final resizedImage = img.copyResize(image, width: 512, height: 512);

    final Float32List floatList =
        Float32List(1 * 3 * resizedImage.width * resizedImage.height);

    for (int y = 0; y < resizedImage.height; y++) {
      for (int x = 0; x < resizedImage.width; x++) {
        final pixel = resizedImage.getPixel(
          x,
          y,
        );
        final index = (y * resizedImage.width + x);

        // Normalize Pixel Values to [-1, 1]
        floatList[index] = (pixel.r / 255.0 - 0.5 * 2.0);
        floatList[index + resizedImage.width * resizedImage.height] =
            (pixel.g / 255.0 - 0.5 * 2.0);
        floatList[index + 2 * resizedImage.width * resizedImage.height] =
            (pixel.b / 255.0 - 0.5 * 2.0);
      }
    }

    return floatList.buffer.asUint8List();
  }

  static Future<ImageProvider> loadOnnxModel(
      ImageProvider imageProvider_) async {
    return imageProvider_;
  }

  /// Applies segmentation mask to remove background
  static Uint8List _applyMask(Uint8List originalImage, Uint8List mask) {
    final image = img.decodeImage(originalImage);
    final maskImage = img.decodeImage(mask);

    if (image == null || maskImage == null) {
      return originalImage;
    }

    // Create a new image with transparency
    final processedImage = img.Image(width: image.width, height: image.height);

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final originalPixel = image.getPixel(x, y);
        final maskPixel = maskImage.getPixel(x, y);

        // Check if pixel should be transparent based on mask
        if (maskPixel.r < 128) {
          // Assuming low red value indicates background
          processedImage.setPixel(
              x,
              y,
              img.ColorRgb8(
                255,
                255,
                255,
              ));
        } else {
          processedImage.setPixel(
              x,
              y,
              img.ColorRgb8(originalPixel.r.toInt(), originalPixel.g.toInt(),
                  originalPixel.b.toInt()));
        }
      }
    }

    // Encode as PNG with transparency
    return img.encodePng(processedImage);
  }
}
