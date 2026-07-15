class WarehouseEntity {
  final String id;
  final String name;
  final bool isDefault;

  const WarehouseEntity({
    required this.id,
    required this.name,
    this.isDefault = false,
  });
}