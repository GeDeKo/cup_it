import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../shared/design/design_tokens.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/glass_card.dart';

class BusinessPaymentsScreen extends ConsumerWidget {
  const BusinessPaymentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overviewAsync = ref.watch(overviewProvider);
    final mock = ref.watch(mockContentRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Бизнес-платежи')),
      body: AppBackground(
        child: overviewAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (overview) {
            final templates = mock.transferTemplates(ref.watch(currentSegmentProvider));
            return ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Платежный календарь', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: AppSpacing.xs),
                      const Text('Сегодня: 2 платежа на подписи, 1 срочный налоговый платеж.'),
                      const SizedBox(height: AppSpacing.sm),
                      const Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xs,
                        children: [
                          Chip(label: Text('Налоги')),
                          Chip(label: Text('Контрагенты')),
                          Chip(label: Text('Зарплата')),
                          Chip(label: Text('Регулярные платежи')),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Шаблоны', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: AppSpacing.sm),
                      ...templates.map(
                        (t) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(t.title),
                          subtitle: Text(t.target),
                          trailing: Text(t.amount),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Последние платежные поручения', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: AppSpacing.sm),
                      ...overview.transactions.take(6).map(
                        (tx) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(tx.title),
                          subtitle: Text('Статус: исполнено • ${tx.date.substring(0, 16)}'),
                          trailing: Text('${tx.amount.toStringAsFixed(0)} ₽'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
