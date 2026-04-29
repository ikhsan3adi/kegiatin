import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:kegiatin/presentation/controllers/auth/auth_controller.dart';
import 'package:kegiatin/presentation/pages/home_page.dart';
import 'package:kegiatin/presentation/pages/login_page.dart';
import 'package:kegiatin/presentation/pages/onboarding_page.dart';
import 'package:kegiatin/presentation/pages/register_page.dart';
import 'package:kegiatin/presentation/pages/splash_page.dart';
import 'package:kegiatin/presentation/providers/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final refreshNotifier = ValueNotifier<int>(0);

  ref.listen(authControllerProvider, (_, _) {
    refreshNotifier.value++;
  });

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);
      final location = state.matchedLocation;

      final isLoading = authState.isLoading;
      final isLoggedIn = authState.value != null;

      final isSplash = location == '/splash';
      final isAuth = location == '/login' || location == '/register';
      final isOnboarding = location == '/onboarding';

      if (isLoading) {
        if (isSplash || isAuth || isOnboarding) return null;
        return '/splash';
      }

      // Auth resolved, user is logged in → redirect away from guest-only pages 
      // (isSplash dihapus dari sini agar tidak otomatis hilang)
      if (isLoggedIn && (isAuth || isOnboarding)) return '/';

      if (!isLoggedIn && (isAuth || isOnboarding)) return null;

      // Blok kode pengecekan "hasSeenOnboarding" saat di splash DIHAPUS 
      // dan dipindahkan ke dalam logic splash_page.dart agar bisa menunggu 3 detik.

      // Auth resolved, not logged in, trying to access protected route
      // (Tambahkan pengecualian isSplash agar tetap bisa diam di halaman splash)
      if (!isLoggedIn && !isSplash) return '/login';

      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const SplashPage()),
      GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingPage()),
      GoRoute(path: '/login', builder: (_, _) => const LoginPage()),
      GoRoute(path: '/register', builder: (_, _) => const RegisterPage()),
      GoRoute(path: '/', builder: (_, _) => const HomePage()),
    ],
  );
}