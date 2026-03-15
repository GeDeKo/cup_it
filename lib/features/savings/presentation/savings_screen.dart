import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/models/bank_app_models.dart';
import '../../../shared/design/design_tokens.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/finance_widgets.dart';
import '../../../shared/widgets/glass_card.dart';

class SavingsScreen extends ConsumerStatefulWidget {
  const SavingsScreen({super.key});

  @override
  ConsumerState<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends ConsumerState<SavingsScreen> {
  final TextEditingController _goalTitle = TextEditingController();
  final TextEditingController _goalTarget = TextEditingController(
    text: '120000',
  );
  bool _busy = false;

  @override
  void dispose() {
    _goalTitle.dispose();
    _goalTarget.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final overviewAsync = ref.watch(overviewProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Накопления и цели')),
      body: AppBackground(
        child: overviewAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (data) => ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              _SavingsKpi(data: data),
              const SizedBox(height: AppSpacing.md),
              _GoalsBlock(
                data: data,
                busy: _busy,
                onTopup: (goalId, amount) => _runAction(
                  () => ref
                      .read(bankingActionsProvider)
                      .topupGoal(goalId: goalId, amount: amount),
                  'Цель пополнена на ${money(amount)}',
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _CreateGoalBlock(
                title: _goalTitle,
                target: _goalTarget,
                busy: _busy,
                onCreate: () async {
                  final target =
                      double.tryParse(_goalTarget.text.replaceAll(',', '.')) ??
                      0;
                  if (_goalTitle.text.trim().isEmpty || target <= 0) return;
                  await _runAction(
                    () => ref
                        .read(bankingActionsProvider)
                        .createGoal(
                          title: _goalTitle.text.trim(),
                          target: target,
                        ),
                    'Цель "${_goalTitle.text.trim()}" создана',
                  );
                  _goalTitle.clear();
                },
              ),
              const SizedBox(height: AppSpacing.md),
              _DepositBlock(
                data: data,
                busy: _busy,
                onOpenDeposit: (amount, term) => _runAction(
                  () => ref
                      .read(bankingActionsProvider)
                      .openDeposit(amount, termDays: term, confirmCode: '0000'),
                  'Открыт вклад на ${money(amount)}',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _runAction(
    Future<void> Function() action,
    String success,
  ) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(success)));
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

class _SavingsKpi extends StatelessWidget {
  const _SavingsKpi({required this.data});

  final BankOverview data;

  @override
  Widget build(BuildContext context) {
    final goalsCurrent = data.goals.fold<double>(0, (s, g) => s + g.current);
    final goalsTarget = data.goals.fold<double>(0, (s, g) => s + g.target);
    final progress = goalsTarget == 0 ? 0.0 : (goalsCurrent / goalsTarget);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: KpiTile(
                label: 'Накоплено',
                value: money(goalsCurrent),
                icon: Icons.savings_rounded,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: KpiTile(
                label: 'Во вкладах',
                value: money(
                  data.deposits.fold<double>(0, (s, d) => s + d.amount),
                ),
                icon: Icons.account_balance_rounded,
                tone: AppColors.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        GlassCard(
          child: ProgressStripe(
            label: 'Общий прогресс целей',
            value: '${(progress.clamp(0.0, 1.0) * 100).round()}%',
            progress: progress,
          ),
        ),
      ],
    );
  }
}

class _GoalsBlock extends StatelessWidget {
  const _GoalsBlock({
    required this.data,
    required this.busy,
    required this.onTopup,
  });

  final BankOverview data;
  final bool busy;
  final Future<void> Function(String goalId, double amount) onTopup;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Мои цели',
            subtitle: 'Автопополнение и контроль прогресса',
          ),
          const SizedBox(height: AppSpacing.sm),
          if (data.goals.isEmpty)
            const Text('Целей пока нет')
          else
            ...data.goals.map(
              (goal) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Column(
                  children: [
                    ProgressStripe(
                      label: goal.title,
                      value: '${money(goal.current)} / ${money(goal.target)}',
                      progress: goal.progress,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.tonal(
                        onPressed: busy ? null : () => onTopup(goal.id, 5000),
                        child: const Text('Пополнить +5 000'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CreateGoalBlock extends StatelessWidget {
  const _CreateGoalBlock({
    required this.title,
    required this.target,
    required this.busy,
    required this.onCreate,
  });

  final TextEditingController title;
  final TextEditingController target;
  final bool busy;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Новая цель',
            subtitle: 'Задайте сумму и отслеживайте прогресс',
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: title,
            decoration: const InputDecoration(labelText: 'Название цели'),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: target,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Целевая сумма'),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: busy ? null : onCreate,
              child: const Text('Создать цель'),
            ),
          ),
        ],
      ),
    );
  }
}

class _DepositBlock extends StatelessWidget {
  const _DepositBlock({
    required this.data,
    required this.busy,
    required this.onOpenDeposit,
  });

  final BankOverview data;
  final bool busy;
  final Future<void> Function(double amount, int termDays) onOpenDeposit;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Вклады',
            subtitle: 'Безрисковые сценарии для накоплений',
          ),
          const SizedBox(height: AppSpacing.sm),
          ...data.deposits.map(
            (d) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.lock_clock_rounded),
              title: Text(d.title),
              subtitle: Text('${d.rate}% до ${d.until.substring(0, 10)}'),
              trailing: Text(money(d.amount)),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: busy ? null : () => onOpenDeposit(50000, 180),
                  child: const Text('Открыть на 180 дней'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: OutlinedButton(
                  onPressed: busy ? null : () => onOpenDeposit(100000, 365),
                  child: const Text('Открыть на 365 дней'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
