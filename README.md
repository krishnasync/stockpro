# StockPro — Flutter Scaffold (Phase 2)

This is the Clean Architecture / MVVM / Riverpod scaffold described in
`01_PRD.md` (Phase 1), wired to the schema in `02_database_schema.sql`.

## What's actually implemented here

Two features are built out **completely**, end to end, as reference
patterns:

- **`features/auth`** — email sign-in, Google OAuth stub, OTP stub,
  password reset stub, full domain/data/presentation split, wired into
  `go_router` with auth-based redirects.
- **`features/products`** — product list with search, low-stock badges,
  same layer split.

Every other feature folder (`inventory`, `vendors`, `sales`, `dashboard`)
exists with the correct folder shape but is either empty or a placeholder
screen. **They are meant to be filled in by copying the `products` pattern
below**, not written from scratch each time.

## The pattern to copy for every new feature

```
features/<feature>/
  domain/
    entities/<thing>_entity.dart        <- plain Dart, no Supabase imports
    repositories/<thing>_repository.dart <- abstract interface (the contract)
  data/
    datasources/<thing>_remote_datasource.dart <- ONLY file with Supabase calls
    repositories/<thing>_repository_impl.dart  <- try/catch -> Result<T>/Failure
  presentation/
    providers/<thing>_provider.dart     <- Riverpod DI chain + ViewModel(s)
    screens/<thing>_screen.dart         <- dumb View, reads providers only
    widgets/                            <- reusable pieces of that screen
```

Rule of thumb: if you're about to write `Supabase.instance.client` or
`.from('table_name')` anywhere outside a `data/datasources/` file, stop —
that logic belongs in a datasource, not in a provider or a screen.

## Running it

```bash
flutter pub get
flutter run \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
```

You'll need to actually run `02_database_schema.sql` against a Supabase
project first (SQL Editor → paste → Run), then create at least one
`companies` row, one `auth.users` row (via Supabase Auth), and a matching
`app_users` row before login will return a real profile.

One thing the schema doesn't give you for free: `product_stock_summary`,
the view `product_remote_datasource.dart` queries. Add it as a migration
before running the Products screen:

```sql
create view product_stock_summary as
select
  p.*,
  coalesce(sum(sl.quantity), 0) as current_stock
from products p
left join stock_levels sl on sl.product_id = p.id
group by p.id;
```

## What's next (per the PRD roadmap)

- **Phase 3**: flesh out Company Setup + full RBAC screens (roles/permissions
  management UI) — the tables already exist in the schema.
- **Phase 4**: finish the Products feature (create/edit form, image upload
  to Supabase Storage, barcode scan-to-fill via `mobile_scanner`).
- **Phase 5**: Inventory & Warehouse module, including the offline-first
  Drift local cache mentioned in `pubspec.yaml` — this is the module where
  offline support actually matters (see PRD §6).

Ask for any of these next and I'll build it directly on top of this
scaffold, following the same pattern.
