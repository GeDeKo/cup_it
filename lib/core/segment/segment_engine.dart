import 'package:flutter/material.dart';

import '../../shared/design/design_tokens.dart';
import 'segment_models.dart';

class SegmentThemePack {
  const SegmentThemePack({
    required this.gradient,
    required this.accent,
    required this.surface,
    required this.title,
  });

  final List<Color> gradient;
  final Color accent;
  final Color surface;
  final String title;
}

class SegmentEngine {
  static SegmentThemePack theme(UserSegment segment) {
    switch (segment) {
      case UserSegment.child:
        return const SegmentThemePack(
          gradient: [Color(0xFFF4FAFF), Color(0xFFDDF1FF), Color(0xFFCFF7EE)],
          accent: Color(0xFF2A8BFF),
          surface: Color(0xE6FFFFFF),
          title: 'Банк для детей',
        );
      case UserSegment.teen:
        return const SegmentThemePack(
          gradient: [Color(0xFF0B1335), Color(0xFF20358A), Color(0xFF1A6BC6)],
          accent: Color(0xFF7EA6FF),
          surface: Color(0x26FFFFFF),
          title: 'Банк для подростков',
        );
      case UserSegment.adult:
        return const SegmentThemePack(
          gradient: [AppColors.bgDeep, AppColors.bgMid, AppColors.bgLight],
          accent: Color(0xFF8FD3FF),
          surface: Color(0x22FFFFFF),
          title: 'Банк для взрослых',
        );
      case UserSegment.business:
        return const SegmentThemePack(
          gradient: [Color(0xFF0E1A2E), Color(0xFF1B304D), Color(0xFF2A4569)],
          accent: Color(0xFF9CBEE2),
          surface: Color(0x26FFFFFF),
          title: 'Бизнес-банк',
        );
    }
  }

  static Set<FeatureKey> features(UserSegment segment) {
    switch (segment) {
      case UserSegment.child:
        return {FeatureKey.familyControl};
      case UserSegment.teen:
        return {
          FeatureKey.familyControl,
          FeatureKey.virtualCard,
          FeatureKey.branchGuardianCredit,
        };
      case UserSegment.adult:
        return {
          FeatureKey.loans,
          FeatureKey.creditCard,
          FeatureKey.riskyInvestments,
          FeatureKey.virtualCard,
        };
      case UserSegment.business:
        return {
          FeatureKey.businessModule,
          FeatureKey.loans,
          FeatureKey.creditCard,
          FeatureKey.riskyInvestments,
        };
    }
  }

  static String segmentHeadline(UserSegment segment) {
    switch (segment) {
      case UserSegment.child:
        return 'Карманные деньги и цели';
      case UserSegment.teen:
        return 'Финансовая самостоятельность';
      case UserSegment.adult:
        return 'Контроль и рост капитала';
      case UserSegment.business:
        return 'Финансы бизнеса под контролем';
    }
  }

  static String lockLabel(UserSegment segment, FeatureKey feature) {
    if (segment == UserSegment.child &&
        (feature == FeatureKey.loans || feature == FeatureKey.creditCard)) {
      return 'Недоступно';
    }
    if (segment == UserSegment.teen &&
        feature == FeatureKey.branchGuardianCredit) {
      return 'Доступно с опекуном';
    }
    if (segment == UserSegment.teen && feature == FeatureKey.loans) {
      return 'Оформление в отделении';
    }
    if (feature == FeatureKey.riskyInvestments &&
        (segment == UserSegment.child || segment == UserSegment.teen)) {
      return '18+';
    }
    return 'Доступно';
  }
}
