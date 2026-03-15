import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/segment/segment_models.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/design/design_tokens.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/finance_widgets.dart';
import '../../../shared/widgets/glass_card.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overview = ref.watch(overviewProvider);
    final segment = ref.watch(currentSegmentProvider);
    final mock = ref.watch(mockContentRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Счета')),
      body: AppBackground(
        child: overview.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (data) {
            final metrics = mock.accountMetrics(segment);
            return ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: KpiTile(
                        label: 'Баланс',
                        value: money(data.account.balance),
                        icon: Icons.account_balance_wallet_rounded,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: KpiTile(
                        label: 'Доступно',
                        value: money(data.account.available),
                        icon: Icons.check_circle_rounded,
                        tone: AppColors.success,
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
                        'Основной счет',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text('Номер: ${data.account.id}'),
                      Text('Валюта: ${data.account.currency}'),
                      const SizedBox(height: AppSpacing.sm),
                      const Divider(height: 1),
                      const SizedBox(height: AppSpacing.sm),
                      ...metrics.map(
                        (m) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                          child: Row(
                            children: [
                              Expanded(child: Text(m.name)),
                              Text(m.value),
                            ],
                          ),
                        ),
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
                        'Дополнительные счета',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _AccountTile(
                        title: 'Накопительный',
                        subtitle: 'Ставка 13.4% • автопополнение включено',
                        amount: segment == UserSegment.business
                            ? '420 000 ₽'
                            : '160 000 ₽',
                      ),
                      _AccountTile(
                        title: 'Валютный',
                        subtitle: 'USD • для поездок и онлайн-покупок',
                        amount: segment == UserSegment.child ? 'Недоступно' : '\$1 260',
                      ),
                      _AccountTile(
                        title: 'Резерв',
                        subtitle: segment == UserSegment.business
                            ? 'Резерв ликвидности на 30 дней'
                            : 'Финансовая подушка',
                        amount: segment == UserSegment.business ? '310 000 ₽' : '56 000 ₽',
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
                        'Последняя активность',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      ...data.transactions.take(5).map(
                        (tx) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(tx.title),
                          subtitle: Text(tx.date.substring(0, 16)),
                          trailing: Text(money(tx.amount)),
                        ),
                      ),
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

class _AccountTile extends StatelessWidget {
  const _AccountTile({
    required this.title,
    required this.subtitle,
    required this.amount,
  });

  final String title;
  final String subtitle;
  final String amount;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Text(amount),
    );
  }
}
