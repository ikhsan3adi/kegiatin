import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:kegiatin/core/pcd/enhancement_options.dart';

class ImageEnhancer {
  static Future<Uint8List> enhance(Uint8List imageBytes, EnhancementMode mode) async {
    if (mode == EnhancementMode.original) {
      return imageBytes;
    }

    return Isolate.run(() => _process(imageBytes, mode));
  }

  static Uint8List _process(Uint8List imageBytes, EnhancementMode mode) {
    final image = img.decodeImage(imageBytes);
    if (image == null) return imageBytes;

    final enhanced = _histogramEqualization(image);
    final sharpened = _unsharpMask(enhanced);

    final encoded = img.encodeJpg(sharpened, quality: 92);
    return Uint8List.fromList(encoded);
  }

  static img.Image _histogramEqualization(img.Image src) {
    final width = src.width;
    final height = src.height;
    final totalPixels = width * height;

    final histogram = List<int>.filled(256, 0);

    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        final pixel = src.getPixel(x, y);
        final r = pixel.r.toInt();
        final g = pixel.g.toInt();
        final b = pixel.b.toInt();
        final luminance = (0.299 * r + 0.587 * g + 0.114 * b).round();
        histogram[luminance.clamp(0, 255)]++;
      }
    }

    final cdf = List<int>.filled(256, 0);
    cdf[0] = histogram[0];
    for (var i = 1; i < 256; i++) {
      cdf[i] = cdf[i - 1] + histogram[i];
    }

    int cdfMin = 0;
    for (var i = 0; i < 256; i++) {
      if (cdf[i] > 0) {
        cdfMin = cdf[i];
        break;
      }
    }

    final lut = List<double>.filled(256, 0);
    final denominator = totalPixels - cdfMin;
    if (denominator > 0) {
      for (var i = 0; i < 256; i++) {
        lut[i] = ((cdf[i] - cdfMin) / denominator) * 255;
      }
    }

    final result = img.Image(width: width, height: height);

    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        final pixel = src.getPixel(x, y);
        final r = pixel.r.toInt();
        final g = pixel.g.toInt();
        final b = pixel.b.toInt();
        final luminance = (0.299 * r + 0.587 * g + 0.114 * b).round().clamp(0, 255);

        final newLuminance = lut[luminance];

        double ratio;
        if (luminance > 0) {
          ratio = newLuminance / luminance;
        } else {
          ratio = 1.0;
        }

        final newR = (r * ratio).round().clamp(0, 255);
        final newG = (g * ratio).round().clamp(0, 255);
        final newB = (b * ratio).round().clamp(0, 255);

        result.setPixelRgba(x, y, newR, newG, newB, pixel.a.toInt());
      }
    }

    return result;
  }

  static img.Image _unsharpMask(
    img.Image src, {
    double amount = 0.8,
    int radius = 1,
    int threshold = 5,
  }) {
    final blurred = img.gaussianBlur(src, radius: radius);
    final width = src.width;
    final height = src.height;
    final result = img.Image(width: width, height: height);

    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        final original = src.getPixel(x, y);
        final blurPixel = blurred.getPixel(x, y);

        final rDiff = original.r.toInt() - blurPixel.r.toInt();
        final gDiff = original.g.toInt() - blurPixel.g.toInt();
        final bDiff = original.b.toInt() - blurPixel.b.toInt();

        int newR, newG, newB;

        if (rDiff.abs() > threshold) {
          newR = (original.r.toInt() + amount * rDiff).round().clamp(0, 255);
        } else {
          newR = original.r.toInt();
        }

        if (gDiff.abs() > threshold) {
          newG = (original.g.toInt() + amount * gDiff).round().clamp(0, 255);
        } else {
          newG = original.g.toInt();
        }

        if (bDiff.abs() > threshold) {
          newB = (original.b.toInt() + amount * bDiff).round().clamp(0, 255);
        } else {
          newB = original.b.toInt();
        }

        result.setPixelRgba(x, y, newR, newG, newB, original.a.toInt());
      }
    }

    return result;
  }
}
