import 'dart:ui';

import 'package:flutter/material.dart';

import '../design/design_tokens.dart';

class GlassCard extends StatelessWidget {
  const GlassCard({required this.child, this.padding, super.key});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadii.card,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: padding ?? const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: AppRadii.card,
            color: AppColors.glass,
            border: Border.all(color: AppColors.glassStrong),
          ),
          child: child,
        ),
      ),
    );
  }
}
