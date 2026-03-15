import 'package:flutter/material.dart';

import '../../core/segment/segment_models.dart';

class AvailabilityBadge extends StatelessWidget {
  const AvailabilityBadge({super.key, required this.reason});

  final AvailabilityReason reason;

  @override
  Widget build(BuildContext context) {
    final palette = _palette(reason);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: palette.$1,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: palette.$2),
      ),
      child: Text(
        _label(reason),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: palette.$3,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  (Color, Color, Color) _palette(AvailabilityReason reason) {
    switch (reason) {
      case AvailabilityReason.allowed:
        return (const Color(0x1E43C487), const Color(0x6B45D58F), const Color(0xFFB8FFE0));
      case AvailabilityReason.ageRestricted:
        return (const Color(0x1EFFB45C), const Color(0x66FFB45C), const Color(0xFFFFE2B8));
      case AvailabilityReason.onlyWithGuardian:
        return (const Color(0x1E6AA2FF), const Color(0x666AA2FF), const Color(0xFFD8E6FF));
      case AvailabilityReason.onlyAtBranch:
        return (const Color(0x1E9D8BFF), const Color(0x669D8BFF), const Color(0xFFE0DAFF));
      case AvailabilityReason.onlyBusiness:
        return (const Color(0x1EA6B3C2), const Color(0x66A6B3C2), const Color(0xFFE3EBF5));
      case AvailabilityReason.hiddenForSegment:
        return (const Color(0x1E9AA3B2), const Color(0x669AA3B2), const Color(0xFFD9DFE7));
    }
  }

  String _label(AvailabilityReason reason) {
    switch (reason) {
      case AvailabilityReason.allowed:
        return 'Доступно';
      case AvailabilityReason.ageRestricted:
        return 'С 18 лет';
      case AvailabilityReason.onlyWithGuardian:
        return 'С опекуном';
      case AvailabilityReason.onlyAtBranch:
        return 'В отделении';
      case AvailabilityReason.onlyBusiness:
        return 'Только для бизнеса';
      case AvailabilityReason.hiddenForSegment:
        return 'Скрыто';
    }
  }
}
