import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/supabase_config.dart';

/// Placeholder for Phase 9. Real implementation will query SQL views
/// built on top of stock_levels, invoices, and payments (see
/// 02_database_schema.sql) — e.g. a `dashboard_summary` view returning
/// today's sales/purchases/stock value in one round trip, rather than
/// the client computing aggregates from raw tables.
final dashboardSummaryProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final client = SupabaseConfig.client;
  // Example of the eventual query shape:
  // return await client.from('dashboard_summary').select().single();
  return {
    'today_sales': 0,
    'today_purchases': 0,
    'low_stock_count': 0,
  }; // stub until Phase 9
});
