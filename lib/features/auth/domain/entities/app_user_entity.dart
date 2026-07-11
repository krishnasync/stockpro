/// Domain entity — plain Dart, zero Supabase/JSON knowledge. This is what
/// the UI and business logic work with. Mapping from Supabase's raw JSON
/// happens only in the data layer (see auth_remote_datasource.dart).
class AppUserEntity {
  final String id;
  final String companyId;
  final String fullName;
  final String email;
  final String? phone;
  final String? avatarUrl;
  final List<String> roleNames;
  final List<String> permissionCodes;

  const AppUserEntity({
    required this.id,
    required this.companyId,
    required this.fullName,
    required this.email,
    this.phone,
    this.avatarUrl,
    this.roleNames = const [],
    this.permissionCodes = const [],
  });

  bool hasPermission(String code) => permissionCodes.contains(code);

  bool get isSuperAdmin => roleNames.contains('Super Admin');
}
