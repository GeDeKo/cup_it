import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/design/design_tokens.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/glass_card.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                const Spacer(),
                const GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Банк, который адаптируется под возраст и жизненный этап',
                      ),
                      SizedBox(height: AppSpacing.sm),
                      Text(
                        'Дети • Подростки • Взрослые • Бизнес в одном приложении',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                const GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Что покажем жюри:'),
                      SizedBox(height: AppSpacing.xs),
                      Text(
                        '• сегментная главная\n• ограничение функций по возрасту\n• бизнес-модуль\n• мгновенное переключение профиля',
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => context.go('/login'),
                    child: const Text('Начать демо'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
