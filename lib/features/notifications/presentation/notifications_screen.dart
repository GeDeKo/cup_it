import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../shared/design/design_tokens.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/glass_card.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overviewAsync = ref.watch(overviewProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Уведомления'),
        actions: [
          IconButton(
            onPressed: () async {
              await ref.read(bankingActionsProvider).markAllNotificationsRead();
            },
            icon: const Icon(Icons.done_all),
          ),
        ],
      ),
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: overviewAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (overview) => ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              GlassCard(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Новых уведомлений: ${overview.notifications.where((n) => !n.read).length}',
                      ),
                    ),
                    const Chip(label: Text('Все каналы')),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              ...overview.notifications.map(
                  (n) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: GlassCard(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            n.read
                                ? Icons.notifications_none
                                : Icons.notifications_active,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  n.title,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                const SizedBox(height: AppSpacing.xxs),
                                Text(n.text),
                                const SizedBox(height: AppSpacing.xxs),
                                Text(n.time.substring(0, 16)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
