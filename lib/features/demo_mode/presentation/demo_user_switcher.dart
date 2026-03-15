import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../shared/design/design_tokens.dart';

class DemoUserSwitcher extends ConsumerWidget {
  const DemoUserSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(currentPersonaProvider);

    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: demoPersonas
          .map(
            (p) => ChoiceChip(
              label: Text('${p.name} • ${p.subtitle}'),
              selected: p.id == current.id,
              onSelected: (_) async =>
                  ref.read(currentPersonaProvider.notifier).switchAccount(p),
            ),
          )
          .toList(),
    );
  }
}
