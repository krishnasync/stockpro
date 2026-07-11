import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Placeholder for Phase 9 (Dashboard & Reports). Wired up now so the
/// router and auth flow have somewhere to land after login. Real KPI
/// cards, charts (fl_chart), and "Top Selling Products" tables get built
/// once the Products/Sales/Purchase modules (Phases 4-7) exist to query.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome${user != null ? ', ${user.fullName}' : ''}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
            onPressed: () => ref.read(authRepositoryProvider).signOut(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _KpiCardPlaceholder(label: 'Today\'s Sales'),
            _KpiCardPlaceholder(label: 'Stock Value'),
            _KpiCardPlaceholder(label: 'Low Stock Items'),
            _KpiCardPlaceholder(label: 'Pending Payments'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go(AppRoutes.products),
        icon: const Icon(Icons.inventory_2_outlined),
        label: const Text('View Products'),
      ),
    );
  }
}

class _KpiCardPlaceholder extends StatelessWidget {
  final String label;
  const _KpiCardPlaceholder({required this.label});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8),
              Text('—',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text('Wired up in Phase 9',
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
