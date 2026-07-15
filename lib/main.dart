import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/network/supabase_client_provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Object? initError;
  try {
    await initSupabase();
  } catch (e, st) {
    initError = e;
    debugPrint('Supabase init failed: $e\n$st');
  }

  runApp(
    ProviderScope(
      child: initError != null
          ? _ErrorApp(error: initError)
          : const StockProApp(),
    ),
  );
}

/// Shows the actual crash reason on-screen instead of a blank page —
/// temporary debugging aid until we confirm the real cause.
class _ErrorApp extends StatelessWidget {
  final Object? error;
  const _ErrorApp({required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'App failed to start:\n\n$error',
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}

class StockProApp extends ConsumerWidget {
  const StockProApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'StockPro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}