import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kegiatin/core/theme/custom.dart';
import 'package:kegiatin/domain/entities/user.dart';
import 'package:kegiatin/domain/enums/user_role.dart';
import 'package:kegiatin/presentation/controllers/auth/auth_controller.dart';
import 'package:kegiatin/presentation/providers/providers.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    _startSplashSequence();
  }

  // LOGIC: Bagian ini tetap sama agar program tidak rusak
  Future<void> _startSplashSequence() async {
    // Jalankan timer splash dan inisialisasi auth secara paralel.
    // Ini memastikan splash tampil minimal 5 detik, tapi juga menunggu
    // hingga status auth benar-benar ter-resolve (tidak mengandalkan .value yang bisa null saat loading).
    final results = await Future.wait([
      Future.delayed(const Duration(seconds: 2, milliseconds: 500)),
      ref.read(authControllerProvider.future),
    ]);

    if (!mounted) return;

    final user = results[1] as User?;
    final isLoggedIn = user != null;
    final hasSeenOnboarding = ref.read(hasSeenOnboardingSyncProvider);

    if (isLoggedIn) {
      if (user.role == UserRole.admin) {
        context.go('/admin');
      } else {
        context.go('/peserta');
      }
    } else if (hasSeenOnboarding) {
      context.go('/login');
    } else {
      context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final Color brandColor = colorScheme.primary;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;
          // Ukuran responsif berdasarkan dimensi layar
          final logoSize = (w * 0.35).clamp(100.0, 260.0);
          final fontSize = (w * 0.075).clamp(22.0, 34.0);
          final starSize = (w * 0.06).clamp(16.0, 28.0);

          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  KegiatinCustomTheme.splashTop,
                  colorScheme.surface,
                  colorScheme.surface,
                  KegiatinCustomTheme.splashBottom,
                ],
                stops: const [0.0, 0.25, 0.75, 1.0],
              ),
            ),
            child: SafeArea(
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    // Konten utama (logo + teks + garis)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/logo_kegiatin.png',
                          width: logoSize,
                          height: logoSize,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(height: h * 0.02),
                        IntrinsicWidth(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'KEGIATIN',
                                  maxLines: 1,
                                  softWrap: false,
                                  textAlign: TextAlign.center,
                                  style: textTheme.displayMedium?.copyWith(
                                    fontSize: fontSize,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 2.5,
                                    color: brandColor,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Divider(color: brandColor, thickness: 3, height: 3),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Bintang atas (di atas logo, center)
                    Positioned(
                      top: -(logoSize * 0.3),
                      child: _buildStar(starSize * 0.75, brandColor.withValues(alpha: 0.25)),
                    ),
                    // Bintang kiri (sejajar tengah logo)
                    Positioned(
                      left: -(w * 0.12),
                      top: logoSize * 0.15,
                      child: _buildStar(starSize, brandColor.withValues(alpha: 0.3)),
                    ),
                    // Bintang kanan (sejajar tengah logo, simetris dengan kiri)
                    Positioned(
                      right: -(w * 0.12),
                      top: logoSize * 0.15,
                      child: _buildStar(starSize, brandColor.withValues(alpha: 0.3)),
                    ),
                    // Bintang bawah (di bawah garis, center)
                    Positioned(
                      bottom: -(h * 0.070),
                      child: _buildStar(starSize * 0.75, brandColor.withValues(alpha: 0.25)),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Widget bintang dekoratif
  Widget _buildStar(double size, Color color) {
    return Icon(Icons.star_rounded, size: size, color: color);
  }
}
