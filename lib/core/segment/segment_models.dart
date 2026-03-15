enum UserSegment { child, teen, adult, business }
enum SegmentRole { child, teen, adult, business }

enum FeatureKey {
  loans,
  creditCard,
  riskyInvestments,
  businessModule,
  familyControl,
  virtualCard,
  branchGuardianCredit,
}

enum AvailabilityReason {
  allowed,
  onlyWithGuardian,
  onlyAtBranch,
  ageRestricted,
  onlyBusiness,
  hiddenForSegment,
}

class GuardedAction {
  const GuardedAction({
    required this.feature,
    required this.allowed,
    required this.reason,
    required this.message,
  });

  final FeatureKey feature;
  final bool allowed;
  final AvailabilityReason reason;
  final String message;
}

class DemoPersona {
  const DemoPersona({
    required this.id,
    required this.name,
    required this.age,
    required this.segment,
    required this.subtitle,
  });

  final String id;
  final String name;
  final int age;
  final UserSegment segment;
  final String subtitle;
}

extension SegmentRoleX on UserSegment {
  SegmentRole get role {
    switch (this) {
      case UserSegment.child:
        return SegmentRole.child;
      case UserSegment.teen:
        return SegmentRole.teen;
      case UserSegment.adult:
        return SegmentRole.adult;
      case UserSegment.business:
        return SegmentRole.business;
    }
  }
}
