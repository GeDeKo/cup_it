import 'feature_access_policy.dart';
import 'segment_models.dart';

class ProductEligibilityService {
  const ProductEligibilityService({
    this.policy = const FeatureAccessPolicy(),
  });

  final FeatureAccessPolicy policy;

  GuardedAction checkLoan(UserSegment segment) =>
      policy.check(segment: segment, feature: FeatureKey.loans);

  GuardedAction checkCreditCard(UserSegment segment) =>
      policy.check(segment: segment, feature: FeatureKey.creditCard);

  GuardedAction checkInvestments(UserSegment segment) =>
      policy.check(segment: segment, feature: FeatureKey.riskyInvestments);

  GuardedAction checkBusiness(UserSegment segment) =>
      policy.check(segment: segment, feature: FeatureKey.businessModule);
}
