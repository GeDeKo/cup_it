import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/design/design_tokens.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/availability_badge.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../core/segment/segment_models.dart';

class TeenGrowthPathSection extends StatelessWidget {
  const TeenGrowthPathSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Твой путь ко взрослому банку')),
      body: AppBackground(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            _StepCard(
              title: 'Что уже доступно сейчас',
              points: const [
                'Виртуальная карта для безопасных покупок',
                'Лимиты расходов по категориям',
                'Накопления и цели',
                'Кэшбэк и персональные рекомендации',
              ],
              reason: AvailabilityReason.allowed,
            ),
            SizedBox(height: AppSpacing.sm),
            _StepCard(
              title: 'Следующий шаг',
              points: const [
                'Запись в отделение для консультации',
                'Подготовка документов с опекуном',
                'Разбор условий подростковой кредитной карты',
              ],
              reason: AvailabilityReason.onlyWithGuardian,
            ),
            SizedBox(height: AppSpacing.sm),
            _StepCard(
              title: 'Что откроется после 18 лет',
              points: const [
                'Полноценные кредитные продукты',
                'Расширенные инвестиции',
                'Больше персональных предложений',
              ],
              reason: AvailabilityReason.ageRestricted,
            ),
            const SizedBox(height: AppSpacing.sm),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Советы по финансовой самостоятельности'),
                  SizedBox(height: AppSpacing.xs),
                  Text('• Держите лимит на онлайн-покупки отдельным.'),
                  Text('• Проверяйте подписки раз в месяц.'),
                  Text('• Планируйте цель и фиксируйте прогресс еженедельно.'),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonal(
                onPressed: () => context.go('/branch-appointment'),
                child: const Text('Записаться в отделение'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.title,
    required this.points,
    required this.reason,
  });

  final String title;
  final List<String> points;
  final AvailabilityReason reason;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: Theme.of(context).textTheme.titleLarge)),
              AvailabilityBadge(reason: reason),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          ...points.map((point) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('• $point'),
              )),
        ],
      ),
    );
  }
}
