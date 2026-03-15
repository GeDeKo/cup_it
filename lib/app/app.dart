import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/segment/segment_engine.dart';
import '../shared/design/segment_theme_factory.dart';
import 'providers.dart';
import 'router.dart';

class BankingShowcaseApp extends ConsumerWidget {
  const BankingShowcaseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final segment = ref.watch(currentSegmentProvider);
    final title = SegmentEngine.theme(segment).title;
    return MaterialApp.router(
      title: title,
      debugShowCheckedModeBanner: false,
      theme: SegmentThemeFactory.build(segment),
      routerConfig: appRouter,
    );
  }
}
