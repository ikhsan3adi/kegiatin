import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:kegiatin/core/pcd/enhancement_options.dart';
import 'package:kegiatin/core/pcd/image_enhancer.dart';

void main() {
  group('enhance', () {
    test('with original mode returns same bytes', () async {
      final bytes = Uint8List.fromList([0, 1, 2, 3]);
      final result = await ImageEnhancer.enhance(bytes, EnhancementMode.original);
      expect(result, bytes);
    });

    test('with auto mode returns different bytes', () async {
      final testImage = img.Image(width: 4, height: 4);
      for (var y = 0; y < 4; y++) {
        for (var x = 0; x < 4; x++) {
          testImage.setPixelRgba(x, y, x * 60, y * 60, 128, 255);
        }
      }
      final bytes = Uint8List.fromList(img.encodeJpg(testImage, quality: 100));
      final result = await ImageEnhancer.enhance(bytes, EnhancementMode.auto);
      expect(result, isNot(equals(bytes)));
    });
  });
}
