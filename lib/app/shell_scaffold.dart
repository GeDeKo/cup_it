import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/segment/segment_engine.dart';
import '../core/segment/segment_models.dart';
import '../shared/design/design_tokens.dart';
import 'providers.dart';

class ShellScaffold extends ConsumerWidget {
  const ShellScaffold({required this.location, required this.child, super.key});

  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final segment = ref.watch(currentSegmentProvider);
    final palette = SegmentEngine.theme(segment);
    final currentIndex = _locationToIndex(location, segment);

    return Scaffold(
      body: child,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          AppSpacing.md,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.glass,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: AppColors.glassStrong),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x55000000),
                    blurRadius: 22,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: NavigationBarTheme(
                data: NavigationBarThemeData(
                  backgroundColor: Colors.transparent,
                  indicatorColor: palette.accent.withValues(alpha: 0.24),
                  iconTheme: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return const IconThemeData(color: AppColors.textPrimary);
                    }
                    return const IconThemeData(color: AppColors.textMuted);
                  }),
                  labelTextStyle: WidgetStatePropertyAll(
                    Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                child: NavigationBar(
                  selectedIndex: currentIndex,
                  backgroundColor: Colors.transparent,
                  onDestinationSelected: (index) {
                    if (segment == UserSegment.business) {
                      switch (index) {
                        case 0:
                          context.go('/home');
                          break;
                        case 1:
                          context.go('/business/payments');
                          break;
                        case 2:
                          context.go('/business/analytics');
                          break;
                        case 3:
                          context.go('/catalog');
                          break;
                        case 4:
                          context.go('/profile');
                          break;
                      }
                      return;
                    }

                    switch (index) {
                      case 0:
                        context.go('/home');
                        break;
                      case 1:
                        context.go('/payments');
                        break;
                      case 2:
                        context.go('/catalog');
                        break;
                      case 3:
                        context.go('/history');
                        break;
                      case 4:
                        context.go('/profile');
                        break;
                    }
                  },
                  destinations: segment == UserSegment.business
                      ? const [
                          NavigationDestination(
                            icon: Icon(Icons.home_outlined),
                            label: 'Главная',
                          ),
                          NavigationDestination(
                            icon: Icon(Icons.payments_outlined),
                            label: 'Платежки',
                          ),
                          NavigationDestination(
                            icon: Icon(Icons.analytics_outlined),
                            label: 'Аналитика',
                          ),
                          NavigationDestination(
                            icon: Icon(Icons.grid_view_outlined),
                            label: 'Каталог',
                          ),
                          NavigationDestination(
                            icon: Icon(Icons.person_outline),
                            label: 'Профиль',
                          ),
                        ]
                      : const [
                          NavigationDestination(
                            icon: Icon(Icons.home_outlined),
                            label: 'Главная',
                          ),
                          NavigationDestination(
                            icon: Icon(Icons.payments_outlined),
                            label: 'Платежи',
                          ),
                          NavigationDestination(
                            icon: Icon(Icons.grid_view_outlined),
                            label: 'Каталог',
                          ),
                          NavigationDestination(
                            icon: Icon(Icons.receipt_long_outlined),
                            label: 'История',
                          ),
                          NavigationDestination(
                            icon: Icon(Icons.person_outline),
                            label: 'Профиль',
                          ),
                        ],
                ),
              ),
            ),
          ),
        ),
      ),
      backgroundColor: AppColors.bgDeep,
    );
  }

  int _locationToIndex(String path, UserSegment segment) {
    if (segment == UserSegment.business) {
      if (path.startsWith('/business/payments')) return 1;
      if (path.startsWith('/business/analytics')) return 2;
      if (path.startsWith('/catalog')) return 3;
      if (path.startsWith('/profile')) return 4;
      return 0;
    }

    if (path.startsWith('/payments')) return 1;
    if (path.startsWith('/catalog')) return 2;
    if (path.startsWith('/history')) return 3;
    if (path.startsWith('/profile')) return 4;
    return 0;
  }
}
