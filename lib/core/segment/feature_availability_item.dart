import 'segment_models.dart';

class FeatureAvailabilityItem {
  const FeatureAvailabilityItem({
    required this.title,
    required this.reason,
    required this.details,
  });

  final String title;
  final AvailabilityReason reason;
  final String details;
}
