import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/segment/product_eligibility_service.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/design/design_tokens.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/glass_card.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen>
    with TickerProviderStateMixin {
  late final TabController _tabs;
  final TextEditingController _goalTitle = TextEditingController();
  final TextEditingController _goalTarget = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _goalTitle.dispose();
    _goalTarget.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final overviewAsync = ref.watch(overviewProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Каталог'),
        bottom: TabBar(
          controller: _tabs,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Кредиты/Вклады'),
            Tab(text: 'Цели/Подписки'),
            Tab(text: 'Кэшбэк'),
            Tab(text: 'Инвестиции'),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: overviewAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (overview) => TabBarView(
            controller: _tabs,
            children: [
              _LoansDepositsTab(overview: overview),
              _GoalsSubscriptionsTab(
                overview: overview,
                goalTitle: _goalTitle,
                goalTarget: _goalTarget,
              ),
              _CashbackTab(overview: overview),
              _InvestmentsTab(overview: overview),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoansDepositsTab extends ConsumerWidget {
  const _LoansDepositsTab({required this.overview});

  final dynamic overview;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final segment = ref.watch(currentSegmentProvider);
    final loanAccess = const ProductEligibilityService().checkLoan(segment);
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Кредиты', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.sm),
              if (!loanAccess.allowed) ...[
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(loanAccess.message),
                  subtitle: const Text(
                    'Кредитные продукты скрыты или ограничены для текущего профиля.',
                  ),
                ),
              ] else ...[
                ...overview.loans.map<Widget>(
                  (loan) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: const Color(0x221C6FB8),
                        border: Border.all(color: const Color(0x334BA7FF)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loan.title,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text('Остаток ${money(loan.remainingDebt)}'),
                          const SizedBox(height: AppSpacing.xs),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: () async {
                                await ref
                                    .read(bankingActionsProvider)
                                    .payLoan(
                                      loan.id,
                                      loan.nextPayment,
                                      confirmCode: '0000',
                                    );
                              },
                              child: const Text('Оплатить'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Вклады', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.sm),
              ...overview.deposits.map<Widget>(
                (dep) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(dep.title),
                  subtitle: Text(
                    '${dep.rate}% до ${dep.until.substring(0, 10)}',
                  ),
                  trailing: Text(money(dep.amount)),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: () async {
                        await ref
                            .read(bankingActionsProvider)
                            .openDeposit(
                              50000,
                              termDays: 180,
                              confirmCode: '0000',
                            );
                      },
                      child: const Text('Открыть на 180 дней'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GoalsSubscriptionsTab extends ConsumerWidget {
  const _GoalsSubscriptionsTab({
    required this.overview,
    required this.goalTitle,
    required this.goalTarget,
  });

  final dynamic overview;
  final TextEditingController goalTitle;
  final TextEditingController goalTarget;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Цели', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.sm),
              ...overview.goals.map<Widget>(
                (goal) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: const Color(0x1F1A6FB8),
                      border: Border.all(color: const Color(0x333E9AE6)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          goal.title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${(goal.progress * 100).round()}% • ${money(goal.current)} из ${money(goal.target)}',
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () async {
                              await ref
                                  .read(bankingActionsProvider)
                                  .topupGoal(goalId: goal.id, amount: 5000);
                            },
                            child: const Text('Пополнить на 5 000 ₽'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Divider(),
              TextField(
                controller: goalTitle,
                decoration: const InputDecoration(labelText: 'Новая цель'),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: goalTarget,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Сумма цели'),
              ),
              const SizedBox(height: AppSpacing.sm),
              FilledButton(
                onPressed: () async {
                  final target =
                      double.tryParse(goalTarget.text.replaceAll(',', '.')) ??
                      0;
                  if (goalTitle.text.trim().isEmpty || target <= 0) return;
                  await ref
                      .read(bankingActionsProvider)
                      .createGoal(title: goalTitle.text.trim(), target: target);
                },
                child: const Text('Создать цель'),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Подписки', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.sm),
              ...overview.subscriptions.map<Widget>(
                (sub) => SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: Text(sub.title),
                  subtitle: Text(money(sub.amount)),
                  value: sub.enabled,
                  onChanged: (_) async {
                    await ref
                        .read(bankingActionsProvider)
                        .toggleSubscription(sub.id);
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CashbackTab extends ConsumerWidget {
  const _CashbackTab({required this.overview});

  final dynamic overview;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Кэшбэк-офферы',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              ...overview.cashbackOffers.map<Widget>(
                (offer) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('${offer.partner} • ${offer.percent}%'),
                  trailing: offer.active
                      ? const Chip(label: Text('Активно'))
                      : FittedBox(
                          fit: BoxFit.scaleDown,
                          child: OutlinedButton(
                            onPressed: () async {
                              await ref
                                  .read(bankingActionsProvider)
                                  .activateCashback(offer.id);
                            },
                            child: const Text('Активировать'),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InvestmentsTab extends ConsumerWidget {
  const _InvestmentsTab({required this.overview});

  final dynamic overview;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Портфель', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.sm),
              if (overview.portfolio.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Text(
                    'Портфель пока не сформирован. Доступны образовательные подборки и консервативные идеи.',
                  ),
                )
              else
                ...overview.portfolio.map<Widget>(
                  (p) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(p.ticker),
                    subtitle: Text('${p.lots} лотов • ср. ${p.avgPrice} ₽'),
                    trailing: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: OutlinedButton(
                        onPressed: () async {
                          await ref
                              .read(bankingActionsProvider)
                              .sellStock(ticker: p.ticker, lots: 1);
                        },
                        child: const Text('Продать 1'),
                      ),
                    ),
                  ),
                ),
              const Divider(),
              ...overview.stockOffers.map<Widget>(
                (s) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('${s.ticker} • ${s.name}'),
                  subtitle: Text('${s.price} ₽'),
                  trailing: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: OutlinedButton(
                      onPressed: () async {
                        await ref
                            .read(bankingActionsProvider)
                            .buyStock(
                              ticker: s.ticker,
                              lots: 1,
                              confirmCode: '0000',
                            );
                      },
                      child: const Text('Купить'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
