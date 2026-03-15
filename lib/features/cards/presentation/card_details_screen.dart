import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/design/design_tokens.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/glass_card.dart';

class CardDetailsScreen extends ConsumerWidget {
  const CardDetailsScreen({super.key, required this.cardId});

  final String cardId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overviewAsync = ref.watch(overviewProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Детали карты')),
      body: AppBackground(
        child: overviewAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (overview) {
            final card = overview.cards.firstWhere(
              (c) => c.id == cardId,
              orElse: () => overview.cards.first,
            );

            return ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(card.title, style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: AppSpacing.xs),
                      Text(card.panMasked),
                      Text('Баланс: ${money(card.balance)}'),
                      Text('Тип: ${card.type} • Формат: ${card.format}'),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                const GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Реквизиты и лимиты'),
                      SizedBox(height: AppSpacing.xs),
                      Text('• Дневной лимит на покупки: 50 000 ₽'),
                      Text('• Онлайн-операции: включены'),
                      Text('• NFC-платежи: включены'),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Последние операции', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: AppSpacing.sm),
                      ...overview.transactions.take(5).map(
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
