sealed class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => '$runtimeType: $message';
}

class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure(super.message, {this.statusCode});
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection']);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

extension FailureMessageExtension on Object {
  String get cleanMessage {
    String msg = toString();
    if (this is Failure) {
      msg = (this as Failure).message;
    }
    return msg.replaceAll(RegExp(r'^[a-zA-Z]+Failure:\s*'), '').trim();
  }
}
