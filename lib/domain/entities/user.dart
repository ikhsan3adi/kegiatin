import 'package:kegiatin/domain/enums/user_role.dart';

/// Entitas pengguna — single source of truth untuk data profil.
///
/// Berlaku untuk Admin maupun Member (Anggota/Non-Anggota).
/// Field [npa] dan [cabang] hanya terisi untuk anggota organisasi.
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
