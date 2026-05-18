class UserSummary {
  final String id;
  final String displayName;
  final String? npa;
  final String? cabang;
  final String? photoUrl;

  const UserSummary({
    required this.id,
    required this.displayName,
    this.npa,
    this.cabang,
    this.photoUrl,
  });
}
