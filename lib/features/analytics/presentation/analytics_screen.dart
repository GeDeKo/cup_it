import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/models/bank_app_models.dart';
import '../../../shared/design/design_tokens.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/finance_widgets.dart';
import '../../../shared/widgets/glass_card.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overviewAsync = ref.watch(overviewProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Аналитика расходов')),
      body: AppBackground(
        child: overviewAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (data) => _AnalyticsBody(data: data),
        ),
      ),
    );
  }
}

class _AnalyticsBody extends StatelessWidget {
  const _AnalyticsBody({required this.data});

  final BankOverview data;

  @override
  Widget build(BuildContext context) {
    final income = data.transactions
        .where((t) => t.amount > 0)
        .fold<double>(0, (s, t) => s + t.amount);
    final expense = data.transactions
        .where((t) => t.amount < 0)
        .fold<double>(0, (s, t) => s + t.amount.abs());
    final balanceDelta = income - expense;

    final categoryData = _buildCategoryData(data);
    final maxCategory = categoryData.isEmpty
        ? 1.0
        : categoryData.map((e) => e.amount).reduce((a, b) => a > b ? a : b);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        const SectionHeader(
          title: 'Финансовый обзор',
          subtitle: 'Доходы, расходы, динамика и оптимизация',
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: KpiTile(
                label: 'Доходы',
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
        const SizedBox(height: AppSpacing.sm),
        KpiTile(
          label: 'Чистый денежный поток',
          value: money(balanceDelta),
          icon: Icons.account_balance_wallet_rounded,
          tone: balanceDelta >= 0 ? AppColors.success : AppColors.warning,
        ),
        const SizedBox(height: AppSpacing.md),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Категории трат',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              ...categoryData.map(
                (category) => ProgressStripe(
                  label: category.title,
                  value: money(category.amount),
                  progress: category.amount / maxCategory,
                  color: category.color,
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
                'Инсайты и рекомендации',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              ...data.insights
                  .take(3)
                  .map(
                    (i) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.lightbulb_outline_rounded),
                      title: Text(i.title),
                      subtitle: Text(i.reason),
                    ),
                  ),
            ],
          ),
        ),
      ],
    );
  }

  List<_CategorySpend> _buildCategoryData(BankOverview overview) {
    final food = overview.transactions
        .take(3)
        .fold<double>(0, (s, t) => s + t.amount.abs() * 0.35);
    final transport = overview.transactions
        .skip(1)
        .take(3)
        .fold<double>(0, (s, t) => s + t.amount.abs() * 0.2);
    final utilities = overview.paymentTemplates.fold<double>(
      0,
      (s, p) => s + p.amount * 0.55,
    );
    final subscriptions = overview.subscriptions
        .where((s) => s.enabled)
        .fold<double>(0, (s, e) => s + e.amount);

    return [
      _CategorySpend('Еда и покупки', food, const Color(0xFF7FDBFF)),
      _CategorySpend('Транспорт', transport, const Color(0xFF66E3B4)),
      _CategorySpend('Коммунальные', utilities, const Color(0xFFFFD089)),
      _CategorySpend('Подписки', subscriptions, const Color(0xFFFF8EA1)),
    ];
  }
}

class _CategorySpend {
  const _CategorySpend(this.title, this.amount, this.color);

  final String title;
  final double amount;
  final Color color;
}
