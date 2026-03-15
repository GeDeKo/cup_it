import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../shared/design/design_tokens.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/glass_card.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presentation = ref.watch(presentationModeProvider);
    final segment = ref.watch(currentSegmentProvider);
    final mock = ref.watch(mockContentRepositoryProvider);
    final sections = mock.settingsSections(segment);

    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: AppBackground(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Профиль интерфейса', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.sm),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Режим презентации'),
                    subtitle: const Text('Показывать демонстрационные плашки и подсказки'),
                    value: presentation,
                    onChanged: (v) =>
                        ref.read(presentationModeProvider.notifier).state = v,
                  ),
                  const Divider(),
                  ...sections.map(
                    (s) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(s.name),
                      subtitle: s.delta.isNotEmpty ? Text(s.delta) : null,
                      trailing: Text(s.value),
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
                  Text('Уведомления'),
                  SizedBox(height: AppSpacing.xs),
                  Text('• Платежи и переводы — включено'),
                  Text('• Персональные офферы — включено'),
                  Text('• ИИ-рекомендации — включено'),
                  Text('• Системные уведомления — включено'),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Приватность и безопасность'),
                  SizedBox(height: AppSpacing.xs),
                  Text('• Вход по биометрии'),
                  Text('• Подтверждение операций по коду'),
                  Text('• Контроль новых устройств'),
                  Text('• История входов за 90 дней'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
