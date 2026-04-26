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

      // Still resolving auth state
      if (isLoading) {
        // Already on splash, auth, or onboarding → stay put
        if (isSplash || isAuth || isOnboarding) return null;
        // Anywhere else during loading → show splash
        return '/splash';
      }

      // Auth resolved, user is logged in → redirect away from guest-only pages
      if (isLoggedIn && (isSplash || isAuth || isOnboarding)) return '/';

      // Auth resolved, not logged in, already on auth/onboarding → stay
      if (!isLoggedIn && (isAuth || isOnboarding)) return null;

      // Auth resolved, not logged in, on splash → check onboarding
      if (!isLoggedIn && isSplash) {
        final hasSeenOnboarding = ref.read(hasSeenOnboardingSyncProvider);
        return hasSeenOnboarding ? '/login' : '/onboarding';
      }

      // Auth resolved, not logged in, trying to access protected route
      if (!isLoggedIn) return '/login';

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
