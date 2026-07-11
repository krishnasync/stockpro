import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/network/supabase_client_provider.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/app_user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

// --- Dependency injection chain -------------------------------------------
// supabaseClientProvider -> datasource -> repository -> ViewModel
// Each layer only depends on the one below it via Riverpod, never
// instantiated directly. This is what makes it possible to override
// authRepositoryProvider with a fake in widget tests.

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(ref.watch(supabaseClientProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(authRemoteDataSourceProvider));
});

/// Holds the currently signed-in user (or null). Screens watch this to
/// decide what to render; the router (Phase 2 core/router) watches it to
/// decide whether to redirect to /login.
final currentUserProvider =
    AsyncNotifierProvider<CurrentUserNotifier, AppUserEntity?>(
  CurrentUserNotifier.new,
);

class CurrentUserNotifier extends AsyncNotifier<AppUserEntity?> {
  @override
  Future<AppUserEntity?> build() async {
    // React to Supabase auth state changes (sign in/out from anywhere).
    ref.listen(authStateChangesProvider, (previous, next) {
      next.whenData((_) => refresh());
    });
    return ref.read(authRepositoryProvider).getCurrentUser();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await ref.read(authRepositoryProvider).getCurrentUser());
  }
}

/// ViewModel for the Login screen specifically — holds form submission
/// state (loading/error) separately from "who is the current user" above.
/// This separation means the login button's spinner doesn't get tangled
/// with the app-wide auth state.
final loginViewModelProvider =
    AsyncNotifierProvider.autoDispose<LoginViewModel, void>(
  LoginViewModel.new,
);

class LoginViewModel extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<Failure?> signInWithEmail(String email, String password) async {
    state = const AsyncLoading();
    final result = await ref
        .read(authRepositoryProvider)
        .signInWithEmail(email: email, password: password);

    return result.when(
      success: (_) {
        state = const AsyncData(null);
        ref.invalidate(currentUserProvider);
        return null;
      },
      failure: (f) {
        state = AsyncError(f, StackTrace.current);
        return f;
      },
    );
  }
}
