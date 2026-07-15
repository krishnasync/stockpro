import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../inventory/presentation/screens/add_stock_dialog.dart';
import '../providers/product_provider.dart';

class ProductListScreen extends ConsumerWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'Scan barcode',
            onPressed: () {}, // -> mobile_scanner flow, Phase 4
          ),
          FilledButton.icon(
            onPressed: () => context.push(AppRoutes.productForm),
            icon: const Icon(Icons.add),
            label: const Text('New Product'),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search products by name...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) =>
                  ref.read(productSearchQueryProvider.notifier).state = value,
            ),
          ),
          Expanded(
            child: productsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Failed to load: $err')),
              data: (products) {
                if (products.isEmpty) {
                  return const Center(child: Text('No products found.'));
                }
                return ListView.separated(
                  itemCount: products.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final p = products[index];
                    return ListTile(
                      onTap: () =>
                          context.push(AppRoutes.productForm, extra: p),
                      title: Text(p.name),
                      subtitle: Text('SKU: ${p.sku}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.add_box_outlined),
                            tooltip: 'Add stock',
                            onPressed: () => showDialog(
                              context: context,
                              builder: (_) => AddStockDialog(
                                productId: p.id,
                                productName: p.name,
                              ),
                            ),
                          ),
                          if (p.isOutOfStock)
                            const _StockBadge(
                                label: 'Out of Stock',
                                color: AppStatusColors.danger)
                          else if (p.isLowStock)
                            const _StockBadge(
                                label: 'Low Stock',
                                color: AppStatusColors.warning),
                          const SizedBox(width: 12),
                          Text('₹${p.sellingPrice.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.titleMedium),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StockBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _StockBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}