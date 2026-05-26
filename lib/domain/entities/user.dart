import 'package:kegiatin/domain/enums/user_role.dart';

class User {
  final String id;
  final String email;
  final String displayName;
  final UserRole role;
  final String? npa;
  final String? cabang;
  final String? photoUrl;
  final bool emailVerified;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.email,
    required this.displayName,
    required this.role,
    this.npa,
    this.cabang,
    this.photoUrl,
    required this.emailVerified,
    required this.createdAt,
  });
}
