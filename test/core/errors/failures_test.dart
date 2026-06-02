import 'package:flutter_test/flutter_test.dart';
import 'package:kegiatin/core/errors/failures.dart';

void main() {
  group('ServerFailure', () {
    test('toString() includes statusCode', () {
      const failure = ServerFailure('Server error', statusCode: 500);
      expect(failure.toString(), 'ServerFailure: Server error');
      expect(failure.statusCode, 500);
    });

    test('toString() without statusCode', () {
      const failure = ServerFailure('Not found');
      expect(failure.toString(), 'ServerFailure: Not found');
      expect(failure.statusCode, isNull);
    });
  });

  group('NetworkFailure', () {
    test('default message is No internet connection', () {
      const failure = NetworkFailure();
      expect(failure.message, 'No internet connection');
    });

    test('custom message', () {
      const failure = NetworkFailure('Custom error');
      expect(failure.message, 'Custom error');
    });
  });

  group('FailureMessageExtension.cleanMessage', () {
    test('strip prefix from ServerFailure', () {
      const failure = ServerFailure('Something went wrong');
      expect(failure.cleanMessage, 'Something went wrong');
    });

    test('strip prefix from NetworkFailure', () {
      const failure = NetworkFailure('No internet');
      expect(failure.cleanMessage, 'No internet');
    });

    test('strip prefix from AuthFailure', () {
      const failure = AuthFailure('Wrong credentials');
      expect(failure.cleanMessage, 'Wrong credentials');
    });

    test('strip prefix from CacheFailure', () {
      const failure = CacheFailure('Cache miss');
      expect(failure.cleanMessage, 'Cache miss');
    });

    test('return raw toString() on non-Failure', () {
      const error = 'Plain string error';
      expect(error.cleanMessage, 'Plain string error');
    });
  });
}
