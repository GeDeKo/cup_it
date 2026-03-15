import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../shared/design/design_tokens.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/glass_card.dart';

class BusinessDocumentsScreen extends ConsumerWidget {
  const BusinessDocumentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docs = ref.watch(mockContentRepositoryProvider).businessDocs();

    return Scaffold(
      appBar: AppBar(title: const Text('Бизнес-документы')),
      body: AppBackground(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            const GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Документооборот'),
                  SizedBox(height: AppSpacing.xs),
                  Text('Счета, акты, накладные и архив с фильтрами по статусам.'),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Последние документы', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.sm),
                  ...docs.map(
                    (d) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(d.title),
                      subtitle: Text(d.number),
                      trailing: Text(d.status),
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
                  Text('Быстрые действия'),
                  SizedBox(height: AppSpacing.xs),
                  Text('• Создать счет'),
                  Text('• Отправить акт контрагенту'),
                  Text('• Выгрузить архив за месяц'),
                  Text('• Отметить документы к проверке'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
