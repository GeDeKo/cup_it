import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../shared/design/design_tokens.dart';
import '../../../shared/widgets/glass_card.dart';

class DemoLauncherSection extends ConsumerWidget {
  const DemoLauncherSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Быстрый демо-запуск',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.xs),
          const Text('Переключайте роли одним нажатием во время защиты.'),
          const SizedBox(height: AppSpacing.sm),
          _DemoLauncherTile(
            title: 'Показать ребенка',
            subtitle: 'Безопасный режим, цели, родительский контроль',
            onTap: () => ref.read(currentPersonaProvider.notifier).switchAccount(demoPersonas[0]),
          ),
          _DemoLauncherTile(
            title: 'Показать подростка',
            subtitle: 'Виртуальная карта, лимиты, путь ко взрослому банку',
            onTap: () => ref.read(currentPersonaProvider.notifier).switchAccount(demoPersonas[1]),
          ),
          _DemoLauncherTile(
            title: 'Показать взрослого',
            subtitle: 'Полный набор продуктов и lifestyle-офферы',
            onTap: () => ref.read(currentPersonaProvider.notifier).switchAccount(demoPersonas[2]),
          ),
          _DemoLauncherTile(
            title: 'Показать бизнес',
            subtitle: 'Cashflow, документы, аномалии расходов',
            onTap: () => ref.read(currentPersonaProvider.notifier).switchAccount(demoPersonas[3]),
          ),
          const SizedBox(height: AppSpacing.xs),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonalIcon(
              onPressed: () => context.go('/jury'),
              icon: const Icon(Icons.gavel_rounded),
              label: const Text('Открыть материалы для жюри'),
            ),
          ),
        ],
      ),
    );
  }
}

class _DemoLauncherTile extends StatelessWidget {
  const _DemoLauncherTile({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: const Color(0x1D5AAEFF),
            border: Border.all(color: const Color(0x335AAEFF)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
