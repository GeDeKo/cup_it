import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/models/bank_app_models.dart';
import '../../../shared/design/design_tokens.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/finance_widgets.dart';
import '../../../shared/widgets/glass_card.dart';

class CardsScreen extends ConsumerWidget {
  const CardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overviewAsync = ref.watch(overviewProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Карты и счета')),
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: overviewAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (overview) {
            final frozenCount = overview.cards.where((c) => c.frozen).length;
            return ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                const SectionHeader(
                  title: 'Мои карты',
                  subtitle: 'Управление лимитами, безопасностью и выпуском',
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: KpiTile(
                        label: 'Всего карт',
                        value: '${overview.cards.length}',
                        icon: Icons.credit_card_rounded,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: KpiTile(
                        label: 'Заморожено',
                        value: '$frozenCount',
                        icon: Icons.shield_moon_rounded,
                        tone: AppColors.warning,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                ...overview.cards.map((card) => _CardTile(card: card)),
                const SizedBox(height: AppSpacing.sm),
                const GlassCard(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.add_card_rounded),
                    title: Text('Выпуск виртуальной карты'),
                    subtitle: Text('Мгновенно для онлайн-платежей'),
                    trailing: Chip(label: Text('Демо')),
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

class _CardTile extends ConsumerStatefulWidget {
  const _CardTile({required this.card});

  final BankCardModel card;

  @override
  ConsumerState<_CardTile> createState() => _CardTileState();
}

class _CardTileState extends ConsumerState<_CardTile> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final card = widget.card;
    final colors = card.gradient.map(_hexToColor).toList();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: GlassCard(
        padding: EdgeInsets.zero,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: AppRadii.card,
            gradient: LinearGradient(colors: colors),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => context.go('/cards/${card.id}'),
                      child: Text(
                        card.title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ),
                  Chip(label: Text(card.format)),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                card.panMasked,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                money(card.balance),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  _ActionChip(
                    label: card.frozen ? 'Разморозить' : 'Заморозить',
                    icon: card.frozen
                        ? Icons.lock_open_rounded
                        : Icons.lock_rounded,
                    busy: _busy,
                    onTap: () => _runAction(
                      () => ref
                          .read(bankingActionsProvider)
                          .toggleCard(card.id, !card.frozen),
                      card.frozen ? 'Карта разблокирована' : 'Карта заморожена',
                    ),
                  ),
                  _ActionChip(
                    label: 'Перевыпуск',
                    icon: Icons.refresh_rounded,
                    busy: _busy,
                    onTap: () => _runAction(
                      () =>
                          ref.read(bankingActionsProvider).reissueCard(card.id),
                      'Запрос на перевыпуск отправлен',
                    ),
                  ),
                  const Chip(
                    avatar: Icon(Icons.shield_rounded, size: 16),
                    label: Text('Защита онлайн-платежей'),
                  ),
                ],
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

  Color _hexToColor(String hex) {
    final value = hex.replaceAll('#', '');
    return Color(int.parse('FF$value', radix: 16));
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.label,
    required this.icon,
    required this.busy,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: busy
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(icon, size: 16),
      label: Text(label),
      onPressed: busy ? null : onTap,
    );
  }
}
