import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/segment/segment_engine.dart';
import '../../../core/segment/segment_models.dart';
import '../../../shared/design/design_tokens.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/finance_widgets.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../demo_mode/presentation/demo_user_switcher.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStateProvider);
    final user = auth.user;
    final current = ref.watch(currentPersonaProvider);
    final presentation = ref.watch(presentationModeProvider);
    final palette = SegmentEngine.theme(current.segment);

    return Scaffold(
      appBar: AppBar(title: const Text('Профиль и демо-режим')),
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(
                    title: 'Клиент',
                    subtitle: 'Основные данные профиля',
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: palette.accent.withValues(alpha: 0.35),
                        child: const Icon(Icons.person_rounded),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.name ?? '-',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              '${user?.phone ?? '-'} • ${current.subtitle}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: KpiTile(
                          label: 'Тариф',
                          value: user?.tier ?? '-',
                          icon: Icons.workspace_premium_rounded,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: KpiTile(
                          label: 'Кэшбэк',
                          value: user?.cashbackLevel ?? '-',
                          icon: Icons.savings_rounded,
                          tone: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(
                    title: 'Переключение демо-пользователя',
                    subtitle: 'Переключение сегмента без перезапуска',
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const DemoUserSwitcher(),
                  const SizedBox(height: AppSpacing.sm),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Режим презентации'),
                    subtitle: const Text('Показывать демо-плашки и пояснения'),
                    value: presentation,
                    onChanged: (v) =>
                        ref.read(presentationModeProvider.notifier).state = v,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.tonal(
                      onPressed: () => context.go('/home'),
                      child: const Text('Применить и открыть главную'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            GlassCard(
              child: Column(
                children: [
                  _MenuRow(
                    title: 'Уведомления',
                    onTap: () => context.go('/notifications'),
                  ),
                  _MenuRow(
                    title: 'Поддержка',
                    onTap: () => context.go('/support'),
                  ),
                  _MenuRow(
                    title: 'Безопасность и лимиты',
                    onTap: () => context.go('/security'),
                  ),
                  _MenuRow(
                    title: 'Заявки и документы',
                    onTap: () => context.go('/applications'),
                  ),
                  _MenuRow(
                    title: 'Почему мне это доступно',
                    onTap: () => context.go('/profile/availability'),
                  ),
                  _MenuRow(
                    title: 'Объяснение ограничений',
                    onTap: () => context.go('/restriction-explainer'),
                  ),
                  if (current.segment == UserSegment.child ||
                      current.segment == UserSegment.teen)
                    _MenuRow(
                      title: 'Родительский контроль',
                      onTap: () => context.go('/parent-control'),
                    ),
                  _MenuRow(title: 'Карты', onTap: () => context.go('/cards')),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton(
              onPressed: () async {
                await ref.read(authStateProvider.notifier).logout();
                if (context.mounted) context.go('/login');
              },
              child: const Text('Выйти из аккаунта'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
