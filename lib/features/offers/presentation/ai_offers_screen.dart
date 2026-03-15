import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/design/design_tokens.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/glass_card.dart';

class AiOffersScreen extends ConsumerWidget {
  const AiOffersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overviewAsync = ref.watch(overviewProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Выгодные предложения')),
      body: AppBackground(
        child: overviewAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (overview) => ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Персональный ИИ-анализ расходов',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Главная категория: ${overview.purchasePattern.topCategory}',
                    ),
                    Text(
                      'Средние траты: ${money(overview.purchasePattern.monthlySpend)} в месяц',
                    ),
                    Text(
                      'Повторяющиеся подписки: ${overview.purchasePattern.repeatingSubscriptions}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Умные подсказки',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (overview.aiInsights.isEmpty)
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Персональные рекомендации формируются по вашей активности.'),
                          SizedBox(height: AppSpacing.xs),
                          Text('• Добавьте категории трат в избранное'),
                          Text('• Используйте карту в партнерской сети'),
                          Text('• Проверьте подписки для поиска экономии'),
                        ],
                      )
                    else
                      ...overview.aiInsights.map(
                        (insight) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.auto_awesome_rounded),
                          title: Text(insight.title),
                          subtitle: Text(
                            '${insight.description}\nКатегория: ${insight.category}\nПотенциальная выгода: ${insight.expectedBenefit}',
                          ),
                          isThreeLine: true,
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
                    Text(
                      'Предложения партнеров',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (overview.merchantOffers.isEmpty)
                      const Text('Партнерские предложения обновляются ежедневно, проверьте позже.')
                    else
                      ...overview.merchantOffers.map(
                        (offer) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.local_offer_rounded),
                          title: Text(offer.merchant),
                          subtitle: Text(
                            '${offer.category} • кэшбэк ${offer.cashbackPercent}% • скидка ${offer.discountPercent}%',
                          ),
                          trailing: Text(offer.until.substring(0, 10)),
                        ),
                      ),
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
