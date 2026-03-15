import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../shared/design/design_tokens.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/glass_card.dart';
import '../domain/lifestyle_offer_model.dart';

class LifestyleOffersScreen extends ConsumerWidget {
  const LifestyleOffersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overviewAsync = ref.watch(overviewProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Персональные офферы по образу жизни')),
      body: AppBackground(
        child: overviewAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (overview) {
            final offers = _buildOffers(overview.aiInsights.map((e) => e.title).toList());
            return ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: offers.length + 1,
              itemBuilder: (_, i) {
                if (i == 0) {
                  return const Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.sm),
                    child: GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Что учитывает ИИ'),
                          SizedBox(height: AppSpacing.xs),
                          Text('• Историю трат и любимые категории'),
                          Text('• Повторяющиеся покупки и подписки'),
                          Text('• Партнерские скидки и кэшбэк'),
                        ],
                      ),
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: LifestyleOfferCard(offer: offers[i - 1]),
                );
              },
            );
          },
        ),
      ),
    );
  }

  List<LifestyleOffer> _buildOffers(List<String> hints) {
    return [
      const LifestyleOffer(
        id: 'life-1',
        category: 'Кофе',
        title: 'Вы часто покупаете кофе по будням',
        subtitle: 'В этой сети доступен кэшбэк 7% в утренние часы.',
        benefit: 'Экономия до 780 ₽/мес',
      ),
      const LifestyleOffer(
        id: 'life-2',
        category: 'Такси',
        title: 'У вас регулярные траты на такси',
        subtitle: 'Подключите категорию с повышенным кэшбэком 10%.',
        benefit: 'До 1 200 ₽/мес',
      ),
      const LifestyleOffer(
        id: 'life-3',
        category: 'Маркетплейсы',
        title: 'В маркетплейсе доступна персональная скидка',
        subtitle: 'Скидка 12% на часто покупаемые категории товаров.',
        benefit: 'До 1 500 ₽/мес',
      ),
      const LifestyleOffer(
        id: 'life-4',
        category: 'Путешествия',
        title: 'В категории «Путешествия» есть спецоффер',
        subtitle: 'Кэшбэк 5% на билеты и бронирования у партнера.',
        benefit: 'До 2 100 ₽/мес',
      ),
      const LifestyleOffer(
        id: 'life-5',
        category: 'Подписки',
        title: 'Повторяющиеся списания выросли',
        subtitle: 'Проверьте подписки и отключите неиспользуемые сервисы.',
        benefit: 'Экономия до 640 ₽/мес',
      ),
      if (hints.isNotEmpty)
        LifestyleOffer(
          id: 'life-6',
          category: 'Индивидуально',
          title: hints.first,
          subtitle: 'Дополнительная персональная рекомендация на основе ваших операций.',
          benefit: 'Динамический расчет',
        ),
    ];
  }
}

class LifestyleOfferCard extends StatelessWidget {
  const LifestyleOfferCard({super.key, required this.offer});

  final LifestyleOffer offer;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(offer.category, style: Theme.of(context).textTheme.labelLarge),
              const Chip(label: Text('Персонально')),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(offer.title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(offer.subtitle),
          const SizedBox(height: AppSpacing.xs),
          Text(offer.benefit, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
