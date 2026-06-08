import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kegiatin/presentation/pages/admin/event_detail/admin_event_detail_page.dart';
import 'package:kegiatin/presentation/pages/admin/create_event/create_event_page.dart';
import 'package:kegiatin/presentation/pages/admin/edit_event/edit_event_page.dart';
import 'package:kegiatin/presentation/pages/admin/qr_scan_page.dart';
import 'package:kegiatin/presentation/pages/edit_profile_page.dart';
import 'package:kegiatin/presentation/pages/peserta/widget/navbar_peserta.dart';
import 'package:kegiatin/presentation/pages/peserta/event_detail/peserta_event_detail_page.dart';
import 'package:kegiatin/presentation/pages/peserta/qr_display/qr_display_page.dart';
import 'package:kegiatin/presentation/pages/admin/widget/navbar_admin.dart';
import 'package:kegiatin/presentation/pages/login_page.dart';
import 'package:kegiatin/presentation/pages/onboarding_page.dart';
import 'package:kegiatin/presentation/pages/register_page.dart';
import 'package:kegiatin/presentation/pages/splash_page.dart';

class TestNavigatorObserver extends NavigatorObserver {
  final List<Route<dynamic>> pushedRoutes = [];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushedRoutes.add(route);
    super.didPush(route, previousRoute);
  }
}

/// Helper to construct a GoRouter instance that mirrors the production routes
/// but can be injected with custom redirect logic or observers for testing.
GoRouter createTestRouter({
  String initialLocation = '/',
  GoRouterRedirect? redirect,
  List<NavigatorObserver>? observers,
}) {
  return GoRouter(
    initialLocation: initialLocation,
    redirect: redirect,
    observers: observers,
    routes: [
      GoRoute(path: '/', builder: (_, _) => const SplashPage()),
      GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingPage()),
      GoRoute(path: '/login', builder: (_, _) => const LoginPage()),
      GoRoute(path: '/register', builder: (_, _) => const RegisterPage()),
      GoRoute(
        path: '/admin',
        builder: (_, _) => const NavbarAdmin(),
        routes: [
          GoRoute(path: 'create-event', builder: (_, _) => const CreateEventPage()),
          GoRoute(
            path: 'event-edit/:eventId',
            builder: (context, state) => EditEventPage(eventId: state.pathParameters['eventId']!),
          ),
          GoRoute(
            path: 'event-detail/:eventId',
            builder: (context, state) =>
                AdminEventDetailPage(eventId: state.pathParameters['eventId']!),
          ),
          GoRoute(path: 'scan', builder: (_, _) => const QrScanPage()),
          GoRoute(path: 'edit-profile', builder: (_, _) => const EditProfilePage()),
        ],
      ),
      GoRoute(
        path: '/peserta',
        builder: (_, _) => const NavbarPeserta(),
        routes: [
          GoRoute(
            path: 'event-detail/:eventId',
            builder: (context, state) =>
                PesertaEventDetailPage(eventId: state.pathParameters['eventId']!),
          ),
          GoRoute(path: 'edit-profile', builder: (_, _) => const EditProfilePage()),
          GoRoute(
            path: 'qr/:eventId',
            builder: (context, state) =>
                PesertaQrDisplayPage(eventId: state.pathParameters['eventId']!),
          ),
        ],
      ),
    ],
  );
}
