class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.phone,
    required this.tier,
    required this.cashbackLevel,
  });

  final String id;
  final String name;
  final String phone;
  final String tier;
  final String cashbackLevel;
}

class SecurityModel {
  const SecurityModel({
    required this.dailyTransferLimit,
    required this.dailyPaymentLimit,
    required this.transferSpentToday,
    required this.paymentSpentToday,
  });

  final double dailyTransferLimit;
  final double dailyPaymentLimit;
  final double transferSpentToday;
  final double paymentSpentToday;
}

class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.title,
    required this.text,
    required this.read,
    required this.time,
  });

  final String id;
  final String title;
  final String text;
  final bool read;
  final String time;
}

class SupportMessage {
  const SupportMessage({
    required this.id,
    required this.author,
    required this.text,
    required this.time,
  });

  final String id;
  final String author;
  final String text;
  final String time;
}

class ApplicationModel {
  const ApplicationModel({
    required this.id,
    required this.type,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String type;
  final String status;
  final String createdAt;
}

class BankCardModel {
  const BankCardModel({
    required this.id,
    required this.title,
    required this.panMasked,
    required this.balance,
    required this.type,
    required this.format,
    required this.gradient,
    required this.frozen,
  });

  final String id;
  final String title;
  final String panMasked;
  final double balance;
  final String type;
  final String format;
  final List<String> gradient;
  final bool frozen;
}

class Beneficiary {
  const Beneficiary({
    required this.id,
    required this.name,
    required this.phone,
  });

  final String id;
  final String name;
  final String phone;
}

class PaymentTemplate {
  const PaymentTemplate({
    required this.id,
    required this.title,
    required this.amount,
    required this.dueInDays,
    required this.account,
  });

  final String id;
  final String title;
  final double amount;
  final int dueInDays;
  final String account;
}

class PaymentService {
  const PaymentService({
    required this.id,
    required this.title,
    required this.category,
  });

  final String id;
  final String title;
  final String category;
}

class SubscriptionModel {
  const SubscriptionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.enabled,
  });

  final String id;
  final String title;
  final double amount;
  final bool enabled;
}

class LoanModel {
  const LoanModel({
    required this.id,
    required this.title,
    required this.nextPayment,
    required this.dueInDays,
    required this.remainingDebt,
  });

  final String id;
  final String title;
  final double nextPayment;
  final int dueInDays;
  final double remainingDebt;
}

class DepositModel {
  const DepositModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.rate,
    required this.until,
  });

  final String id;
  final String title;
  final double amount;
  final double rate;
  final String until;
}

class GoalModel {
  const GoalModel({
    required this.id,
    required this.title,
    required this.target,
    required this.current,
  });

  final String id;
  final String title;
  final double target;
  final double current;

  double get progress => target == 0 ? 0 : (current / target).clamp(0, 1);
}

class CashbackOffer {
  const CashbackOffer({
    required this.id,
    required this.partner,
    required this.percent,
    required this.active,
  });

  final String id;
  final String partner;
  final int percent;
  final bool active;
}

class StockOffer {
  const StockOffer({
    required this.id,
    required this.ticker,
    required this.name,
    required this.price,
  });

  final String id;
  final String ticker;
  final String name;
  final double price;
}

class PortfolioItem {
  const PortfolioItem({
    required this.ticker,
    required this.lots,
    required this.avgPrice,
  });

  final String ticker;
  final int lots;
  final double avgPrice;
}

class TransactionItem {
  const TransactionItem({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
  });

  final String id;
  final String title;
  final double amount;
  final String date;
}

class InsightItem {
  const InsightItem({
    required this.id,
    required this.title,
    required this.reason,
  });

  final String id;
  final String title;
  final String reason;
}

class AiPurchaseInsight {
  const AiPurchaseInsight({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.expectedBenefit,
  });

  final String id;
  final String title;
  final String description;
  final String category;
  final String expectedBenefit;
}

class MerchantOffer {
  const MerchantOffer({
    required this.id,
    required this.merchant,
    required this.category,
    required this.cashbackPercent,
    required this.discountPercent,
    required this.until,
  });

  final String id;
  final String merchant;
  final String category;
  final int cashbackPercent;
  final int discountPercent;
  final String until;
}

class PurchasePatternSummary {
  const PurchasePatternSummary({
    required this.topCategory,
    required this.monthlySpend,
    required this.repeatingSubscriptions,
  });

  final String topCategory;
  final double monthlySpend;
  final int repeatingSubscriptions;
}

class AccountModel {
  const AccountModel({
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

class BankOverview {
  const BankOverview({
    required this.user,
    required this.account,
    required this.security,
    required this.cards,
    required this.beneficiaries,
    required this.paymentTemplates,
    required this.paymentServices,
    required this.subscriptions,
    required this.loans,
    required this.deposits,
    required this.goals,
    required this.cashbackOffers,
    required this.stockOffers,
    required this.portfolio,
    required this.applications,
    required this.notifications,
    required this.supportThread,
    required this.transactions,
    required this.insights,
    required this.aiInsights,
    required this.merchantOffers,
    required this.purchasePattern,
  });

  final AppUser user;
  final AccountModel account;
  final SecurityModel security;
  final List<BankCardModel> cards;
  final List<Beneficiary> beneficiaries;
  final List<PaymentTemplate> paymentTemplates;
  final List<PaymentService> paymentServices;
  final List<SubscriptionModel> subscriptions;
  final List<LoanModel> loans;
  final List<DepositModel> deposits;
  final List<GoalModel> goals;
  final List<CashbackOffer> cashbackOffers;
  final List<StockOffer> stockOffers;
  final List<PortfolioItem> portfolio;
  final List<ApplicationModel> applications;
  final List<NotificationModel> notifications;
  final List<SupportMessage> supportThread;
  final List<TransactionItem> transactions;
  final List<InsightItem> insights;
  final List<AiPurchaseInsight> aiInsights;
  final List<MerchantOffer> merchantOffers;
  final PurchasePatternSummary purchasePattern;
}

class AuthResult {
  const AuthResult({required this.token, required this.user});

  final String token;
  final AppUser user;
}
