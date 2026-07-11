import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/config/supabase_config.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/app_user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/sign_in_with_email.dart';

// --- Dependency wiring ------------------------------------------------
// This is the ONLY place these concrete classes get instantiated.
// Everything else asks Riverpod for the abstraction.

final _authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(SupabaseConfig.client);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.watch(_authRemoteDataSourceProvider),
    SupabaseConfig.client,
  );
});

final signInWithEmailProvider = Provider<SignInWithEmail>((ref) {
  return SignInWithEmail(ref.watch(authRepositoryProvider));
});

// --- App-wide auth state -----------------------------------------------
// Watched by app_router.dart to decide whether to show /login or /dashboard.
final authStateProvider = StreamProvider<AppUserEntity?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

// --- Login screen's own ViewModel ---------------------------------------
// Separate from authStateProvider: this one tracks the *form submission*
// state (loading / error while the user is mid-login), not the app-wide
// "am I logged in" state, which is what authStateProvider is for.
final loginViewModelProvider =
    AsyncNotifierProvider<LoginViewModel, void>(LoginViewModel.new);

class LoginViewModel extends AsyncNotifier<void> {
  @override
  Future<void> build() async {} // idle state

  Future<void> signInWithEmail(String email, String password) async {
    state = const AsyncLoading();
    final result = await ref.read(signInWithEmailProvider).call(
          email: email,
          password: password,
        );
    state = result.when(
      success: (_) => const AsyncData(null),
      failure: (f) => AsyncError(f.message, StackTrace.current),
    );
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    final result = await ref.read(authRepositoryProvider).signInWithGoogle();
    state = result.when(
      success: (_) => const AsyncData(null),
      failure: (f) => AsyncError(f.message, StackTrace.current),
    );
  }
}
