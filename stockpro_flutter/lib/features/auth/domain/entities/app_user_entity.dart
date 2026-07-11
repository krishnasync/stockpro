/// Domain entity — plain Dart, zero Supabase/JSON knowledge. This is what
/// ViewModels and widgets work with. Compare to AppUserModel in the data
/// layer, which knows how to (de)serialize from Postgres rows.
class AppUserEntity {
  final String id;
  final String companyId;
  final String fullName;
  final String email;
  final String? phone;
  final String? avatarUrl;
  final List<String> roleNames; // e.g. ['Admin', 'Sales Executive']

  const AppUserEntity({
    required this.id,
    required this.companyId,
    required this.fullName,
    required this.email,
    this.phone,
    this.avatarUrl,
    this.roleNames = const [],
  });

  bool hasRole(String role) => roleNames.contains(role);
}
