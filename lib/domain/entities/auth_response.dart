import 'package:kegiatin/domain/entities/user.dart';

class AuthResponse {
  final User user;
  final String accessToken;
  final String refreshToken;

  const AuthResponse({required this.user, required this.accessToken, required this.refreshToken});
}
