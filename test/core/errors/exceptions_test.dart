import 'package:flutter_test/flutter_test.dart';
import 'package:kegiatin/core/errors/exceptions.dart';

void main() {
  group('ServerException', () {
    test('stores message and statusCode', () {
      const exception = ServerException('Internal error', statusCode: 500);
      expect(exception.message, 'Internal error');
      expect(exception.statusCode, 500);
    });

    test('statusCode is null when not provided', () {
      const exception = ServerException('Error');
      expect(exception.statusCode, isNull);
    });
  });

  group('UnauthorizedException', () {
    test('default message is Unauthorized', () {
      const exception = UnauthorizedException();
      expect(exception.message, 'Unauthorized');
    });

    test('custom message', () {
      const exception = UnauthorizedException('Token expired');
      expect(exception.message, 'Token expired');
    });
  });

  group('CacheException', () {
    test('stores message', () {
      const exception = CacheException('Cache not found');
      expect(exception.message, 'Cache not found');
    });
  });
}
