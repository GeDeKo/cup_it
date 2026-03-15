import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/design/design_tokens.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/finance_widgets.dart';
import '../../../shared/widgets/glass_card.dart';
import '../domain/business_anomaly_model.dart';
import 'widgets/business_anomaly_card.dart';

class BusinessDashboardScreen extends ConsumerWidget {
  const BusinessDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overviewAsync = ref.watch(overviewProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Бизнес-дэшборд')),
      body: AppBackground(
        child: overviewAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (data) {
            final incoming = data.transactions
                .where((t) => t.amount > 0)
                .fold<double>(0, (s, t) => s + t.amount);
            final outgoing = data.transactions
                .where((t) => t.amount < 0)
                .fold<double>(0, (s, t) => s + t.amount.abs());
            final anomalies = const <BusinessAnomalyModel>[
              BusinessAnomalyModel(
                id: 'an-1',
                title: 'Рост расходов на рекламу',
                description: 'В этом месяце траты на рекламу выше среднего значения за 3 месяца.',
                delta: '+18%',
              ),
              BusinessAnomalyModel(
                id: 'an-2',
                title: 'Повторяющиеся платежи по подпискам',
                description: 'Количество регулярных подписок увеличилось и требует ревизии.',
                delta: '+11%',
              ),
              BusinessAnomalyModel(
                id: 'an-3',
                title: 'Нетипичный всплеск логистики',
                description: 'Траты на логистику выросли выше планового коридора.',
                delta: '+14%',
              ),
            ];

            return ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Финансовый срез руководителя',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      const Text(
                        'Платежная дисциплина, операционный денежный поток и риски на 7 дней',
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      const _CashflowBars(
                        values: [0.42, 0.53, 0.48, 0.62, 0.57, 0.7, 0.64],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                const SectionHeader(
                  title: 'Финансы компании',
                  subtitle: 'Остатки, денежный поток, платежный календарь',
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: KpiTile(
                        label: 'Остаток',
                        value: money(data.account.available),
                        icon: Icons.account_balance_wallet_rounded,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: KpiTile(
                        label: 'Налоги/платежки',
                        value: '${data.paymentTemplates.length}',
                        icon: Icons.request_quote_rounded,
                        tone: AppColors.warning,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: KpiTile(
                        label: 'Входящий поток',
                        value: money(incoming),
                        icon: Icons.trending_up_rounded,
                        tone: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: KpiTile(
                        label: 'Исходящий поток',
                        value: money(outgoing),
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
                      Text(
                        'Приоритеты сегодня',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      const ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.priority_high_rounded),
                        title: Text('2 платежа ждут подписи'),
                        subtitle: Text('Срок исполнения: сегодня до 18:00'),
                      ),
                      const ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.receipt_long_rounded),
                        title: Text('Налоговый платеж через 2 дня'),
                        subtitle: Text('Рекомендуем включить автоплатеж'),
                      ),
                      const ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.groups_rounded),
                        title: Text('Новый сотрудник без роли доступа'),
                        subtitle: Text('Назначьте роль в центре безопасности'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Аномалии расходов',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      const Text('Сигналы выявлены на основе динамики категорий и контрагентов.'),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                ...anomalies
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: BusinessAnomalyCard(item: item),
                      ),
                    ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: () => context.go('/business/payments'),
                        child: const Text('Бизнес-платежи'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.tonal(
                        onPressed: () => context.go('/business/documents'),
                        child: const Text('Бизнес-документы'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.tonal(
                        onPressed: () => context.go('/business/analytics'),
                        child: const Text('Бизнес-аналитика'),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CashflowBars extends StatelessWidget {
  const _CashflowBars({required this.values});

  final List<double> values;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: values
          .map(
            (v) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.1, end: v.clamp(0.1, 1.0)),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  builder: (_, value, __) => Container(
                    height: 56 * value,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(7),
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF8CCBFF), Color(0xFF467BDA)],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
