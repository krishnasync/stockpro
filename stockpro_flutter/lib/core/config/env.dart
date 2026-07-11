/// Reads environment configuration from `.env` (via flutter_dotenv).
/// Never commit a real `.env` file — ship `.env.example` instead.
library;

import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  Env._();

  static String get supabaseUrl => dotenv.get('SUPABASE_URL');
  static String get supabaseAnonKey => dotenv.get('SUPABASE_ANON_KEY');
  static bool get isDebug => dotenv.get('APP_ENV', fallback: 'debug') == 'debug';
}
