import 'enums.dart';

class UserSignals {
  const UserSignals({
    required this.daysToNearestObligation,
    required this.daysToLoanPayment,
    required this.hasOverspendingSpike,
    required this.isSavingsDisciplined,
    required this.transferOnlyBehavior,
    required this.highPaymentRegularity,
  });

  final int? daysToNearestObligation;
  final int? daysToLoanPayment;
  final bool hasOverspendingSpike;
  final bool isSavingsDisciplined;
  final bool transferOnlyBehavior;
  final bool highPaymentRegularity;
}

class PriorityItem {
  const PriorityItem({
    required this.title,
    required this.subtitle,
    required this.reason,
    required this.cta,
    required this.scenario,
    required this.importance,
  });

  final String title;
  final String subtitle;
  final String reason;
  final String cta;
  final ScenarioType scenario;
  final Importance importance;
}

class NextBestAction {
  const NextBestAction({
    required this.title,
    required this.subtitle,
    required this.reason,
    required this.cta,
    required this.scenario,
  });

  final String title;
  final String subtitle;
  final String reason;
  final String cta;
  final ScenarioType scenario;
}

class ScenarioDigest {
  const ScenarioDigest({
    required this.scenario,
    required this.title,
    required this.metricLabel,
    required this.metricValue,
    required this.priority,
  });

  final ScenarioType scenario;
  final String title;
  final String metricLabel;
  final String metricValue;
  final int priority;
}

class PersonalizedRecommendation {
  const PersonalizedRecommendation({
    required this.title,
    required this.description,
    required this.reason,
    required this.cta,
    required this.scenario,
  });

  final String title;
  final String description;
  final String reason;
  final String cta;
  final ScenarioType scenario;
}

class PersonalizedHome {
  const PersonalizedHome({
    required this.summaryTitle,
    required this.summarySubtitle,
    required this.nextBestAction,
    required this.priorities,
    required this.scenarioDigests,
    required this.recommendations,
  });

  final String summaryTitle;
  final String summarySubtitle;
  final NextBestAction nextBestAction;
  final List<PriorityItem> priorities;
  final List<ScenarioDigest> scenarioDigests;
  final List<PersonalizedRecommendation> recommendations;
}
