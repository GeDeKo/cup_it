import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/models/bank_app_models.dart';
import '../../../shared/design/design_tokens.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/glass_card.dart';

class PaymentsScreen extends ConsumerStatefulWidget {
  const PaymentsScreen({super.key});

  @override
  ConsumerState<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends ConsumerState<PaymentsScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final overviewAsync = ref.watch(overviewProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Платежи и переводы'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Перевод'),
            Tab(text: 'Оплата'),
            Tab(text: 'Шаблоны'),
            Tab(text: 'Пополнение'),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: overviewAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (overview) => TabBarView(
            controller: _tabController,
            children: [
              _TransferTab(overview: overview),
              _PaymentsTab(overview: overview),
              _TemplatesTab(overview: overview),
              const _TopupTab(),
            ],
          ),
        ),
      ),
    );
  }
}

class _TransferTab extends ConsumerStatefulWidget {
  const _TransferTab({required this.overview});

  final BankOverview overview;

  @override
  ConsumerState<_TransferTab> createState() => _TransferTabState();
}

class _TransferTabState extends ConsumerState<_TransferTab> {
  final TextEditingController _amount = TextEditingController(text: '3000');
  final TextEditingController _comment = TextEditingController();
  String? _beneficiaryId;

  @override
  void dispose() {
    _amount.dispose();
    _comment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final beneficiaries = widget.overview.beneficiaries;
    _beneficiaryId ??= beneficiaries.isNotEmpty ? beneficiaries.first.id : null;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Перевод по контактам',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              DropdownButtonFormField<String>(
                initialValue: _beneficiaryId,
                items: beneficiaries
                    .map(
                      (b) => DropdownMenuItem(
                        value: b.id,
                        child: Text('${b.name} (${b.phone})'),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _beneficiaryId = v),
                decoration: const InputDecoration(labelText: 'Получатель'),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _amount,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Сумма'),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _comment,
                decoration: const InputDecoration(labelText: 'Комментарий'),
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton(
                onPressed: () async {
                  final amount =
                      double.tryParse(_amount.text.replaceAll(',', '.')) ?? 0;
                  if (amount <= 0 || _beneficiaryId == null) return;
                  final b = beneficiaries.firstWhere(
                    (e) => e.id == _beneficiaryId,
                  );
                  await ref
                      .read(bankingActionsProvider)
                      .transfer(
                        to: b.name,
                        amount: amount,
                        comment: _comment.text.trim(),
                        confirmCode: '0000',
                      );
                  if (!context.mounted) {
                    return;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Перевод выполнен: ${money(amount)}'),
                    ),
                  );
                },
                child: const Text('Перевести'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PaymentsTab extends ConsumerStatefulWidget {
  const _PaymentsTab({required this.overview});

  final BankOverview overview;

  @override
  ConsumerState<_PaymentsTab> createState() => _PaymentsTabState();
}

class _PaymentsTabState extends ConsumerState<_PaymentsTab> {
  String? _serviceId;
  final TextEditingController _account = TextEditingController();
  final TextEditingController _amount = TextEditingController();

  @override
  void dispose() {
    _account.dispose();
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _serviceId ??= widget.overview.paymentServices.firstOrNull?.id;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Оплата услуг',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              DropdownButtonFormField<String>(
                initialValue: _serviceId,
                items: widget.overview.paymentServices
                    .map(
                      (s) => DropdownMenuItem(
                        value: s.id,
                        child: Text('${s.title} • ${s.category}'),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _serviceId = v),
                decoration: const InputDecoration(labelText: 'Сервис'),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _account,
                decoration: const InputDecoration(
                  labelText: 'Лицевой счет / телефон',
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _amount,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Сумма'),
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton(
                onPressed: () async {
                  final service = widget.overview.paymentServices.firstWhere(
                    (s) => s.id == _serviceId,
                  );
                  final amount =
                      double.tryParse(_amount.text.replaceAll(',', '.')) ?? 0;
                  if (amount <= 0 || _account.text.trim().isEmpty) return;
                  await ref
                      .read(bankingActionsProvider)
                      .payCustom(
                        title: service.title,
                        account: _account.text.trim(),
                        amount: amount,
                        confirmCode: '0000',
                      );
                },
                child: const Text('Оплатить'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TemplatesTab extends ConsumerStatefulWidget {
  const _TemplatesTab({required this.overview});

  final BankOverview overview;

  @override
  ConsumerState<_TemplatesTab> createState() => _TemplatesTabState();
}

class _TemplatesTabState extends ConsumerState<_TemplatesTab> {
  final TextEditingController _title = TextEditingController();
  final TextEditingController _account = TextEditingController();
  final TextEditingController _amount = TextEditingController();

  @override
  void dispose() {
    _title.dispose();
    _account.dispose();
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Мои шаблоны',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              ...widget.overview.paymentTemplates.map(
                (p) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(p.title),
                  subtitle: Text('${p.account} • ${money(p.amount)}'),
                  trailing: OutlinedButton(
                    onPressed: () async {
                      await ref
                          .read(bankingActionsProvider)
                          .payTemplate(p.id, confirmCode: '0000');
                    },
                    child: const Text('Оплатить'),
                  ),
                ),
              ),
              const Divider(),
              TextField(
                controller: _title,
                decoration: const InputDecoration(
                  labelText: 'Название шаблона',
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _account,
                decoration: const InputDecoration(labelText: 'Счет / номер'),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _amount,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Сумма'),
              ),
              const SizedBox(height: AppSpacing.sm),
              FilledButton(
                onPressed: () async {
                  final amount =
                      double.tryParse(_amount.text.replaceAll(',', '.')) ?? 0;
                  if (_title.text.trim().isEmpty ||
                      _account.text.trim().isEmpty ||
                      amount <= 0) {
                    return;
                  }
                  await ref
                      .read(bankingActionsProvider)
                      .createTemplate(
                        title: _title.text.trim(),
                        account: _account.text.trim(),
                        amount: amount,
                      );
                },
                child: const Text('Сохранить шаблон'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TopupTab extends ConsumerStatefulWidget {
  const _TopupTab();

  @override
  ConsumerState<_TopupTab> createState() => _TopupTabState();
}

class _TopupTabState extends ConsumerState<_TopupTab> {
  final TextEditingController _amount = TextEditingController(text: '10000');
  String _source = 'СБП';

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Пополнение', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.sm),
              DropdownButtonFormField<String>(
                initialValue: _source,
                items: const [
                  DropdownMenuItem(value: 'СБП', child: Text('СБП')),
                  DropdownMenuItem(
                    value: 'Карта другого банка',
                    child: Text('Карта другого банка'),
                  ),
                  DropdownMenuItem(
                    value: 'Наличные в банкомате',
                    child: Text('Наличные в банкомате'),
                  ),
                ],
                onChanged: (v) => setState(() => _source = v ?? 'СБП'),
                decoration: const InputDecoration(labelText: 'Источник'),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _amount,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Сумма'),
              ),
              const SizedBox(height: AppSpacing.sm),
              FilledButton(
                onPressed: () async {
                  final amount =
                      double.tryParse(_amount.text.replaceAll(',', '.')) ?? 0;
                  if (amount <= 0) return;
                  await ref
                      .read(bankingActionsProvider)
                      .topUp(amount: amount, source: _source);
                },
                child: const Text('Пополнить счет'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

extension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
