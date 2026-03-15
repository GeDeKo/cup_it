import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/segment/feature_access_policy.dart';
import '../../../core/segment/feature_availability_item.dart';
import '../../../core/segment/segment_models.dart';
import '../../../shared/design/design_tokens.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/availability_badge.dart';
import '../../../shared/widgets/glass_card.dart';

class FeatureAvailabilityScreen extends ConsumerWidget {
  const FeatureAvailabilityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final persona = ref.watch(currentPersonaProvider);
    final segment = persona.segment;
    final policy = const FeatureAccessPolicy();

    final items = <FeatureAvailabilityItem>[
      _item('Переводы и платежи', policy.check(segment: segment, feature: FeatureKey.familyControl), fallbackAllowed: true),
      _item('Кредиты', policy.check(segment: segment, feature: FeatureKey.loans)),
      _item('Кредитная карта', policy.check(segment: segment, feature: FeatureKey.creditCard)),
      _item('Инвестиции', policy.check(segment: segment, feature: FeatureKey.riskyInvestments)),
      _item('Виртуальная карта', policy.check(segment: segment, feature: FeatureKey.virtualCard)),
      _item('Бизнес-функции', policy.check(segment: segment, feature: FeatureKey.businessModule)),
      _item('Оформление с опекуном', policy.check(segment: segment, feature: FeatureKey.branchGuardianCredit)),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Почему мне это доступно')),
      body: AppBackground(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Профиль: ${persona.name}', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.xs),
                  Text('Возраст: ${persona.age} • Сегмент: ${_segmentLabel(segment)}'),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: const [
                      AvailabilityBadge(reason: AvailabilityReason.allowed),
                      AvailabilityBadge(reason: AvailabilityReason.ageRestricted),
                      AvailabilityBadge(reason: AvailabilityReason.onlyWithGuardian),
                      AvailabilityBadge(reason: AvailabilityReason.onlyAtBranch),
                      AvailabilityBadge(reason: AvailabilityReason.onlyBusiness),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: GlassCard(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.title, style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 4),
                            Text(item.details),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      AvailabilityBadge(reason: item.reason),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Что откроется позже'),
                  SizedBox(height: AppSpacing.xs),
                  Text('• Полные кредитные продукты доступны с 18 лет.'),
                  Text('• Для подростков часть функций доступна только с опекуном и в отделении.'),
                  Text('• Бизнес-модуль доступен только в бизнес-профиле.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  FeatureAvailabilityItem _item(String title, GuardedAction action, {bool fallbackAllowed = false}) {
    if (fallbackAllowed && action.reason == AvailabilityReason.hiddenForSegment) {
      return FeatureAvailabilityItem(
        title: title,
        reason: AvailabilityReason.allowed,
        details: 'Базовые операции доступны в пределах текущих лимитов профиля.',
      );
    }

    return FeatureAvailabilityItem(
      title: title,
      reason: action.reason,
      details: action.allowed
          ? 'Функция доступна для текущего сегмента.'
          : 'Ограничение: ${action.message}. Правила зависят от возраста и типа профиля.',
    );
  }

  String _segmentLabel(UserSegment segment) {
    switch (segment) {
      case UserSegment.child:
        return 'Ребенок';
      case UserSegment.teen:
        return 'Подросток';
      case UserSegment.adult:
        return 'Взрослый';
      case UserSegment.business:
        return 'Бизнес';
    }
  }
}
