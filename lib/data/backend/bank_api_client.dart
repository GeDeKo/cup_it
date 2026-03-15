import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/models/bank_app_models.dart';

class BankApiClient {
  BankApiClient({required this.baseUrl, http.Client? client})
    : _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  Future<AuthResult> register({
    required String name,
    required String phone,
    required String password,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'phone': phone, 'password': password}),
    );
    _check(response);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return AuthResult(
      token: data['token'] as String,
      user: _userFromJson(data['user'] as Map<String, dynamic>),
    );
  }

  Future<AuthResult> login({
    required String phone,
    required String password,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone, 'password': password}),
    );
    _check(response);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return AuthResult(
      token: data['token'] as String,
      user: _userFromJson(data['user'] as Map<String, dynamic>),
    );
  }

  Future<void> logout(String token) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/auth/logout'),
      headers: _authHeaders(token),
    );
    _check(response);
  }

  Future<AppUser> switchDemoAccount(
    String token, {
    required String personaId,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/auth/demo/switch'),
      headers: _authHeaders(token),
      body: jsonEncode({'personaId': personaId}),
    );
    _check(response);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return _userFromJson(data['user'] as Map<String, dynamic>);
  }

  Future<BankOverview> getOverview(String token) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/bank/overview'),
      headers: _authHeaders(token),
    );
    _check(response);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return _overviewFromJson(data);
  }

  Future<void> markAllNotificationsRead(String token) async {
    await _postAction(token, '/bank/notifications/read-all', {});
  }

  Future<void> sendSupportMessage(String token, {required String text}) async {
    await _postAction(token, '/bank/support/message', {'text': text});
  }

  Future<void> updateSecurity(
    String token, {
    required double dailyTransferLimit,
    required double dailyPaymentLimit,
  }) async {
    await _postAction(token, '/bank/security/update', {
      'dailyTransferLimit': dailyTransferLimit,
      'dailyPaymentLimit': dailyPaymentLimit,
    });
  }

  Future<void> createApplication(String token, {required String type}) async {
    await _postAction(token, '/bank/applications/create', {'type': type});
  }

  Future<void> transfer(
    String token, {
    required String to,
    required double amount,
    String comment = '',
    String confirmCode = '',
  }) async {
    await _postAction(token, '/bank/transfer', {
      'to': to,
      'amount': amount,
      'comment': comment,
      'confirmCode': confirmCode,
    });
  }

  Future<void> topUp(
    String token, {
    required double amount,
    String source = 'СБП',
    String confirmCode = '',
  }) async {
    await _postAction(token, '/bank/topup', {
      'amount': amount,
      'source': source,
      'confirmCode': confirmCode,
    });
  }

  Future<void> payTemplate(
    String token, {
    required String paymentId,
    String confirmCode = '',
  }) async {
    await _postAction(token, '/bank/payments/pay', {
      'paymentId': paymentId,
      'confirmCode': confirmCode,
    });
  }

  Future<void> payCustom(
    String token, {
    required String title,
    required String account,
    required double amount,
    String confirmCode = '',
  }) async {
    await _postAction(token, '/bank/payments/custom', {
      'title': title,
      'account': account,
      'amount': amount,
      'confirmCode': confirmCode,
    });
  }

  Future<void> createTemplate(
    String token, {
    required String title,
    required String account,
    required double amount,
  }) async {
    await _postAction(token, '/bank/templates/create', {
      'title': title,
      'account': account,
      'amount': amount,
    });
  }

  Future<void> payLoan(
    String token, {
    required String loanId,
    required double amount,
    String confirmCode = '',
  }) async {
    await _postAction(token, '/bank/loans/pay', {
      'loanId': loanId,
      'amount': amount,
      'confirmCode': confirmCode,
    });
  }

  Future<void> openDeposit(
    String token, {
    required double amount,
    int termDays = 365,
    String confirmCode = '',
  }) async {
    await _postAction(token, '/bank/deposits/open', {
      'amount': amount,
      'termDays': termDays,
      'confirmCode': confirmCode,
    });
  }

  Future<void> createGoal(
    String token, {
    required String title,
    required double target,
  }) async {
    await _postAction(token, '/bank/goals/create', {
      'title': title,
      'target': target,
    });
  }

  Future<void> topupGoal(
    String token, {
    required String goalId,
    required double amount,
  }) async {
    await _postAction(token, '/bank/goals/topup', {
      'goalId': goalId,
      'amount': amount,
    });
  }

  Future<void> toggleSubscription(String token, {required String id}) async {
    await _postAction(token, '/bank/subscriptions/toggle', {'id': id});
  }

  Future<void> toggleCard(
    String token, {
    required String cardId,
    required bool frozen,
  }) async {
    await _postAction(token, '/bank/cards/freeze', {
      'cardId': cardId,
      'frozen': frozen,
    });
  }

  Future<void> reissueCard(String token, {required String cardId}) async {
    await _postAction(token, '/bank/cards/reissue', {'cardId': cardId});
  }

  Future<void> activateCashback(String token, {required String offerId}) async {
    await _postAction(token, '/bank/offers/cashback/activate', {
      'offerId': offerId,
    });
  }

  Future<void> buyStock(
    String token, {
    required String ticker,
    required int lots,
    String confirmCode = '',
  }) async {
    await _postAction(token, '/bank/stocks/buy', {
      'ticker': ticker,
      'lots': lots,
      'confirmCode': confirmCode,
    });
  }

  Future<void> sellStock(
    String token, {
    required String ticker,
    required int lots,
  }) async {
    await _postAction(token, '/bank/stocks/sell', {
      'ticker': ticker,
      'lots': lots,
    });
  }

  Future<void> _postAction(
    String token,
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await _client.post(
      Uri.parse('$baseUrl$path'),
      headers: _authHeaders(token),
      body: jsonEncode(body),
    );
    _check(response);
  }

  Map<String, String> _authHeaders(String token) => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  void _check(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }
    throw Exception('Ошибка API ${response.statusCode}: ${response.body}');
  }

  AppUser _userFromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      tier: json['tier'] as String,
      cashbackLevel: json['cashbackLevel'] as String,
    );
  }

  BankOverview _overviewFromJson(Map<String, dynamic> json) {
    final user = _userFromJson(json['user'] as Map<String, dynamic>);
    final accountJson = json['account'] as Map<String, dynamic>;
    final securityJson = json['security'] as Map<String, dynamic>;

    return BankOverview(
      user: user,
      account: AccountModel(
        id: accountJson['id'] as String,
        balance: (accountJson['balance'] as num).toDouble(),
        available: (accountJson['available'] as num).toDouble(),
        currency: accountJson['currency'] as String,
      ),
      security: SecurityModel(
        dailyTransferLimit: (securityJson['dailyTransferLimit'] as num)
            .toDouble(),
        dailyPaymentLimit: (securityJson['dailyPaymentLimit'] as num)
            .toDouble(),
        transferSpentToday: (securityJson['transferSpentToday'] as num)
            .toDouble(),
        paymentSpentToday: (securityJson['paymentSpentToday'] as num)
            .toDouble(),
      ),
      cards: (json['cards'] as List<dynamic>)
          .map((item) => item as Map<String, dynamic>)
          .map(
            (card) => BankCardModel(
              id: card['id'] as String,
              title: card['title'] as String,
              panMasked: card['panMasked'] as String,
              balance: (card['balance'] as num).toDouble(),
              type: card['type'] as String,
              format: card['format'] as String,
              gradient: (card['gradient'] as List<dynamic>)
                  .map((e) => e as String)
                  .toList(),
              frozen: card['frozen'] as bool,
            ),
          )
          .toList(),
      beneficiaries: (json['beneficiaries'] as List<dynamic>)
          .map((item) => item as Map<String, dynamic>)
          .map(
            (b) => Beneficiary(
              id: b['id'] as String,
              name: b['name'] as String,
              phone: b['phone'] as String,
            ),
          )
          .toList(),
      paymentTemplates: (json['paymentTemplates'] as List<dynamic>)
          .map((item) => item as Map<String, dynamic>)
          .map(
            (p) => PaymentTemplate(
              id: p['id'] as String,
              title: p['title'] as String,
              amount: (p['amount'] as num).toDouble(),
              dueInDays: p['dueInDays'] as int,
              account: p['account'] as String,
            ),
          )
          .toList(),
      paymentServices: (json['paymentServices'] as List<dynamic>)
          .map((item) => item as Map<String, dynamic>)
          .map(
            (p) => PaymentService(
              id: p['id'] as String,
              title: p['title'] as String,
              category: p['category'] as String,
            ),
          )
          .toList(),
      subscriptions: (json['subscriptions'] as List<dynamic>)
          .map((item) => item as Map<String, dynamic>)
          .map(
            (s) => SubscriptionModel(
              id: s['id'] as String,
              title: s['title'] as String,
              amount: (s['amount'] as num).toDouble(),
              enabled: s['enabled'] as bool,
            ),
          )
          .toList(),
      loans: (json['loans'] as List<dynamic>)
          .map((item) => item as Map<String, dynamic>)
          .map(
            (l) => LoanModel(
              id: l['id'] as String,
              title: l['title'] as String,
              nextPayment: (l['nextPayment'] as num).toDouble(),
              dueInDays: l['dueInDays'] as int,
              remainingDebt: (l['remainingDebt'] as num).toDouble(),
            ),
          )
          .toList(),
      deposits: (json['deposits'] as List<dynamic>)
          .map((item) => item as Map<String, dynamic>)
          .map(
            (d) => DepositModel(
              id: d['id'] as String,
              title: d['title'] as String,
              amount: (d['amount'] as num).toDouble(),
              rate: (d['rate'] as num).toDouble(),
              until: d['until'] as String,
            ),
          )
          .toList(),
      goals: (json['goals'] as List<dynamic>)
          .map((item) => item as Map<String, dynamic>)
          .map(
            (g) => GoalModel(
              id: g['id'] as String,
              title: g['title'] as String,
              target: (g['target'] as num).toDouble(),
              current: (g['current'] as num).toDouble(),
            ),
          )
          .toList(),
      cashbackOffers:
          ((json['offers'] as Map<String, dynamic>)['cashback']
                  as List<dynamic>)
              .map((item) => item as Map<String, dynamic>)
              .map(
                (c) => CashbackOffer(
                  id: c['id'] as String,
                  partner: c['partner'] as String,
                  percent: c['percent'] as int,
                  active: c['active'] as bool,
                ),
              )
              .toList(),
      stockOffers:
          ((json['offers'] as Map<String, dynamic>)['stocks'] as List<dynamic>)
              .map((item) => item as Map<String, dynamic>)
              .map(
                (s) => StockOffer(
                  id: s['id'] as String,
                  ticker: s['ticker'] as String,
                  name: s['name'] as String,
                  price: (s['price'] as num).toDouble(),
                ),
              )
              .toList(),
      portfolio: (json['portfolio'] as List<dynamic>)
          .map((item) => item as Map<String, dynamic>)
          .map(
            (p) => PortfolioItem(
              ticker: p['ticker'] as String,
              lots: p['lots'] as int,
              avgPrice: (p['avgPrice'] as num).toDouble(),
            ),
          )
          .toList(),
      applications: (json['applications'] as List<dynamic>)
          .map((item) => item as Map<String, dynamic>)
          .map(
            (a) => ApplicationModel(
              id: a['id'] as String,
              type: a['type'] as String,
              status: a['status'] as String,
              createdAt: a['createdAt'] as String,
            ),
          )
          .toList(),
      notifications: (json['notifications'] as List<dynamic>)
          .map((item) => item as Map<String, dynamic>)
          .map(
            (n) => NotificationModel(
              id: n['id'] as String,
              title: n['title'] as String,
              text: n['text'] as String,
              read: n['read'] as bool,
              time: n['time'] as String,
            ),
          )
          .toList(),
      supportThread: (json['supportThread'] as List<dynamic>)
          .map((item) => item as Map<String, dynamic>)
          .map(
            (m) => SupportMessage(
              id: m['id'] as String,
              author: m['author'] as String,
              text: m['text'] as String,
              time: m['time'] as String,
            ),
          )
          .toList(),
      transactions: (json['transactions'] as List<dynamic>)
          .map((item) => item as Map<String, dynamic>)
          .map(
            (t) => TransactionItem(
              id: t['id'] as String,
              title: t['title'] as String,
              amount: (t['amount'] as num).toDouble(),
              date: t['date'] as String,
            ),
          )
          .toList(),
      insights: (json['insights'] as List<dynamic>)
          .map((item) => item as Map<String, dynamic>)
          .map(
            (i) => InsightItem(
              id: i['id'] as String,
              title: i['title'] as String,
              reason: i['reason'] as String,
            ),
          )
          .toList(),
      aiInsights: (json['aiInsights'] as List<dynamic>)
          .map((item) => item as Map<String, dynamic>)
          .map(
            (i) => AiPurchaseInsight(
              id: i['id'] as String,
              title: i['title'] as String,
              description: i['description'] as String,
              category: i['category'] as String,
              expectedBenefit: i['expectedBenefit'] as String,
            ),
          )
          .toList(),
      merchantOffers: (json['merchantOffers'] as List<dynamic>)
          .map((item) => item as Map<String, dynamic>)
          .map(
            (o) => MerchantOffer(
              id: o['id'] as String,
              merchant: o['merchant'] as String,
              category: o['category'] as String,
              cashbackPercent: o['cashbackPercent'] as int,
              discountPercent: o['discountPercent'] as int,
              until: o['until'] as String,
            ),
          )
          .toList(),
      purchasePattern: PurchasePatternSummary(
        topCategory: (json['purchasePattern'] as Map<String, dynamic>)['topCategory'] as String,
        monthlySpend: ((json['purchasePattern'] as Map<String, dynamic>)['monthlySpend'] as num)
            .toDouble(),
        repeatingSubscriptions: (json['purchasePattern'] as Map<String, dynamic>)['repeatingSubscriptions']
            as int,
      ),
    );
  }
}
