import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:kegiatin/presentation/controllers/auth/auth_controller.dart';
import 'package:kegiatin/presentation/pages/home_page.dart';
import 'package:kegiatin/presentation/pages/login_page.dart';
import 'package:kegiatin/presentation/pages/register_page.dart';
import 'package:kegiatin/presentation/pages/splash_page.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(Ref ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isLoading = authState.isLoading;
      final user = authState.value;
      final isLoggedIn = user != null;
      final isAuthRoute = state.matchedLocation == '/login' || state.matchedLocation == '/register';

      if (isLoading) return '/splash';
      if (!isLoggedIn && !isAuthRoute) return '/login';
      if (isLoggedIn && isAuthRoute) return '/';

      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashPage()),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterPage()),
      GoRoute(path: '/', builder: (context, state) => const HomePage()),
    ],
  );
}
