import 'package:flutter/material.dart';
import 'package:kegiatin/domain/enums/user_role.dart';

/// Card header profil — menampilkan avatar, nama, NPA, dan badge peran.
///
/// Dirancang untuk ditempatkan di dalam container bergradien (AppBar).
/// Latar belakang semi-transparan agar gradien di belakangnya tetap terlihat.
class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({
    super.key,
    required this.displayName,
    required this.role,
    this.npa,
    this.photoUrl,
  });

  /// Nama tampilan pengguna.
  final String displayName;

  /// Peran pengguna dalam sistem.
  final UserRole role;

  /// Nomor pokok anggota — hanya tersedia untuk anggota organisasi.
  final String? npa;

  /// URL foto profil — bila null, inisial nama ditampilkan sebagai fallback.
  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // Card semi-transparan — gradien AppBar di belakangnya masih terlihat.
    const cardBg = Color(0x26FFFFFF);   // white 15% opacity
    const cardBorder = Color(0x40FFFFFF); // white 25% opacity

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorder, width: 1),
      ),
      child: Row(
        children: [
          _Avatar(photoUrl: photoUrl, displayName: displayName),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  displayName,
                  style: textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (npa != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'NPA-$npa',
                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                _RoleBadge(role: role),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Avatar bundar dengan foto atau inisial fallback.
class _Avatar extends StatelessWidget {
  const _Avatar({required this.photoUrl, required this.displayName});

  final String? photoUrl;
  final String displayName;

  String get _initials {
    final parts = displayName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0x33FFFFFF), // white 20% opacity
        border: Border.all(color: const Color(0x66FFFFFF), width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: photoUrl != null
          ? Image.network(
              photoUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _InitialsFallback(_initials),
            )
          : _InitialsFallback(_initials),
    );
  }
}

class _InitialsFallback extends StatelessWidget {
  const _InitialsFallback(this.initials);
  final String initials;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        initials,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

/// Badge kecil yang menampilkan label peran pengguna.
class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role});
  final UserRole role;

  String get _label => switch (role) {
        UserRole.admin => 'Admin',
        UserRole.member => 'Anggota',
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0x33FFFFFF), // white 20% opacity
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x59FFFFFF)), // white 35%
      ),
      child: Text(
        _label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
