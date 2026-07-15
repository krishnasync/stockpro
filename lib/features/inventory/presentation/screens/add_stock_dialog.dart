import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../products/presentation/providers/product_provider.dart';
import '../providers/inventory_provider.dart';

/// Call via showDialog(context: context, builder: (_) => AddStockDialog(productId: ...))
class AddStockDialog extends ConsumerStatefulWidget {
  final String productId;
  final String productName;
  const AddStockDialog(
      {super.key, required this.productId, required this.productName});

  @override
  ConsumerState<AddStockDialog> createState() => _AddStockDialogState();
}

class _AddStockDialogState extends ConsumerState<AddStockDialog> {
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();
  String? _selectedWarehouseId;
  bool _isSaving = false;

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final quantity = double.tryParse(_quantityController.text);
    if (quantity == null || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid quantity')),
      );
      return;
    }
    if (_selectedWarehouseId == null) return;

    setState(() => _isSaving = true);

    final result = await ref.read(inventoryRepositoryProvider).addStock(
          productId: widget.productId,
          warehouseId: _selectedWarehouseId!,
          quantity: quantity,
          movementType: 'IN',
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        );

    if (!mounted) return;
    setState(() => _isSaving = false);

    result.when(
      success: (_) {
        // Refresh the product list so the updated stock count shows up.
        ref.invalidate(productListProvider);
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Stock added')),
        );
      },
      failure: (f) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(f.message)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final warehousesAsync = ref.watch(warehousesProvider);

    return AlertDialog(
      title: Text('Add Stock — ${widget.productName}'),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            warehousesAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, _) => Text('Failed to load warehouses: $err'),
              data: (warehouses) {
                _selectedWarehouseId ??=
                    warehouses.isNotEmpty ? warehouses.first.id : null;
                return DropdownButtonFormField<String>(
                  initialValue: _selectedWarehouseId,
                  decoration: const InputDecoration(labelText: 'Warehouse'),
                  items: warehouses
                      .map((w) => DropdownMenuItem(
                            value: w.id,
                            child: Text(w.name),
                          ))
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _selectedWarehouseId = value),
                );
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _quantityController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Quantity to add'),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  hintText: 'e.g. Received from vendor'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _submit,
          child: _isSaving
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Add Stock'),
        ),
      ],
    );
  }
}