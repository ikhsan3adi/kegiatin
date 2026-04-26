import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kegiatin/core/router/app_router.dart';
import 'package:kegiatin/core/theme/theme.dart';
import 'package:kegiatin/core/theme/util.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final brightness = View.of(context).platformDispatcher.platformBrightness;
    final textTheme = createTextTheme(context, 'Inter', 'Alumni Sans');
    final theme = MaterialTheme(textTheme);

    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Kegiatin',
      debugShowCheckedModeBanner: false,
      theme: theme.light(),
      // theme: brightness == Brightness.light ? theme.light() : theme.dark(),
      routerConfig: router,
    );
  }
}
