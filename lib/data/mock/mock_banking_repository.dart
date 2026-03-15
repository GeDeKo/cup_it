import '../../core/constants/app_constants.dart';
import '../../domain/models/demo_profile.dart';
import '../../domain/models/entities.dart';
import '../../domain/models/enums.dart';
import '../../domain/repositories/banking_repository.dart';

class MockBankingRepository implements BankingRepository {
  @override
  Future<String?> createSession(DemoProfile profile) async => null;

  @override
  Future<void> updateProfile({
    required String sessionId,
    required DemoProfile profile,
  }) async {}

  @override
  Future<void> performAction({
    required String sessionId,
    required String action,
    required Map<String, dynamic> payload,
  }) async {}

  @override
  Future<FinancialSnapshot> fetchSnapshot(
    DemoProfile profile, {
    String? sessionId,
  }) async {
    await Future<void>.delayed(AppConstants.mockNetworkDelay);

    if (profile.forceError) {
      throw Exception('Ошибка загрузки данных в demo-режиме');
    }

    final DateTime now = DateTime.now();

    final User user = User(
      id: 'u-001',
      firstName: profile.clientType == ClientType.newClient ? 'Алина' : 'Илья',
      isNewClient: profile.clientType == ClientType.newClient,
    );

    final Account account = Account(
      id: 'a-001',
      balance: profile.highOverspendingRisk ? 38700 : 98200,
      available: profile.highOverspendingRisk ? 22400 : 91500,
      currency: 'RUB',
    );

    final CardInfo card = CardInfo(
      id: 'c-001',
      maskedNumber: '•••• 5521',
      isFrozen: false,
      monthlyLimit: profile.highOverspendingRisk ? 75000 : 120000,
    );

    final List<Transaction> transactions = <Transaction>[
      Transaction(
        id: 't-1',
        category: 'Еда',
        amount: profile.highOverspendingRisk ? 18400 : 9400,
        date: now.subtract(const Duration(days: 2)),
        isRegular: false,
      ),
      Transaction(
        id: 't-2',
        category: 'Транспорт',
        amount: 4300,
        date: now.subtract(const Duration(days: 3)),
        isRegular: true,
      ),
      Transaction(
        id: 't-3',
        category: 'Подписки',
        amount: 1290,
        date: now.subtract(const Duration(days: 7)),
        isRegular: true,
      ),
      Transaction(
        id: 't-4',
        category: 'Дом',
        amount: 5200,
        date: now.subtract(const Duration(days: 8)),
        isRegular: true,
      ),
      Transaction(
        id: 't-5',
        category: 'Переводы',
        amount: profile.activityLevel == ActivityLevel.low ? 22000 : 9000,
        date: now.subtract(const Duration(days: 1)),
        isRegular: false,
      ),
    ];

    final List<PaymentObligation> obligations = profile.highPaymentRegularity
        ? <PaymentObligation>[
            PaymentObligation(
              id: 'p-1',
              title: 'ЖКУ',
              amount: 5400,
              dueDate: now.add(const Duration(days: 2)),
              isAutopayEnabled: false,
            ),
            PaymentObligation(
              id: 'p-2',
              title: 'Мобильная связь',
              amount: 950,
              dueDate: now.add(const Duration(days: 4)),
              isAutopayEnabled: true,
            ),
          ]
        : <PaymentObligation>[];

    final Loan? loan = profile.hasLoan
        ? Loan(
            id: 'l-1',
            nextPaymentAmount: 12800,
            nextPaymentDate: now.add(
              Duration(days: profile.highOverspendingRisk ? 2 : 6),
            ),
            remainingDebt: 486000,
          )
        : null;

    final SavingsGoal? goal = profile.hasSavingsGoal
        ? SavingsGoal(
            id: 'g-1',
            title: 'Финподушка',
            targetAmount: 300000,
            currentAmount: profile.highOverspendingRisk ? 62000 : 168000,
            monthlyPlan: 15000,
          )
        : null;

    return FinancialSnapshot(
      user: user,
      account: account,
      card: card,
      transactions: transactions,
      obligations: obligations,
      loan: loan,
      goal: goal,
    );
  }
}
