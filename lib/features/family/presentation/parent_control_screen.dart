import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../shared/design/design_tokens.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/glass_card.dart';

class ParentControlScreen extends ConsumerWidget {
  const ParentControlScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overviewAsync = ref.watch(overviewProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Родительский контроль')),
      body: AppBackground(
        child: overviewAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (overview) => ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              const GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Лимиты ребенка'),
                    SizedBox(height: AppSpacing.xs),
                    Text('• Дневной лимит: 1 000 ₽'),
                    Text('• Онлайн-покупки: только разрешенные магазины'),
                    Text('• Ночные операции: отключены'),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Последние траты', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: AppSpacing.sm),
                    ...overview.transactions.take(5).map(
                      (tx) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(tx.title),
                        subtitle: Text(tx.date.substring(0, 16)),
                        trailing: Text('${tx.amount.toStringAsFixed(0)} ₽'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('История одобрений'),
                    SizedBox(height: AppSpacing.xs),
                    Text('• Покупка в книжном — одобрено'),
                    Text('• Пополнение игры — отклонено (превышение лимита)'),
                    Text('• Перевод от родителя — подтвержден'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
