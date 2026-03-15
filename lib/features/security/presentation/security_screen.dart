import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/design/design_tokens.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/glass_card.dart';

class SecurityScreen extends ConsumerStatefulWidget {
  const SecurityScreen({super.key});

  @override
  ConsumerState<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends ConsumerState<SecurityScreen> {
  final TextEditingController _transferLimit = TextEditingController();
  final TextEditingController _paymentLimit = TextEditingController();

  @override
  void dispose() {
    _transferLimit.dispose();
    _paymentLimit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final overviewAsync = ref.watch(overviewProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Безопасность и лимиты')),
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: overviewAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (overview) {
            _transferLimit.text = overview.security.dailyTransferLimit
                .toStringAsFixed(0);
            _paymentLimit.text = overview.security.dailyPaymentLimit
                .toStringAsFixed(0);

            return ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Лимиты на сегодня',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Переводы: ${money(overview.security.transferSpentToday)} / ${money(overview.security.dailyTransferLimit)}',
                      ),
                      Text(
                        'Платежи: ${money(overview.security.paymentSpentToday)} / ${money(overview.security.dailyPaymentLimit)}',
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
                        'Изменить лимиты',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextField(
                        controller: _transferLimit,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Лимит переводов',
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextField(
                        controller: _paymentLimit,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Лимит платежей',
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      FilledButton(
                        onPressed: () async {
                          final transfer =
                              double.tryParse(_transferLimit.text.trim()) ?? 0;
                          final payment =
                              double.tryParse(_paymentLimit.text.trim()) ?? 0;
                          if (transfer <= 0 || payment <= 0) return;
                          await ref
                              .read(bankingActionsProvider)
                              .updateSecurity(
                                dailyTransferLimit: transfer,
                                dailyPaymentLimit: payment,
                              );
                        },
                        child: const Text('Сохранить'),
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
