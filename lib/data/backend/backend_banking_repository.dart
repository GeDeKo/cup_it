import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/models/demo_profile.dart';
import '../../domain/models/entities.dart';
import '../../domain/repositories/banking_repository.dart';

class BackendBankingRepository implements BankingRepository {
  BackendBankingRepository({required this.baseUrl, http.Client? client})
    : _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  @override
  Future<String?> createSession(DemoProfile profile) async {
    final http.Response response = await _client.post(
      Uri.parse('$baseUrl/sessions'),
      headers: <String, String>{'Content-Type': 'application/json'},
      body: jsonEncode(<String, dynamic>{'profile': _profileToJson(profile)}),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to create session: ${response.body}');
    }
    final Map<String, dynamic> data =
        jsonDecode(response.body) as Map<String, dynamic>;
    return data['sessionId'] as String;
  }

  @override
  Future<FinancialSnapshot> fetchSnapshot(
    DemoProfile profile, {
    String? sessionId,
  }) async {
    if (sessionId == null || sessionId.isEmpty) {
      throw Exception('Session id is required for backend snapshot');
    }
    final http.Response response = await _client.get(
      Uri.parse('$baseUrl/sessions/$sessionId/snapshot'),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to fetch snapshot: ${response.body}');
    }
    final Map<String, dynamic> data =
        jsonDecode(response.body) as Map<String, dynamic>;
    return _snapshotFromJson(data['snapshot'] as Map<String, dynamic>);
  }

  @override
  Future<void> updateProfile({
    required String sessionId,
    required DemoProfile profile,
  }) async {
    final http.Response response = await _client.put(
      Uri.parse('$baseUrl/sessions/$sessionId/profile'),
      headers: <String, String>{'Content-Type': 'application/json'},
      body: jsonEncode(<String, dynamic>{'profile': _profileToJson(profile)}),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to update profile: ${response.body}');
    }
  }

  @override
  Future<void> performAction({
    required String sessionId,
    required String action,
    required Map<String, dynamic> payload,
  }) async {
    final http.Response response = await _client.post(
      Uri.parse('$baseUrl/sessions/$sessionId/actions'),
      headers: <String, String>{'Content-Type': 'application/json'},
      body: jsonEncode(<String, dynamic>{'action': action, 'payload': payload}),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to perform action: ${response.body}');
    }
  }

  Map<String, dynamic> _profileToJson(DemoProfile profile) {
    return <String, dynamic>{
      'clientType': profile.clientType.name,
      'hasLoan': profile.hasLoan,
      'hasSavingsGoal': profile.hasSavingsGoal,
      'highOverspendingRisk': profile.highOverspendingRisk,
      'highPaymentRegularity': profile.highPaymentRegularity,
      'activityLevel': profile.activityLevel.name,
    };
  }

  FinancialSnapshot _snapshotFromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> userJson = json['user'] as Map<String, dynamic>;
    final Map<String, dynamic> accountJson =
        json['account'] as Map<String, dynamic>;
    final Map<String, dynamic> cardJson = json['card'] as Map<String, dynamic>;

    return FinancialSnapshot(
      user: User(
        id: userJson['id'] as String,
        firstName: userJson['firstName'] as String,
        isNewClient: userJson['isNewClient'] as bool,
      ),
      account: Account(
        id: accountJson['id'] as String,
        balance: (accountJson['balance'] as num).toDouble(),
        available: (accountJson['available'] as num).toDouble(),
        currency: accountJson['currency'] as String,
      ),
      card: CardInfo(
        id: cardJson['id'] as String,
        maskedNumber: cardJson['maskedNumber'] as String,
        isFrozen: cardJson['isFrozen'] as bool,
        monthlyLimit: (cardJson['monthlyLimit'] as num).toDouble(),
      ),
      transactions: (json['transactions'] as List<dynamic>).map((dynamic item) {
        final Map<String, dynamic> tx = item as Map<String, dynamic>;
        return Transaction(
          id: tx['id'] as String,
          category: tx['category'] as String,
          amount: (tx['amount'] as num).toDouble(),
          date: DateTime.parse(tx['date'] as String),
          isRegular: tx['isRegular'] as bool,
        );
      }).toList(),
      obligations: (json['obligations'] as List<dynamic>).map((dynamic item) {
        final Map<String, dynamic> p = item as Map<String, dynamic>;
        return PaymentObligation(
          id: p['id'] as String,
          title: p['title'] as String,
          amount: (p['amount'] as num).toDouble(),
          dueDate: DateTime.parse(p['dueDate'] as String),
          isAutopayEnabled: p['isAutopayEnabled'] as bool,
        );
      }).toList(),
      loan: json['loan'] == null
          ? null
          : (() {
              final Map<String, dynamic> l =
                  json['loan'] as Map<String, dynamic>;
              return Loan(
                id: l['id'] as String,
                nextPaymentAmount: (l['nextPaymentAmount'] as num).toDouble(),
                nextPaymentDate: DateTime.parse(l['nextPaymentDate'] as String),
                remainingDebt: (l['remainingDebt'] as num).toDouble(),
              );
            })(),
      goal: json['goal'] == null
          ? null
          : (() {
              final Map<String, dynamic> g =
                  json['goal'] as Map<String, dynamic>;
              return SavingsGoal(
                id: g['id'] as String,
                title: g['title'] as String,
                targetAmount: (g['targetAmount'] as num).toDouble(),
                currentAmount: (g['currentAmount'] as num).toDouble(),
                monthlyPlan: (g['monthlyPlan'] as num).toDouble(),
              );
            })(),
    );
  }
}
