import 'package:flutter/material.dart';

import '../../../shared/design/design_tokens.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/glass_card.dart';

class BranchAppointmentScreen extends StatelessWidget {
  const BranchAppointmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Запись в отделение')),
      body: AppBackground(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            const GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Консультация по подростковым продуктам'),
                  SizedBox(height: AppSpacing.xs),
                  Text('Оформление кредитной карты подростка возможно только с законным представителем.'),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Документы'),
                  SizedBox(height: AppSpacing.xs),
                  Text('• Паспорт опекуна'),
                  Text('• Свидетельство о рождении / паспорт подростка'),
                  Text('• Заявление в отделении'),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ближайшие окна', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.sm),
                  const ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Пн, 18:30 • Отделение «Центральное»'),
                    subtitle: Text('ул. Ленина, 14'),
                  ),
                  const ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Вт, 12:00 • Отделение «Север»'),
                    subtitle: Text('пр. Мира, 88'),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Запись подтверждена (демо)')),
                        );
                      },
                      child: const Text('Записаться'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
