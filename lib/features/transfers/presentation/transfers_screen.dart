import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/design/design_tokens.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/glass_card.dart';

class TransfersScreen extends ConsumerWidget {
  const TransfersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overviewAsync = ref.watch(overviewProvider);
    final mock = ref.watch(mockContentRepositoryProvider);
    final segment = ref.watch(currentSegmentProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Переводы')),
      body: AppBackground(
        child: overviewAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (overview) {
            final templates = mock.transferTemplates(segment);
            final recipients = mock.frequentRecipients(segment);

            return ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Быстрые сценарии', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xs,
                        children: const [
                          Chip(label: Text('Между своими счетами')),
                          Chip(label: Text('По номеру телефона')),
                          Chip(label: Text('В другой банк')),
                          Chip(label: Text('По шаблону')),
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
                      Text('Частые получатели', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: AppSpacing.sm),
                      ...recipients.map(
                        (name) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(child: Text(name.characters.first)),
                          title: Text(name),
                          subtitle: const Text('Быстрый перевод за 10 секунд'),
                          trailing: FilledButton.tonal(
                            onPressed: () {},
                            child: const Text('Выбрать'),
                          ),
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
                      Text('Шаблоны переводов', style: Theme.of(context).textTheme.titleLarge),
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
                      Text('Последние переводы', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: AppSpacing.sm),
                      ...overview.transactions.take(6).map(
                        (tx) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(tx.title),
                          subtitle: Text(tx.date.substring(0, 16)),
                          trailing: Text(money(tx.amount)),
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
