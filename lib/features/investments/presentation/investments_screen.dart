import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/segment/product_eligibility_service.dart';
import '../../../core/segment/segment_models.dart';
import '../../../shared/design/design_tokens.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/glass_card.dart';

class InvestmentsScreen extends ConsumerWidget {
  const InvestmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overview = ref.watch(overviewProvider);
    final segment = ref.watch(currentSegmentProvider);
    final access = const ProductEligibilityService().checkInvestments(segment);

    return Scaffold(
      appBar: AppBar(title: const Text('Инвестиции')),
      body: AppBackground(
        child: overview.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (data) => ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              if (!access.allowed && segment != UserSegment.business)
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Chip(label: Text(access.message)),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Инвестиции временно ограничены',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      const Text(
                        'Для вашего профиля доступны только безопасные финансовые сценарии.',
                      ),
                    ],
                  ),
                )
              else
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Портфель',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      ...data.portfolio.map(
                        (p) => Text(
                          '${p.ticker}: ${p.lots} лотов • ср. ${p.avgPrice.toStringAsFixed(2)} ₽',
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
                      'Персональные идеи',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ...data.aiInsights
                        .map((insight) => Text('• ${insight.title}')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
