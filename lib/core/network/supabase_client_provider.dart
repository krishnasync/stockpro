import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/app_constants.dart';

/// Call once in main() before runApp(). This is the ONLY place
/// Supabase.initialize should be called.
Future<void> initSupabase() async {
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
    // Persists the session locally so users aren't logged out on app restart.
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );
}

/// The single shared SupabaseClient instance. Every data source in every
/// feature reads this provider instead of calling Supabase.instance.client
/// directly — this indirection is what makes repositories mockable/testable
/// (override this provider in tests with a fake client).
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Emits auth state changes (sign in / sign out / token refresh) so any
/// widget in the tree can react — e.g. the router redirects to /login
/// automatically when this stream emits a signed-out state.
final authStateChangesProvider = StreamProvider<AuthState>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client.auth.onAuthStateChange;
});
