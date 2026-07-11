/// Central place for Supabase initialization.
///
/// Why this file exists on its own: nothing outside `core/config` should
/// know the Supabase URL/anon key, or even that Supabase is the backend.
/// Repositories in `features/*/data` depend on `Supabase.instance.client`,
/// which is a deliberate, contained exception to strict Clean Architecture
/// layering — acceptable because "swap the backend" is a data-layer-only
/// change either way.
library;

import 'package:supabase_flutter/supabase_flutter.dart';
import 'env.dart';

class SupabaseConfig {
  SupabaseConfig._();

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabaseAnonKey,
      debug: Env.isDebug,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
