import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kegiatin/presentation/controllers/auth/auth_controller.dart';

/// Placeholder home page — akan diganti dengan dashboard di sprint berikutnya.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kegiatin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
      body: Center(
        child: authState.when(
          data: (user) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_outline, size: 64, color: colorScheme.primary),
              const SizedBox(height: 16),
              Text('Selamat datang, ${user?.displayName ?? '-'}'),
              const SizedBox(height: 8),
              Text(user?.email ?? '', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          loading: () => const CircularProgressIndicator(),
          error: (e, _) => Text('Error: $e'),
        ),
      ),
    );
  }
}
