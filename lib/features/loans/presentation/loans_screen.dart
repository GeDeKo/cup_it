import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/segment/segment_models.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/models/bank_app_models.dart';
import '../../../shared/design/design_tokens.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/availability_badge.dart';
import '../../../shared/widgets/finance_widgets.dart';
import '../../../shared/widgets/glass_card.dart';

class LoansScreen extends ConsumerStatefulWidget {
  const LoansScreen({super.key});

  @override
  ConsumerState<LoansScreen> createState() => _LoansScreenState();
}

class _LoansScreenState extends ConsumerState<LoansScreen> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final overviewAsync = ref.watch(overviewProvider);
    final segment = ref.watch(currentSegmentProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Кредиты и нагрузка')),
      body: AppBackground(
        child: overviewAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (data) {
            if (segment == UserSegment.child) {
              return const _LockedState(
                label: 'Недоступно',
                description:
                    'Кредитные продукты недоступны для детского профиля.',
              );
            }
            if (segment == UserSegment.teen) {
              return const _LockedState(
                label: 'Доступно с опекуном',
                description:
                    'Оформление подростковой кредитки возможно только в отделении с законным представителем.',
                showTeenFlow: true,
              );
            }
            return _LoansBody(
              data: data,
              busy: _busy,
              onPay: (loanId, amount) => _payLoan(loanId, amount),
            );
          },
        ),
      ),
    );
  }

  Future<void> _payLoan(String loanId, double amount) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(bankingActionsProvider)
          .payLoan(loanId, amount, confirmCode: '0000');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Платеж ${money(amount)} отправлен')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

class _LoansBody extends StatelessWidget {
  const _LoansBody({
    required this.data,
    required this.busy,
    required this.onPay,
  });

  final BankOverview data;
  final bool busy;
  final Future<void> Function(String loanId, double amount) onPay;

  @override
  Widget build(BuildContext context) {
    final totalDebt = data.loans.fold<double>(0, (s, l) => s + l.remainingDebt);
    final nextPayment = data.loans.fold<double>(0, (s, l) => s + l.nextPayment);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Row(
          children: [
            Expanded(
              child: KpiTile(
                label: 'Общий долг',
                value: money(totalDebt),
                icon: Icons.account_balance_rounded,
                tone: AppColors.warning,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: KpiTile(
                label: 'Ближайшие платежи',
                value: money(nextPayment),
                icon: Icons.event_available_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        ...data.loans.map(
          (loan) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(
                    title: loan.title,
                    subtitle: 'До платежа: ${loan.dueInDays} дн.',
                    trailing: const Chip(label: Text('Активно')),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ProgressStripe(
                    label: 'Погашено',
                    value: 'Остаток ${money(loan.remainingDebt)}',
                    progress:
                        (1 -
                                (loan.remainingDebt /
                                    (loan.remainingDebt + 350000)))
                            .clamp(0.0, 1.0),
                    color: AppColors.success,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: busy
                              ? null
                              : () => onPay(loan.id, loan.nextPayment),
                          child: Text('Оплатить ${money(loan.nextPayment)}'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: busy
                              ? null
                              : () => onPay(
                                  loan.id,
                                  (loan.nextPayment * 2).clamp(
                                    0,
                                    loan.remainingDebt,
                                  ),
                                ),
                          child: const Text('Досрочно ×2'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LockedState extends StatelessWidget {
  const _LockedState({
    required this.label,
    required this.description,
    this.showTeenFlow = false,
  });

  final String label;
  final String description;
  final bool showTeenFlow;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Chip(label: Text(label)),
                  const SizedBox(width: AppSpacing.xs),
                  AvailabilityBadge(
                    reason: showTeenFlow
                        ? AvailabilityReason.onlyWithGuardian
                        : AvailabilityReason.ageRestricted,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Кредиты и кредитные карты',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(description),
              const SizedBox(height: AppSpacing.sm),
              const Text('Витрина адаптирована под возрастной сегмент.'),
              if (showTeenFlow) ...[
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: const [
                    Chip(label: Text('Оформление в отделении')),
                    Chip(label: Text('Только с опекуном')),
                    Chip(label: Text('Нужны документы')),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.tonal(
                        onPressed: () => context.go('/branch-appointment'),
                        child: const Text('Записаться в отделение'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => context.go('/restriction-explainer'),
                        child: const Text('Условия и ограничения'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
