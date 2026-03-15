import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/design/design_tokens.dart';
import '../../../shared/widgets/glass_card.dart';
import '../data/jury_insights_repository.dart';
import '../domain/jury_charts_factory.dart';
import '../domain/jury_models.dart';
import '../domain/jury_section_router.dart';

class JuryScreen extends StatefulWidget {
  const JuryScreen({super.key});

  @override
  State<JuryScreen> createState() => _JuryScreenState();
}

class _JuryScreenState extends State<JuryScreen> {
  final _repo = const JuryInsightsRepository();
  final _router = const JurySectionRouter();
  final _charts = const JuryChartsFactory();
  JurySection _section = JurySection.overview;

  @override
  Widget build(BuildContext context) {
    final kpis = _repo.kpis();
    final surveys = _repo.surveys();
    final rows = _repo.comparisonRows();
    final line = _repo.engagementLine();
    final pie = _repo.prioritiesPie();
    final pieLabels = _repo.prioritiesLabels();

    return Scaffold(
      backgroundColor: const Color(0xFF071428),
      appBar: AppBar(
        title: const Text('Материалы для жюри'),
        actions: [
          IconButton(
            tooltip: 'Вернуться ко входу',
            onPressed: () => context.go('/login'),
            icon: const Icon(Icons.login_rounded),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: NavigationBar(
          selectedIndex: _section.index,
          onDestinationSelected: (i) => setState(() => _section = JurySection.values[i]),
          destinations: JurySection.values
              .map(
                (s) => NavigationDestination(
                  icon: const Icon(Icons.analytics_outlined),
                  label: _router.title(s),
                ),
              )
              .toList(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.xl,
          ),
          children: [
            _HeroBlock(kpis: kpis),
            const SizedBox(height: AppSpacing.md),
            if (_section == JurySection.overview) ...[
              const _ProblemBlock(),
              const SizedBox(height: AppSpacing.md),
              const _IdeaBlock(),
              const SizedBox(height: AppSpacing.md),
              _ComparisonTable(rows: rows),
              const SizedBox(height: AppSpacing.md),
              const JuryBeforeAfterBlock(),
              const SizedBox(height: AppSpacing.md),
              const _FeatureMatrixBlock(),
            ] else if (_section == JurySection.research) ...[
              _SurveyChart(surveys: surveys, charts: _charts),
              const SizedBox(height: AppSpacing.md),
              _PiePriorities(values: pie, labels: pieLabels),
              const SizedBox(height: AppSpacing.md),
              const _AiJuryBlock(),
              const SizedBox(height: AppSpacing.md),
              const JuryAccessibilityBlock(),
              const SizedBox(height: AppSpacing.md),
              const _ClientBenefitBlock(),
            ] else ...[
              _LineEngagement(points: line, charts: _charts),
              const SizedBox(height: AppSpacing.md),
              _FunnelComparison(
                classic: _repo.funnelClassic(),
                adaptive: _repo.funnelAdaptive(),
              ),
              const SizedBox(height: AppSpacing.md),
              const _ExtraKpiBlock(),
              const SizedBox(height: AppSpacing.md),
              const _BusinessImpactBlock(),
              const SizedBox(height: AppSpacing.md),
              const _FinalBlock(),
            ],
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.icon(
                onPressed: () => context.go('/login'),
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Вернуться ко входу'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroBlock extends StatelessWidget {
  const _HeroBlock({required this.kpis});
  final List<KpiModel> kpis;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Адаптивная банковская витрина',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          const Text(
            'Банк, который перестраивает интерфейс, сценарии и доступность продуктов под возраст и этап жизни клиента.',
          ),
          const SizedBox(height: AppSpacing.sm),
          const Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              Chip(label: Text('Персонализация витрины')),
              Chip(label: Text('Прозрачные ограничения')),
              Chip(label: Text('Рост релевантности')),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          AdaptiveKpiGrid(kpis: kpis),
        ],
      ),
    );
  }
}

class AdaptiveKpiGrid extends StatelessWidget {
  const AdaptiveKpiGrid({super.key, required this.kpis});

  final List<KpiModel> kpis;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth < 520 ? 1 : 2;
        final itemWidth = (constraints.maxWidth - (columns - 1) * AppSpacing.sm) / columns;
        return Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: kpis
              .map(
                (kpi) => SizedBox(
                  width: itemWidth,
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 126),
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: const Color(0x223D89D8),
                      border: Border.all(color: const Color(0x447CC4FF)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          kpi.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          kpi.value,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          kpi.delta,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _ProblemBlock extends StatelessWidget {
  const _ProblemBlock();

  @override
  Widget build(BuildContext context) {
    return const GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Проблема'),
          SizedBox(height: AppSpacing.xs),
          Text('• Типовые банковские приложения одинаковы для всех возрастов.'),
          Text('• Главный экран часто перегружен и требует лишних переходов.'),
          Text('• Детям и подросткам показываются нерелевантные взрослые продукты.'),
          Text('• Банку сложнее давать релевантные предложения в нужный момент.'),
        ],
      ),
    );
  }
}

class _IdeaBlock extends StatelessWidget {
  const _IdeaBlock();

  @override
  Widget build(BuildContext context) {
    return const GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Идея решения'),
          SizedBox(height: AppSpacing.xs),
          Text('• Интерфейс полностью перестраивается под возрастной сегмент.'),
          Text('• Показываются только релевантные функции и сценарии.'),
          Text('• Ограничения объясняются прозрачно: «С опекуном», «18+», «В отделении».'),
          Text('• Стиль, действия и структура отличаются для каждого сегмента.'),
        ],
      ),
    );
  }
}

class _ComparisonTable extends StatelessWidget {
  const _ComparisonTable({required this.rows});
  final List<ComparisonRowModel> rows;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Обычный банк и наше решение', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: 640,
              child: Table(
                border: TableBorder.all(color: const Color(0x337FB4EA)),
                columnWidths: const {
                  0: FlexColumnWidth(1.6),
                  1: FlexColumnWidth(1),
                  2: FlexColumnWidth(1),
                },
                children: [
                  const TableRow(
                    children: [
                      Padding(padding: EdgeInsets.all(8), child: Text('Метрика')),
                      Padding(padding: EdgeInsets.all(8), child: Text('Обычный')),
                      Padding(padding: EdgeInsets.all(8), child: Text('Наш банк')),
                    ],
                  ),
                  ...rows.map(
                    (r) => TableRow(
                      children: [
                        Padding(padding: const EdgeInsets.all(8), child: Text(r.metric)),
                        Padding(padding: const EdgeInsets.all(8), child: Text(r.classicBank)),
                        Padding(padding: const EdgeInsets.all(8), child: Text(r.adaptiveBank)),
                      ],
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

class JuryBeforeAfterBlock extends StatelessWidget {
  const JuryBeforeAfterBlock({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('До / После', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          LayoutBuilder(
            builder: (context, constraints) {
              final twoColumns = constraints.maxWidth >= 640;
              if (!twoColumns) {
                return const Column(
                  children: [
                    _BeforeAfterColumn(
                      title: 'Обычный мобильный банк',
                      points: [
                        'Одинаковый интерфейс для всех',
                        'Перегруженный главный экран',
                        'Все продукты подряд',
                        'Неясные ограничения',
                        'Нет персональных подсказок',
                      ],
                    ),
                    SizedBox(height: AppSpacing.sm),
                    _BeforeAfterColumn(
                      title: 'Наш адаптивный банк',
                      points: [
                        'Интерфейс под возраст и роль',
                        'Релевантный home по сценариям',
                        'Только актуальные функции',
                        'Прозрачные правила доступа',
                        'ИИ-рекомендации и рост конверсии',
                      ],
                    ),
                  ],
                );
              }

              return const Row(
                children: [
                  Expanded(
                    child: _BeforeAfterColumn(
                      title: 'Обычный мобильный банк',
                      points: [
                        'Одинаковый интерфейс для всех',
                        'Перегруженный главный экран',
                        'Все продукты подряд',
                        'Неясные ограничения',
                        'Нет персональных подсказок',
                      ],
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _BeforeAfterColumn(
                      title: 'Наш адаптивный банк',
                      points: [
                        'Интерфейс под возраст и роль',
                        'Релевантный home по сценариям',
                        'Только актуальные функции',
                        'Прозрачные правила доступа',
                        'ИИ-рекомендации и рост конверсии',
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _BeforeAfterColumn extends StatelessWidget {
  const _BeforeAfterColumn({required this.title, required this.points});

  final String title;
  final List<String> points;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: const Color(0x151E6FB8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x334A9ADF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          ...points.map((point) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('• $point'),
              )),
        ],
      ),
    );
  }
}

class _SurveyChart extends StatelessWidget {
  const _SurveyChart({required this.surveys, required this.charts});
  final List<SurveyResultModel> surveys;
  final JuryChartsFactory charts;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Результаты опросов', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          ...surveys.map((s) {
            final p = charts.normalized(s.percent);
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.question),
                  const SizedBox(height: 6),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: p),
                    duration: const Duration(milliseconds: 700),
                    builder: (_, v, __) => LinearProgressIndicator(
                      value: v,
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('${s.percent}%', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _PiePriorities extends StatelessWidget {
  const _PiePriorities({required this.values, required this.labels});

  final List<double> values;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Приоритеты по сегментам', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 200,
            width: double.infinity,
            child: CustomPaint(
              painter: _PiePainter(values),
              child: const SizedBox.expand(),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...labels.asMap().entries.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('• ${e.value} — ${values[e.key].round()}%'),
            ),
          ),
        ],
      ),
    );
  }
}

class _LineEngagement extends StatelessWidget {
  const _LineEngagement({required this.points, required this.charts});
  final List<JuryLinePoint> points;
  final JuryChartsFactory charts;

  @override
  Widget build(BuildContext context) {
    final max = charts.maxLineValue(points).clamp(1, double.infinity).toDouble();

    return ResponsiveChartCard(
      title: 'Рост вовлеченности (доля недельно активных)',
      subtitle: 'Синяя линия — адаптивный банк, серая — обычный банк.',
      chart: SizedBox(
        width: double.infinity,
        height: 220,
        child: CustomPaint(
          painter: _LinePainter(points: points, maxValue: max),
          child: const SizedBox.expand(),
        ),
      ),
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: points
            .map((p) => Expanded(
                  child: Text(
                    p.label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class ResponsiveChartCard extends StatelessWidget {
  const ResponsiveChartCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.chart,
    this.footer,
  });

  final String title;
  final String subtitle;
  final Widget chart;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(subtitle),
          const SizedBox(height: AppSpacing.sm),
          chart,
          if (footer != null) ...[
            const SizedBox(height: AppSpacing.xs),
            footer!,
          ],
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: const [
              _LegendDot(color: Color(0xFF74CCFF), label: 'Адаптивный банк'),
              _LegendDot(color: Color(0xFF8A9BB2), label: 'Обычный банк'),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label),
      ],
    );
  }
}

class _FunnelComparison extends StatelessWidget {
  const _FunnelComparison({required this.classic, required this.adaptive});
  final List<double> classic;
  final List<double> adaptive;

  @override
  Widget build(BuildContext context) {
    const stages = ['Вход', 'Поиск', 'Выбор', 'Действие'];
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Воронка от входа до действия', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          ...stages.asMap().entries.map((e) {
            final i = e.key;
            final c = classic[i] / 100;
            final a = adaptive[i] / 100;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(e.value),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(child: LinearProgressIndicator(value: c, minHeight: 8)),
                      const SizedBox(width: AppSpacing.xs),
                      Text('${classic[i].round()}%'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: a,
                          minHeight: 8,
                          color: const Color(0xFF7DD1FF),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text('${adaptive[i].round()}%'),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _FeatureMatrixBlock extends StatelessWidget {
  const _FeatureMatrixBlock();

  @override
  Widget build(BuildContext context) {
    TableRow row(String title, String child, String teen, String adult, String business) {
      return TableRow(
        children: [
          Padding(padding: const EdgeInsets.all(8), child: Text(title)),
          Padding(padding: const EdgeInsets.all(8), child: Text(child)),
          Padding(padding: const EdgeInsets.all(8), child: Text(teen)),
          Padding(padding: const EdgeInsets.all(8), child: Text(adult)),
          Padding(padding: const EdgeInsets.all(8), child: Text(business)),
        ],
      );
    }

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Матрица доступности функций', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: 740,
              child: Table(
                border: TableBorder.all(color: const Color(0x337FB4EA)),
                columnWidths: const {
                  0: FlexColumnWidth(1.5),
                  1: FlexColumnWidth(1),
                  2: FlexColumnWidth(1),
                  3: FlexColumnWidth(1),
                  4: FlexColumnWidth(1),
                },
                children: [
                  const TableRow(
                    children: [
                      Padding(padding: EdgeInsets.all(8), child: Text('Функция')),
                      Padding(padding: EdgeInsets.all(8), child: Text('Дети')),
                      Padding(padding: EdgeInsets.all(8), child: Text('Подростки')),
                      Padding(padding: EdgeInsets.all(8), child: Text('Взрослые')),
                      Padding(padding: EdgeInsets.all(8), child: Text('Бизнес')),
                    ],
                  ),
                  row('Кредиты', 'Нет', 'С опекуном в офисе', 'Да', 'Да'),
                  row('Виртуальная карта', 'Нет', 'Да', 'Да', 'Опц.'),
                  row('Инвестиции', 'Нет', 'Ограничено', 'Да', 'Нет'),
                  row('Семейный контроль', 'Да', 'Да', 'Нет', 'Нет'),
                  row('Бизнес-платежи', 'Нет', 'Нет', 'Нет', 'Да'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class JuryAccessibilityBlock extends StatelessWidget {
  const JuryAccessibilityBlock({super.key});

  @override
  Widget build(BuildContext context) {
    return const GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Доступность и читаемость'),
          SizedBox(height: AppSpacing.xs),
          Text('• Высокий контраст и читабельные размеры шрифта для всех сегментов.'),
          Text('• Снижение когнитивной нагрузки через релевантный состав экранов.'),
          Text('• Прозрачные статусы ограничений: «С 18 лет», «С опекуном», «В отделении».'),
          Text('• Единый язык интерфейса и понятные плашки доступности.'),
        ],
      ),
    );
  }
}

class _AiJuryBlock extends StatelessWidget {
  const _AiJuryBlock();

  @override
  Widget build(BuildContext context) {
    return const GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ИИ-рекомендации покупок'),
          SizedBox(height: AppSpacing.xs),
          Text('• Анализируются частые категории, чеки, подписки и время покупок.'),
          Text('• Пользователь видит, где выше кэшбэк и где есть скидки партнеров.'),
          Text('• Банк повышает CTR персональных офферов и монетизацию партнерской сети.'),
          Text('• Ожидаемый рост отклика на релевантные предложения: +18%.'),
        ],
      ),
    );
  }
}

class _ClientBenefitBlock extends StatelessWidget {
  const _ClientBenefitBlock();

  @override
  Widget build(BuildContext context) {
    return const GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Выгода для клиента'),
          SizedBox(height: AppSpacing.xs),
          Text('• Быстрее найти нужное действие без лишних шагов.'),
          Text('• Безопаснее для детей и прозрачнее для родителей.'),
          Text('• Более современный опыт для подростков.'),
          Text('• Спокойный и статусный интерфейс для взрослых.'),
          Text('• Эффективный панельный подход для бизнеса.'),
        ],
      ),
    );
  }
}

class _ExtraKpiBlock extends StatelessWidget {
  const _ExtraKpiBlock();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Дополнительные KPI', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          const Text('Интерес к ИИ-рекомендациям: 67%'),
          const Text('Прогноз роста CTR партнерских офферов: +18%'),
          const Text('Снижение когнитивной нагрузки по опросу: -23%'),
          const Text('Удержание молодых клиентов (12 мес): +11%'),
        ],
      ),
    );
  }
}

class _BusinessImpactBlock extends StatelessWidget {
  const _BusinessImpactBlock();

  @override
  Widget build(BuildContext context) {
    return const GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Бизнес-эффект'),
          SizedBox(height: AppSpacing.xs),
          Text('• Рост вовлеченности и частоты использования приложения.'),
          Text('• Повышение релевантности продуктовых предложений.'),
          Text('• Снижение когнитивной нагрузки на пользователя.'),
          Text('• Удержание молодых клиентов и рост пожизненной ценности клиента.'),
        ],
      ),
    );
  }
}

class _FinalBlock extends StatelessWidget {
  const _FinalBlock();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ключевая особенность', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.xs),
          const Text(
            'Банк не просто меняет цветовую тему. Он перестраивает интерфейс, пользовательский путь, доступность продуктов и сценарии под возрастную группу.',
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Банк, который взрослеет вместе с клиентом.',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ],
      ),
    );
  }
}

class _PiePainter extends CustomPainter {
  _PiePainter(this.values);
  final List<double> values;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.33;
    final colors = [
      const Color(0xFF7CC9FF),
      const Color(0xFF79E0C5),
      const Color(0xFFFFC27F),
      const Color(0xFFFF93B4),
    ];
    double start = -math.pi / 2;
    final total = values.fold<double>(0, (s, v) => s + v).clamp(1, double.infinity);
    for (var i = 0; i < values.length; i++) {
      final sweep = (values[i] / total) * (math.pi * 2);
      final paint = Paint()..color = colors[i % colors.length];
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), start, sweep, true, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _LinePainter extends CustomPainter {
  _LinePainter({required this.points, required this.maxValue});

  final List<JuryLinePoint> points;
  final double maxValue;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2 || size.width <= 0 || size.height <= 0) return;

    const padLeft = 28.0;
    const padRight = 10.0;
    const padTop = 10.0;
    const padBottom = 24.0;

    final chartWidth = size.width - padLeft - padRight;
    final chartHeight = size.height - padTop - padBottom;
    if (chartWidth <= 0 || chartHeight <= 0) return;

    final axisPaint = Paint()
      ..color = const Color(0xFF5C7091)
      ..strokeWidth = 1;

    canvas.drawLine(
      Offset(padLeft, padTop),
      Offset(padLeft, padTop + chartHeight),
      axisPaint,
    );
    canvas.drawLine(
      Offset(padLeft, padTop + chartHeight),
      Offset(padLeft + chartWidth, padTop + chartHeight),
      axisPaint,
    );

    final step = chartWidth / (points.length - 1);

    double y(double value) => padTop + chartHeight - ((value / maxValue) * chartHeight);

    final classicPath = Path();
    final adaptivePath = Path();

    for (var i = 0; i < points.length; i++) {
      final x = padLeft + i * step;
      final yClassic = y(points[i].classic);
      final yAdaptive = y(points[i].adaptive);
      if (i == 0) {
        classicPath.moveTo(x, yClassic);
        adaptivePath.moveTo(x, yAdaptive);
      } else {
        classicPath.lineTo(x, yClassic);
        adaptivePath.lineTo(x, yAdaptive);
      }

      canvas.drawCircle(Offset(x, yClassic), 2, Paint()..color = const Color(0xFF8A9BB2));
      canvas.drawCircle(Offset(x, yAdaptive), 2.4, Paint()..color = const Color(0xFF74CCFF));
    }

    canvas.drawPath(
      classicPath,
      Paint()
        ..color = const Color(0xFF8A9BB2)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );
    canvas.drawPath(
      adaptivePath,
      Paint()
        ..color = const Color(0xFF74CCFF)
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke,
    );

    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (final tick in [0.0, maxValue / 2, maxValue]) {
      textPainter.text = TextSpan(
        text: tick.round().toString(),
        style: const TextStyle(color: Color(0xFF9BAFCC), fontSize: 10),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(2, y(tick) - 6));
    }
  }

  @override
  bool shouldRepaint(covariant _LinePainter oldDelegate) {
    return oldDelegate.points != points || oldDelegate.maxValue != maxValue;
  }
}
