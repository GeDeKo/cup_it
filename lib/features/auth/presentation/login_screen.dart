import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/segment/segment_models.dart';
import '../../../shared/design/design_tokens.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/glass_card.dart';
import 'demo_launcher_section.dart';
import '../../demo_mode/presentation/demo_user_switcher.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _phone = TextEditingController(
    text: '+79990000000',
  );
  final TextEditingController _password = TextEditingController(text: '123456');

  @override
  void dispose() {
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authStateProvider);
    final current = ref.watch(currentPersonaProvider);
    final isPresentation = ref.watch(presentationModeProvider);

    ref.listen<AuthState>(authStateProvider, (_, next) {
      if (next.isAuthenticated) context.go('/home');
    });

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              Text(
                'Выбор демо-пользователя',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              const Text('Выберите сегмент и войдите в готовый демо-сценарий'),
              const SizedBox(height: AppSpacing.md),
              const DemoUserSwitcher(),
              const SizedBox(height: AppSpacing.sm),
              GlassCard(child: Text(_segmentHint(current.segment))),
              const SizedBox(height: AppSpacing.sm),
              const DemoLauncherSection(),
              const SizedBox(height: AppSpacing.sm),
              GlassCard(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Данные для входа',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextField(
                        controller: _phone,
                        decoration: const InputDecoration(labelText: 'Телефон'),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextField(
                        controller: _password,
                        obscureText: true,
                        decoration: const InputDecoration(labelText: 'Пароль'),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        value: isPresentation,
                        title: const Text('Режим презентации'),
                        subtitle: const Text(
                          'Отображать демо-плашки и подсказки',
                        ),
                        onChanged: (value) =>
                            ref.read(presentationModeProvider.notifier).state =
                                value,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: auth.isLoading
                              ? null
                              : () async {
                                  final ok = await ref
                                      .read(authStateProvider.notifier)
                                      .login(
                                        phone: _phone.text.trim(),
                                        password: _password.text.trim(),
                                      );
                                  if (!ok) return;
                                  await ref
                                      .read(currentPersonaProvider.notifier)
                                      .switchAccount(current);
                                },
                          child: Text(
                            auth.isLoading
                                ? 'Входим...'
                                : 'Войти как ${current.name}',
                          ),
                        ),
                      ),
                      if (auth.error != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          auth.error!,
                          style: const TextStyle(color: AppColors.danger),
                        ),
                      ],
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Wrap(
                          spacing: AppSpacing.xs,
                          children: [
                            TextButton(
                              onPressed: () => context.go('/jury'),
                              child: const Text('Материалы для жюри'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _segmentHint(UserSegment segment) {
    switch (segment) {
      case UserSegment.child:
        return 'Простой интерфейс, цели, карманные деньги, безопасность';
      case UserSegment.teen:
        return 'Лимиты, подписки, самостоятельность, функции с опекуном';
      case UserSegment.adult:
        return 'Полный банк: карты, кредиты, инвестиции, аналитика';
      case UserSegment.business:
        return 'Денежный поток, платежи, роли, отчетность бизнеса';
    }
  }
}
