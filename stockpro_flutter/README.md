# StockPro — Flutter Client (Phase 2 Scaffold)

This is the Phase 2 deliverable from the roadmap in `01_PRD.md`: the Flutter
project structure, wired for Clean Architecture + MVVM + Riverpod +
Supabase, with the **auth feature fully implemented end-to-end** as a
worked example, and every other module stubbed with a `README.md`
explaining exactly what to build there in Phase 4+.

## Why the auth feature is complete but nothing else is

You learn a layered architecture by seeing one full vertical slice, not by
seeing ten empty folders. Auth was chosen because it touches every layer
(entity, repository contract, use case, remote datasource, repository impl,
Riverpod providers, a ViewModel, and a widget) while staying conceptually
simple. Once this makes sense, `lib/features/products/README.md` (and the
other five) tell you exactly how to repeat the pattern.

## How to run this (once you have a Supabase project)

1. Run `02_database_schema.sql` against a fresh Supabase Postgres database
   (SQL Editor in the Supabase dashboard, or `supabase db push` via CLI).
2. Copy `.env.example` to `.env` and fill in your project's URL and anon key.
3. `flutter pub get`
4. `flutter run`

You'll land on the login screen; signing in requires a row in `app_users`
matching a Supabase Auth user (create one via Supabase Auth, then insert
the matching `app_users` + `user_roles` rows per the schema).

## Folder structure

```
lib/
  core/                     # Shared across all features — no feature imports this
    config/                 # Supabase init, env loading
    theme/                  # AppColors + light/dark ThemeData (Material 3)
    router/                 # go_router config with auth-based redirect guard
    utils/                  # Result<T> + Failure types (shared error handling)
    widgets/                # LoadingIndicator, ErrorView — reused by every screen

  features/
    auth/                   # ✅ Fully implemented — the reference pattern
      domain/                 entities, repository contract, use case
      data/                    models, remote datasource, repository impl
      presentation/            Riverpod providers, screens, widgets
    dashboard/               # Partial — provider stub + working UI shell (Phase 9 fills in real queries)
    products/                # 📋 Stub — see README.md inside
    inventory/                # 📋 Stub
    purchases/                # 📋 Stub
    sales/                    # 📋 Stub
    vendors/                  # 📋 Stub
    customers/                # 📋 Stub
    payments/                 # 📋 Stub

test/
  features/auth/            # Example unit test — use case tested with a mock repository, no backend needed
```

## The pattern, in one sentence per layer

- **`domain/entities`** — plain Dart, describes *what a thing is*, knows nothing about Supabase.
- **`domain/repositories`** — an abstract interface describing *what operations exist*, not how they're done.
- **`domain/usecases`** — optional; worth it once an operation is more than one repository call.
- **`data/models`** — extends the entity, adds `fromJson`/`toJson` matching the actual Postgres row shape.
- **`data/datasources`** — the only place that calls `Supabase.instance.client` directly.
- **`data/repositories`** — implements the domain contract, translates Supabase exceptions into `Failure` types.
- **`presentation/providers`** — Riverpod `Provider`s wire the concrete classes together; `AsyncNotifier`s hold per-screen state.
- **`presentation/screens` / `widgets`** — dumb, reactive to provider state, no business logic.

## Next phase

Phase 3 in the roadmap: build out the Company Setup + full RBAC screens on
top of the `companies` / `roles` / `permissions` tables, using this exact
pattern. After that, Phase 4 (Products) is the first "real" business
module and the template every remaining feature folder follows.
