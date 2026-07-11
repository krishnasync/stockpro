import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stockpro/core/utils/result.dart';
import 'package:stockpro/features/auth/domain/entities/app_user_entity.dart';
import 'package:stockpro/features/auth/domain/repositories/auth_repository.dart';
import 'package:stockpro/features/auth/domain/usecases/sign_in_with_email.dart';

/// This is the payoff of Clean Architecture for a learning project: the
/// use case is tested with zero Supabase, zero widget tree, zero network —
/// just a fake repository. Compare how little setup this needs to what
/// a widget test hitting a real Supabase backend would require.
class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;
  late SignInWithEmail useCase;

  setUp(() {
    repository = MockAuthRepository();
    useCase = SignInWithEmail(repository);
  });

  test('returns AppUserEntity on successful sign in', () async {
    const user = AppUserEntity(
      id: 'u1',
      companyId: 'c1',
      fullName: 'Test User',
      email: 'test@example.com',
    );
    when(() => repository.signInWithEmail(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => const Result.success(user));

    final result = await useCase(email: 'test@example.com', password: 'secret123');

    result.when(
      success: (data) => expect(data.email, 'test@example.com'),
      failure: (_) => fail('expected success'),
    );
  });
}
