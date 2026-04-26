import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kegiatin/app.dart';
import 'package:kegiatin/core/constants/db_constants.dart';
import 'package:kegiatin/presentation/providers/providers.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  await Hive.initFlutter();
  final authBox = await Hive.openBox(DbConstants.authBox);
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        authBoxProvider.overrideWithValue(authBox),
      ],
      child: const MyApp(),
    ),
  );
}
