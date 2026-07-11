# inventory — Phase 4+ (not yet implemented)

Follow the exact pattern established in `lib/features/auth`:

```
inventory/
  domain/
    entities/        # plain Dart classes
    repositories/     # abstract contracts
    usecases/         # optional, for multi-step orchestration
  data/
    models/           # fromJson/toJson mapped to schema tables
    datasources/       # the only files that import supabase_flutter
    repositories/       # implements domain contracts, maps exceptions -> Failure
  presentation/
    providers/         # Riverpod wiring + AsyncNotifier ViewModels
    screens/
    widgets/
```

Relevant tables from `02_database_schema.sql`:
- warehouses, warehouse_locations, stock_levels, stock_movements, stock_transfers, stock_adjustments
