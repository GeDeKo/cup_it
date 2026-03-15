import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/segment/segment_engine.dart';
import '../../../core/segment/segment_models.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/models/bank_app_models.dart';
import '../../../shared/design/design_tokens.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/glass_card.dart';

class HomeDashboardScreen extends ConsumerWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overviewAsync = ref.watch(overviewProvider);
    final segment = ref.watch(currentSegmentProvider);
    final persona = ref.watch(currentPersonaProvider);
    final presentationMode = ref.watch(presentationModeProvider);
    final palette = SegmentEngine.theme(segment);

    return Scaffold(
      appBar: AppBar(title: Text('Главная • ${persona.name}')),
      body: AppBackground(
        child: overviewAsync.when(
          loading: () => const _HomeLoadingState(),
          error: (e, _) => _HomeErrorState(message: e.toString()),
          data: (overview) {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 450),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: ListView(
                key: ValueKey(segment),
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  _FadeSlideIn(
                    index: 0,
                    child: _SegmentHero(
                      overview: overview,
                      segment: segment,
                      personaName: persona.name,
                      accent: palette.accent,
                      presentationMode: presentationMode,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _FadeSlideIn(
                    index: 1,
                    child: _QuickActions(segment: segment),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _FadeSlideIn(
                    index: 2,
                    child: _AdaptiveSegmentBody(
                      segment: segment,
                      overview: overview,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SegmentHero extends StatelessWidget {
  const _SegmentHero({
    required this.overview,
    required this.segment,
    required this.personaName,
    required this.accent,
    required this.presentationMode,
  });

  final BankOverview overview;
  final UserSegment segment;
  final String personaName;
  final Color accent;
  final bool presentationMode;

  @override
  Widget build(BuildContext context) {
    final spentToday =
        overview.security.paymentSpentToday +
        overview.security.transferSpentToday;
    final forecast = overview.account.available - (spentToday * 0.15);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: accent.withValues(alpha: 0.35),
                child: Icon(
                  _segmentIcon(segment),
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  '${SegmentEngine.segmentHeadline(segment)} • $personaName',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              if (presentationMode) const Chip(label: Text('Режим демо')),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            money(overview.account.available),
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Прогноз свободных средств: ${money(forecast)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              _StatusTag(
                icon: Icons.security_rounded,
                label: segment == UserSegment.child
                    ? 'Защита родителя'
                    : 'Умная защита',
              ),
              _StatusTag(
                icon: Icons.insights_rounded,
                label: segment == UserSegment.business
                    ? 'Инсайты по денежному потоку'
                    : 'Персональные инсайты',
              ),
              _StatusTag(
                icon: Icons.flash_on_rounded,
                label: 'Следующее действие',
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _segmentIcon(UserSegment segment) {
    switch (segment) {
      case UserSegment.child:
        return Icons.toys_rounded;
      case UserSegment.teen:
        return Icons.school_rounded;
      case UserSegment.adult:
        return Icons.account_balance_wallet_rounded;
      case UserSegment.business:
        return Icons.apartment_rounded;
    }
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.segment});

  final UserSegment segment;

  @override
  Widget build(BuildContext context) {
    final actions = <_QuickAction>[
      const _QuickAction(
        icon: Icons.swap_horiz_rounded,
        label: 'Переводы',
        route: '/transfers',
      ),
      const _QuickAction(
        icon: Icons.credit_card_rounded,
        label: 'Карты',
        route: '/cards',
      ),
      const _QuickAction(
        icon: Icons.savings_rounded,
        label: 'Цели',
        route: '/savings',
      ),
      const _QuickAction(
        icon: Icons.bar_chart_rounded,
        label: 'Аналитика',
        route: '/analytics',
      ),
      const _QuickAction(
        icon: Icons.auto_awesome_rounded,
        label: 'Выгода',
        route: '/offers',
      ),
      if (segment == UserSegment.adult || segment == UserSegment.business)
        const _QuickAction(
          icon: Icons.show_chart_rounded,
          label: 'Инвестиции',
          route: '/investments',
        ),
      if (segment == UserSegment.business)
        const _QuickAction(
          icon: Icons.business_center_rounded,
          label: 'Бизнес',
          route: '/business/dashboard',
        ),
    ];

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Быстрые действия',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: actions
                .map(
                  (a) => ActionChip(
                    avatar: Icon(a.icon, size: 18),
                    label: Text(a.label),
                    onPressed: () => context.go(a.route),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _AdaptiveSegmentBody extends StatelessWidget {
  const _AdaptiveSegmentBody({required this.segment, required this.overview});

  final UserSegment segment;
  final BankOverview overview;

  @override
  Widget build(BuildContext context) {
    switch (segment) {
      case UserSegment.child:
        return _ChildHome(overview: overview);
      case UserSegment.teen:
        return _TeenHome(overview: overview);
      case UserSegment.adult:
        return _AdultHome(overview: overview);
      case UserSegment.business:
        return _BusinessHome(overview: overview);
    }
  }
}

class _ChildHome extends StatelessWidget {
  const _ChildHome({required this.overview});

  final BankOverview overview;

  @override
  Widget build(BuildContext context) {
    final goal = overview.goals.firstOrNull;

    return Column(
      children: [
        _SectionCard(
          title: 'Карманные деньги',
          subtitle: 'Последний перевод от родителя: +2 000 ₽',
          icon: Icons.family_restroom_rounded,
          cta: 'Попросить перевод',
          onTap: () {},
        ),
        const SizedBox(height: AppSpacing.sm),
        _SectionCard(
          title: goal == null ? 'Моя копилка' : 'Цель: ${goal.title}',
          subtitle: goal == null
              ? 'Создайте первую цель накоплений'
              : '${(goal.progress * 100).round()}% выполнено',
          icon: Icons.savings_rounded,
          progress: goal?.progress ?? 0.2,
          cta: 'К целям',
          onTap: () => context.go('/savings'),
        ),
        const SizedBox(height: AppSpacing.sm),
        const _SectionCard(
          title: 'Финансовая привычка дня',
          subtitle: 'Проверяй баланс перед каждой покупкой',
          icon: Icons.stars_rounded,
          badge: 'Безопасное обучение',
        ),
        const SizedBox(height: AppSpacing.sm),
        _SectionCard(
          title: 'Родительский контроль',
          subtitle: 'Лимиты, одобрения и безопасные покупки под контролем семьи',
          icon: Icons.family_restroom_rounded,
          cta: 'Открыть',
          onTap: () => context.go('/parent-control'),
        ),
        const SizedBox(height: AppSpacing.sm),
        _SectionCard(
          title: 'Где выгоднее покупать',
          subtitle: overview.aiInsights.isEmpty
              ? 'Подсказки появятся после нескольких операций'
              : overview.aiInsights.first.title,
          icon: Icons.auto_awesome_rounded,
          cta: 'Выгодные предложения',
          onTap: () => context.go('/offers'),
        ),
      ],
    );
  }
}

class _TeenHome extends StatelessWidget {
  const _TeenHome({required this.overview});

  final BankOverview overview;

  @override
  Widget build(BuildContext context) {
    final spend = [
      (
        'Еда',
        overview.transactions
            .take(3)
            .fold<double>(0, (s, t) => s + t.amount.abs()),
      ),
      (
        'Подписки',
        overview.subscriptions
            .where((s) => s.enabled)
            .fold<double>(0, (s, sub) => s + sub.amount),
      ),
      (
        'Транспорт',
        overview.transactions
            .skip(1)
            .take(2)
            .fold<double>(0, (s, t) => s + (t.amount.abs() * 0.35)),
      ),
      (
        'Шопинг',
        overview.transactions
            .skip(2)
            .take(2)
            .fold<double>(0, (s, t) => s + (t.amount.abs() * 0.55)),
      ),
    ];
    final max =
        spend.map((e) => e.$2).fold<double>(0, (a, b) => a > b ? a : b) == 0
        ? 1.0
        : spend.map((e) => e.$2).reduce((a, b) => a > b ? a : b);
    return Column(
      children: [
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _HeroBadge(
                title: 'Фокус подростка',
                subtitle: 'Самостоятельность + контроль лимитов',
                icon: Icons.bolt_rounded,
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: _MiniMetric(
                      label: 'Кэшбэк',
                      value: '8.4%',
                      color: const Color(0xFF7EE7D2),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: _MiniMetric(
                      label: 'Лимит месяца',
                      value: '73%',
                      color: const Color(0xFF8EC5FF),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: _MiniMetric(
                      label: 'Подписки',
                      value:
                          '${overview.subscriptions.where((s) => s.enabled).length}',
                      color: const Color(0xFFFF9FC2),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        const _SectionCard(
          title: 'Подписки и лимиты',
          subtitle: 'Контроль платежей и безопасные онлайн-покупки',
          icon: Icons.subscriptions_rounded,
          cta: 'Управлять',
        ),
        const SizedBox(height: AppSpacing.sm),
        const _SectionCard(
          title: 'Подростковая кредитка',
          subtitle:
              'Оформление возможно только в офисе с законным представителем',
          icon: Icons.verified_user_rounded,
          badge: 'Доступно с опекуном',
        ),
        const SizedBox(height: AppSpacing.sm),
        _SectionCard(
          title: 'Твой путь ко взрослому банку',
          subtitle:
              'Что уже доступно сейчас, как подготовиться к взрослым продуктам',
          icon: Icons.flag_rounded,
          cta: 'Открыть путь',
          onTap: () => context.go('/teen-growth'),
        ),
        const SizedBox(height: AppSpacing.sm),
        _SectionCard(
          title: 'Запись в отделение',
          subtitle:
              'Подготовьте документы и выберите удобное время с опекуном',
          icon: Icons.storefront_rounded,
          cta: 'Записаться',
          onTap: () => context.go('/branch-appointment'),
        ),
        const SizedBox(height: AppSpacing.sm),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Траты по категориям',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              ...spend.take(4).map((s) {
                final ratio = (s.$2 / max).clamp(0.08, 1.0);
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: Row(
                    children: [
                      SizedBox(width: 84, child: Text(s.$1)),
                      Expanded(
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: ratio),
                          duration: const Duration(milliseconds: 700),
                          curve: Curves.easeOutCubic,
                          builder: (_, value, __) => LinearProgressIndicator(
                            value: value,
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(8),
                            color: const Color(0xFF7EBCFF),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(money(s.$2)),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        _SectionCard(
          title: 'ИИ-рекомендации покупок',
          subtitle: overview.aiInsights.isEmpty
              ? 'Скоро появятся персональные подсказки'
              : overview.aiInsights.first.description,
          icon: Icons.auto_awesome_rounded,
          cta: 'Посмотреть предложения',
          onTap: () => context.go('/offers'),
        ),
      ],
    );
  }
}

class _AdultHome extends StatelessWidget {
  const _AdultHome({required this.overview});

  final BankOverview overview;

  @override
  Widget build(BuildContext context) {
    final hasLoan = overview.loans.isNotEmpty;
    final income = overview.transactions
        .where((t) => t.amount > 0)
        .fold<double>(0, (s, t) => s + t.amount);
    final expense = overview.transactions
        .where((t) => t.amount < 0)
        .fold<double>(0, (s, t) => s + t.amount.abs());
    final runway = income == 0
        ? 0.0
        : ((income - expense) / income).clamp(0.0, 1.0);

    return Column(
      children: [
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _HeroBadge(
                title: 'Премиальный обзор',
                subtitle: 'Деньги, обязательства, рост капитала',
                icon: Icons.workspace_premium_rounded,
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: _MiniMetric(
                      label: 'Свободный денежный поток',
                      value: '${(runway * 100).round()}%',
                      color: const Color(0xFF8FD3FF),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: _MiniMetric(
                      label: 'Инвестиции',
                      value: '${overview.portfolio.length} поз.',
                      color: const Color(0xFF79E3BE),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: _MiniMetric(
                      label: 'Кред.нагрузка',
                      value: hasLoan ? 'есть' : 'низкая',
                      color: hasLoan
                          ? const Color(0xFFFFB58E)
                          : const Color(0xFF7EE7D2),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              _SparklineBars(
                values: [0.35, 0.52, 0.44, 0.68, 0.58, 0.73, runway],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        _SectionCard(
          title: hasLoan ? 'Кредитный платеж скоро' : 'Кредитные предложения',
          subtitle: hasLoan
              ? 'До платежа осталось 3 дня • ${money(overview.loans.first.nextPayment)}'
              : 'Персональная ставка и быстрый расчет',
          icon: Icons.account_balance_rounded,
          cta: 'К кредитам',
          onTap: () => context.go('/loans'),
        ),
        const SizedBox(height: AppSpacing.sm),
        _SectionCard(
          title: 'Инвестиции и рост капитала',
          subtitle: 'Портфель: ${overview.portfolio.length} позиций',
          icon: Icons.trending_up_rounded,
          cta: 'Открыть',
          onTap: () => context.go('/investments'),
        ),
        const SizedBox(height: AppSpacing.sm),
        _SectionCard(
          title: 'Регулярные платежи',
          subtitle:
              'Шаблоны: ${overview.paymentTemplates.length}, автоплатежи активны',
          icon: Icons.calendar_month_rounded,
          cta: 'К платежам',
          onTap: () => context.go('/payments'),
        ),
        const SizedBox(height: AppSpacing.sm),
        _SectionCard(
          title: 'ИИ: выгодные покупки и кэшбэк',
          subtitle: overview.aiInsights.isEmpty
              ? 'Анализ трат формируется по мере использования'
              : overview.aiInsights.first.title,
          icon: Icons.auto_awesome_rounded,
          cta: 'Открыть рекомендации',
          onTap: () => context.go('/offers'),
        ),
        const SizedBox(height: AppSpacing.sm),
        _SectionCard(
          title: 'Офферы по образу жизни',
          subtitle: 'Кофе, такси, маркетплейсы, путешествия и дом',
          icon: Icons.auto_graph_rounded,
          cta: 'Открыть lifestyle',
          onTap: () => context.go('/lifestyle-offers'),
        ),
      ],
    );
  }
}

class _BusinessHome extends StatelessWidget {
  const _BusinessHome({required this.overview});

  final BankOverview overview;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _HeroBadge(
                title: 'Центр управления бизнесом',
                subtitle: 'Платежи, роли, риски и прогнозы в одном месте',
                icon: Icons.apartment_rounded,
              ),
              SizedBox(height: AppSpacing.sm),
              _SparklineBars(
                values: [0.42, 0.56, 0.49, 0.63, 0.67, 0.61, 0.74],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        _SectionCard(
          title: 'Денежный поток и остатки',
          subtitle: 'Доступно на счетах: ${money(overview.account.available)}',
          icon: Icons.query_stats_rounded,
          cta: 'Бизнес-аналитика',
          onTap: () => context.go('/business/analytics'),
        ),
        const SizedBox(height: AppSpacing.sm),
        const _SectionCard(
          title: 'Платежки контрагентам',
          subtitle: '5 новых платежей, 2 на подписи',
          icon: Icons.request_quote_rounded,
          cta: 'Открыть',
        ),
        const SizedBox(height: AppSpacing.sm),
        _SectionCard(
          title: 'Документы и роли',
          subtitle: 'Доступы сотрудников и статусы операций',
          icon: Icons.badge_rounded,
          cta: 'Документы',
          onTap: () => context.go('/business/documents'),
        ),
        const SizedBox(height: AppSpacing.sm),
        _SectionCard(
          title: 'ИИ-оптимизация расходов',
          subtitle: overview.aiInsights.isEmpty
              ? 'Подбор предложений для бизнеса'
              : overview.aiInsights.first.description,
          icon: Icons.auto_awesome_rounded,
          cta: 'Партнерские офферы',
          onTap: () => context.go('/offers'),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.cta,
    this.badge,
    this.progress,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String? cta;
  final String? badge;
  final double? progress;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              if (badge != null) Chip(label: Text(badge!)),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(subtitle),
          if (progress != null) ...[
            const SizedBox(height: AppSpacing.sm),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress!.clamp(0.0, 1.0)),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (_, value, __) => LinearProgressIndicator(
                value: value,
                minHeight: 8,
                borderRadius: BorderRadius.circular(8),
                color: const Color(0xFF82CFFF),
              ),
            ),
          ],
          if (cta != null) ...[
            const SizedBox(height: AppSpacing.sm),
            FilledButton.tonal(onPressed: onTap, child: Text(cta!)),
          ],
        ],
      ),
    );
  }
}

class _HeroBadge extends StatelessWidget {
  const _HeroBadge({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              colors: [Color(0xFF74C7FF), Color(0xFF7CE8C1)],
            ),
          ),
          child: Icon(icon, size: 20, color: const Color(0xFF05213E)),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}

class _MiniMetric extends StatelessWidget {
  const _MiniMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: color.withValues(alpha: 0.16),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 2),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _SparklineBars extends StatelessWidget {
  const _SparklineBars({required this.values});

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
                  tween: Tween(begin: 0.12, end: v.clamp(0.08, 1.0)),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOutCubic,
                  builder: (_, value, __) => Container(
                    height: 46 * value,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF87D4FF), Color(0xFF4EA8F6)],
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

class _StatusTag extends StatelessWidget {
  const _StatusTag({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: AppColors.glass,
        border: Border.all(color: AppColors.glassStrong),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _QuickAction {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.route,
  });

  final IconData icon;
  final String label;
  final String route;
}

class _FadeSlideIn extends StatelessWidget {
  const _FadeSlideIn({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final duration = Duration(milliseconds: 280 + (index * 120));
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (_, value, widgetChild) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, (1 - value) * 16),
          child: widgetChild,
        ),
      ),
      child: child,
    );
  }
}

class _HomeLoadingState extends StatelessWidget {
  const _HomeLoadingState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: const [
        GlassCard(child: SizedBox(height: 120)),
        SizedBox(height: AppSpacing.md),
        GlassCard(child: SizedBox(height: 90)),
        SizedBox(height: AppSpacing.md),
        GlassCard(child: SizedBox(height: 160)),
      ],
    );
  }
}

class _HomeErrorState extends StatelessWidget {
  const _HomeErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GlassCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 28),
            const SizedBox(height: AppSpacing.sm),
            const Text('Не удалось загрузить витрину'),
            const SizedBox(height: AppSpacing.xs),
            Text(message, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
