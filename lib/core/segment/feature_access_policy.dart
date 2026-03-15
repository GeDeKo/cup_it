import 'segment_models.dart';

class FeatureAccessPolicy {
  const FeatureAccessPolicy();

  bool isAllowed({required UserSegment segment, required FeatureKey feature}) {
    switch (segment) {
      case UserSegment.child:
        return feature == FeatureKey.familyControl;
      case UserSegment.teen:
        return feature == FeatureKey.familyControl ||
            feature == FeatureKey.virtualCard;
      case UserSegment.adult:
        return true;
      case UserSegment.business:
        return feature == FeatureKey.businessModule ||
            feature == FeatureKey.loans ||
            feature == FeatureKey.creditCard;
    }
  }

  GuardedAction check({
    required UserSegment segment,
    required FeatureKey feature,
  }) {
    if (isAllowed(segment: segment, feature: feature)) {
      return GuardedAction(
        feature: feature,
        allowed: true,
        reason: AvailabilityReason.allowed,
        message: 'Доступно',
      );
    }

    if (segment == UserSegment.teen && feature == FeatureKey.branchGuardianCredit) {
      return GuardedAction(
        feature: feature,
        allowed: true,
        reason: AvailabilityReason.onlyWithGuardian,
        message: 'Доступно с опекуном',
      );
    }

    if (segment == UserSegment.teen && feature == FeatureKey.loans) {
      return GuardedAction(
        feature: feature,
        allowed: false,
        reason: AvailabilityReason.onlyAtBranch,
        message: 'Оформление в отделении',
      );
    }

    if (feature == FeatureKey.businessModule && segment != UserSegment.business) {
      return GuardedAction(
        feature: feature,
        allowed: false,
        reason: AvailabilityReason.onlyBusiness,
        message: 'Только для бизнеса',
      );
    }

    if (segment == UserSegment.child || segment == UserSegment.teen) {
      return GuardedAction(
        feature: feature,
        allowed: false,
        reason: AvailabilityReason.ageRestricted,
        message: 'Доступно после 18 лет',
      );
    }

    return GuardedAction(
      feature: feature,
      allowed: false,
      reason: AvailabilityReason.hiddenForSegment,
      message: 'Недоступно для выбранного профиля',
    );
  }

  String explain({required UserSegment segment, required FeatureKey feature}) {
    return check(segment: segment, feature: feature).message;
  }
}
