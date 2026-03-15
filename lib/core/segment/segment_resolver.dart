import 'segment_models.dart';

class SegmentResolver {
  const SegmentResolver();

  UserSegment resolveByAge({required int age, bool isBusiness = false}) {
    if (isBusiness) return UserSegment.business;
    if (age < 14) return UserSegment.child;
    if (age < 18) return UserSegment.teen;
    return UserSegment.adult;
  }
}
