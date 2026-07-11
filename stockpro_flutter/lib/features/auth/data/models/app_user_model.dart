import '../../domain/entities/app_user_entity.dart';

/// Data-layer model — knows how to parse the shape returned by our
/// `app_users` table joined with roles (see 02_database_schema.sql,
/// Section 1). Converts to/from the plain domain entity at the
/// repository boundary so nothing upstream depends on this shape.
class AppUserModel extends AppUserEntity {
  const AppUserModel({
    required super.id,
    required super.companyId,
    required super.fullName,
    required super.email,
    super.phone,
    super.avatarUrl,
    super.roleNames,
  });

  factory AppUserModel.fromJson(Map<String, dynamic> json) {
    final roles = (json['user_roles'] as List<dynamic>? ?? [])
        .map((r) => r['roles']?['name'] as String?)
        .whereType<String>()
        .toList();

    return AppUserModel(
      id: json['id'] as String,
      companyId: json['company_id'] as String,
      fullName: json['full_name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      roleNames: roles,
    );
  }
}
