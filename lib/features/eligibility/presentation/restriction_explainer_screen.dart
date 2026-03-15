import 'package:flutter/material.dart';

import '../../../shared/design/design_tokens.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/availability_badge.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../core/segment/segment_models.dart';

class RestrictionExplainerScreen extends StatelessWidget {
  const RestrictionExplainerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Объяснение ограничений')),
      body: AppBackground(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: const [
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Почему часть функций ограничена'),
                  SizedBox(height: AppSpacing.xs),
                  Text('Ограничения зависят от возраста, роли пользователя и требований безопасности.'),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.md),
            _RestrictionTile(
              title: 'Кредиты',
              details: 'Для подростков доступны только консультация и оформление с опекуном в отделении.',
              reason: AvailabilityReason.onlyWithGuardian,
            ),
            SizedBox(height: AppSpacing.sm),
            _RestrictionTile(
              title: 'Рискованные инвестиции',
              details: 'Открываются только с 18 лет в полном режиме.',
              reason: AvailabilityReason.ageRestricted,
            ),
            SizedBox(height: AppSpacing.sm),
            _RestrictionTile(
              title: 'Бизнес-модуль',
              details: 'Доступен только для бизнес-профиля с корпоративным счетом.',
              reason: AvailabilityReason.onlyBusiness,
            ),
          ],
        ),
      ),
    );
  }
}

class _RestrictionTile extends StatelessWidget {
  const _RestrictionTile({
    required this.title,
    required this.details,
    required this.reason,
  });

  final String title;
  final String details;
  final AvailabilityReason reason;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title),
                SizedBox(height: AppSpacing.xs),
                Text(details),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.xs),
          AvailabilityBadge(reason: reason),
        ],
      ),
    );
  }
}
