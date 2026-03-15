import 'enums.dart';

class DemoProfile {
  const DemoProfile({
    required this.clientType,
    required this.hasLoan,
    required this.hasSavingsGoal,
    required this.highOverspendingRisk,
    required this.highPaymentRegularity,
    required this.activityLevel,
    required this.forceError,
  });

  const DemoProfile.defaults()
    : clientType = ClientType.experienced,
      hasLoan = true,
      hasSavingsGoal = true,
      highOverspendingRisk = false,
      highPaymentRegularity = true,
      activityLevel = ActivityLevel.medium,
      forceError = false;

  final ClientType clientType;
  final bool hasLoan;
  final bool hasSavingsGoal;
  final bool highOverspendingRisk;
  final bool highPaymentRegularity;
  final ActivityLevel activityLevel;
  final bool forceError;

  DemoProfile copyWith({
    ClientType? clientType,
    bool? hasLoan,
    bool? hasSavingsGoal,
    bool? highOverspendingRisk,
    bool? highPaymentRegularity,
    ActivityLevel? activityLevel,
    bool? forceError,
  }) {
    return DemoProfile(
      clientType: clientType ?? this.clientType,
      hasLoan: hasLoan ?? this.hasLoan,
      hasSavingsGoal: hasSavingsGoal ?? this.hasSavingsGoal,
      highOverspendingRisk: highOverspendingRisk ?? this.highOverspendingRisk,
      highPaymentRegularity:
          highPaymentRegularity ?? this.highPaymentRegularity,
      activityLevel: activityLevel ?? this.activityLevel,
      forceError: forceError ?? this.forceError,
    );
  }
}
