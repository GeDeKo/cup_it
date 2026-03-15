import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/design/design_tokens.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/finance_widgets.dart';
import '../../../shared/widgets/glass_card.dart';

class BusinessAnalyticsScreen extends ConsumerWidget {
  const BusinessAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overviewAsync = ref.watch(overviewProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Бизнес-аналитика')),
      body: AppBackground(
        child: overviewAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (overview) {
            final income = overview.transactions
                .where((t) => t.amount > 0)
                .fold<double>(0, (s, t) => s + t.amount);
            final expense = overview.transactions
                .where((t) => t.amount < 0)
                .fold<double>(0, (s, t) => s + t.amount.abs());

            return ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: KpiTile(
                        label: 'Выручка',
                        value: money(income),
                        icon: Icons.trending_up_rounded,
                        tone: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: KpiTile(
                        label: 'Расходы',
                        value: money(expense),
                        icon: Icons.trending_down_rounded,
                        tone: AppColors.danger,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Структура расходов', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: AppSpacing.sm),
                      const ProgressStripe(
                        label: 'Логистика',
                        value: '34%',
                        progress: 0.34,
                        color: Color(0xFF7CC9FF),
                      ),
                      const ProgressStripe(
                        label: 'Реклама',
                        value: '22%',
                        progress: 0.22,
                        color: Color(0xFFFFBE7A),
                      ),
                      const ProgressStripe(
                        label: 'Закупки',
                        value: '28%',
                        progress: 0.28,
                        color: Color(0xFF8AE8C3),
                      ),
                      const ProgressStripe(
                        label: 'Подписки и сервисы',
                        value: '16%',
                        progress: 0.16,
                        color: Color(0xFFC3B1FF),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Сравнение периодов', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: AppSpacing.sm),
                      const _PeriodRow(label: 'Текущий месяц', value: '+12% к выручке'),
                      const _PeriodRow(label: 'Прошлый месяц', value: '+4% к выручке'),
                      const _PeriodRow(label: '3 месяца среднее', value: 'Стабильный рост'),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                const GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Рекомендации'),
                      SizedBox(height: AppSpacing.xs),
                      Text('• Снизить частоту мелких платежей поставщикам, объединяя в реестр.'),
                      Text('• Пересмотреть рекламный бюджет по каналу с низкой конверсией.'),
                      Text('• Зафиксировать лимит по категории «Подписки и сервисы».'),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PeriodRow extends StatelessWidget {
  const _PeriodRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      trailing: Text(value),
    );
  }
}
