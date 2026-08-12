import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/models.dart';
import 'providers/groups_provider.dart';
import 'theme/app_theme.dart';
import 'utils/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait (natural for a mobile expense app)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF07070C),
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  // Initialize Hive
  await Hive.initFlutter();

  // Register adapters
  Hive.registerAdapter(MemberAdapter());
  Hive.registerAdapter(ItemShareAdapter());
  Hive.registerAdapter(SplitItemAdapter());
  Hive.registerAdapter(SplitSessionAdapter());
  Hive.registerAdapter(GroupAdapter());

  // Open boxes
  await Hive.openBox<Group>('groups');
  await Hive.openBox<String>('prefs');

  runApp(
    const ProviderScope(
      child: SplitsApp(),
    ),
  );
}

class SplitsApp extends ConsumerWidget {
  const SplitsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'Splits',
      debugShowCheckedModeBanner: false,
      theme: SplitsTheme.light(),
      darkTheme: SplitsTheme.dark(),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      routerConfig: router,
    );
  }
}
