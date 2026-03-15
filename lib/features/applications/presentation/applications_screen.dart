import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../shared/design/design_tokens.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/glass_card.dart';

class ApplicationsScreen extends ConsumerStatefulWidget {
  const ApplicationsScreen({super.key});

  @override
  ConsumerState<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends ConsumerState<ApplicationsScreen> {
  String _type = 'Кредитная карта';

  @override
  Widget build(BuildContext context) {
    final overviewAsync = ref.watch(overviewProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Заявки')),
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: overviewAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (overview) => ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Новая заявка',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    DropdownButtonFormField<String>(
                      initialValue: _type,
                      items: const [
                        DropdownMenuItem(
                          value: 'Кредитная карта',
                          child: Text('Кредитная карта'),
                        ),
                        DropdownMenuItem(
                          value: 'Потребительский кредит',
                          child: Text('Потребительский кредит'),
                        ),
                        DropdownMenuItem(
                          value: 'Ипотека',
                          child: Text('Ипотека'),
                        ),
                        DropdownMenuItem(
                          value: 'Премиум карта',
                          child: Text('Премиум карта'),
                        ),
                      ],
                      onChanged: (v) => setState(() => _type = v ?? _type),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    FilledButton(
                      onPressed: () async {
                        await ref
                            .read(bankingActionsProvider)
                            .createApplication(type: _type);
                      },
                      child: const Text('Отправить заявку'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ...overview.applications.map(
                (app) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: GlassCard(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(app.type),
                      subtitle: Text(
                        '${app.status} • ${app.createdAt.substring(0, 16)}',
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
