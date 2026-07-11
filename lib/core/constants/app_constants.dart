/// App-wide constants. Keep this file free of business logic — just values.
class AppConstants {
  AppConstants._();

  static const String appName = 'StockPro';

  // Supabase — read from --dart-define at build time, never hardcoded.
  // flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY');

  // Pagination
  static const int defaultPageSize = 25;

  // Local DB
  static const String localDbName = 'stockpro_local.sqlite';
}

/// Central place for permission code strings, mirroring the `permissions`
/// table in the DB schema (Phase 1). Keeping these as constants avoids
/// stringly-typed typos scattered across the UI layer.
class PermissionCodes {
  PermissionCodes._();

  static const String productCreate = 'product.create';
  static const String productEdit = 'product.edit';
  static const String productDelete = 'product.delete';

  static const String purchaseApprove = 'purchase.approve';
  static const String purchaseCreate = 'purchase.create';

  static const String salesCreate = 'sales.create';
  static const String salesDiscount = 'sales.discount';

  static const String inventoryAdjust = 'inventory.adjust';
  static const String inventoryTransfer = 'inventory.transfer';

  static const String reportsView = 'reports.view';
  static const String settingsManage = 'settings.manage';
}
