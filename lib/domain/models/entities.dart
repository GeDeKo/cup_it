class User {
  const User({
    required this.id,
    required this.firstName,
    required this.isNewClient,
  });

  final String id;
  final String firstName;
  final bool isNewClient;
}

class Account {
  const Account({
    required this.id,
    required this.balance,
    required this.available,
    required this.currency,
  });

  final String id;
  final double balance;
  final double available;
  final String currency;
}

class CardInfo {
  const CardInfo({
    required this.id,
    required this.maskedNumber,
    required this.isFrozen,
    required this.monthlyLimit,
  });

  final String id;
  final String maskedNumber;
  final bool isFrozen;
  final double monthlyLimit;
}

class Transaction {
  const Transaction({
    required this.id,
    required this.category,
    required this.amount,
    required this.date,
    required this.isRegular,
  });

  final String id;
  final String category;
  final double amount;
  final DateTime date;
  final bool isRegular;
}

class Loan {
  const Loan({
    required this.id,
    required this.nextPaymentAmount,
    required this.nextPaymentDate,
    required this.remainingDebt,
  });

  final String id;
  final double nextPaymentAmount;
  final DateTime nextPaymentDate;
  final double remainingDebt;
}

class PaymentObligation {
  const PaymentObligation({
    required this.id,
    required this.title,
    required this.amount,
    required this.dueDate,
    required this.isAutopayEnabled,
  });

  final String id;
  final String title;
  final double amount;
  final DateTime dueDate;
  final bool isAutopayEnabled;
}

class SavingsGoal {
  const SavingsGoal({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    required this.monthlyPlan,
  });

  final String id;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final double monthlyPlan;

  double get progress =>
      targetAmount == 0 ? 0 : (currentAmount / targetAmount).clamp(0, 1);
}

class FinancialSnapshot {
  const FinancialSnapshot({
    required this.user,
    required this.account,
    required this.card,
    required this.transactions,
    required this.obligations,
    required this.loan,
    required this.goal,
  });

  final User user;
  final Account account;
  final CardInfo card;
  final List<Transaction> transactions;
  final List<PaymentObligation> obligations;
  final Loan? loan;
  final SavingsGoal? goal;
}
