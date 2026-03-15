import '../models/demo_profile.dart';
import '../models/entities.dart';

abstract class BankingRepository {
  Future<FinancialSnapshot> fetchSnapshot(
    DemoProfile profile, {
    String? sessionId,
  });

  Future<String?> createSession(DemoProfile profile) async => null;

  Future<void> updateProfile({
    required String sessionId,
    required DemoProfile profile,
  }) async {}

  Future<void> performAction({
    required String sessionId,
    required String action,
    required Map<String, dynamic> payload,
  }) async {}
}
