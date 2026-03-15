import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config/backend_config.dart';
import '../core/segment/segment_models.dart';
import '../data/backend/bank_api_client.dart';
import '../data/mock/mock_content_repository.dart';
import '../domain/models/bank_app_models.dart';

class AuthState {
  const AuthState({this.token, this.user, this.isLoading = false, this.error});

  final String? token;
  final AppUser? user;
  final bool isLoading;
  final String? error;

  bool get isAuthenticated => token != null;

  AuthState copyWith({
    String? token,
    AppUser? user,
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool clearAuth = false,
  }) {
    return AuthState(
      token: clearAuth ? null : token ?? this.token,
      user: clearAuth ? null : user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  AuthController(this.ref) : super(const AuthState());

  final Ref ref;

  Future<bool> login({required String phone, required String password}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final api = ref.read(bankApiProvider);
      final result = await api.login(phone: phone, password: password);
      state = AuthState(
        token: result.token,
        user: result.user,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String phone,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final api = ref.read(bankApiProvider);
      final result = await api.register(
        name: name,
        phone: phone,
        password: password,
      );
      state = AuthState(
        token: result.token,
        user: result.user,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    final token = state.token;
    if (token != null) {
      try {
        await ref.read(bankApiProvider).logout(token);
      } catch (_) {}
    }
    state = state.copyWith(clearAuth: true, clearError: true);
  }

  void setUser(AppUser user) {
    state = state.copyWith(user: user);
  }
}

class BankingActions {
  BankingActions(this.ref);

  final Ref ref;

  String _tokenOrThrow() {
    final token = ref.read(authStateProvider).token;
    if (token == null) throw Exception('Требуется авторизация');
    return token;
  }

  void _refresh() => ref.invalidate(overviewProvider);

  Future<void> markAllNotificationsRead() async {
    await ref.read(bankApiProvider).markAllNotificationsRead(_tokenOrThrow());
    _refresh();
  }

  Future<void> sendSupportMessage({required String text}) async {
    await ref
        .read(bankApiProvider)
        .sendSupportMessage(_tokenOrThrow(), text: text);
    _refresh();
  }

  Future<void> updateSecurity({
    required double dailyTransferLimit,
    required double dailyPaymentLimit,
  }) async {
    await ref
        .read(bankApiProvider)
        .updateSecurity(
          _tokenOrThrow(),
          dailyTransferLimit: dailyTransferLimit,
          dailyPaymentLimit: dailyPaymentLimit,
        );
    _refresh();
  }

  Future<void> createApplication({required String type}) async {
    await ref
        .read(bankApiProvider)
        .createApplication(_tokenOrThrow(), type: type);
    _refresh();
  }

  Future<void> transfer({
    required String to,
    required double amount,
    String comment = '',
    String confirmCode = '',
  }) async {
    await ref
        .read(bankApiProvider)
        .transfer(
          _tokenOrThrow(),
          to: to,
          amount: amount,
          comment: comment,
          confirmCode: confirmCode,
        );
    _refresh();
  }

  Future<void> topUp({
    required double amount,
    String source = 'СБП',
    String confirmCode = '',
  }) async {
    await ref
        .read(bankApiProvider)
        .topUp(
          _tokenOrThrow(),
          amount: amount,
          source: source,
          confirmCode: confirmCode,
        );
    _refresh();
  }

  Future<void> payTemplate(String paymentId, {String confirmCode = ''}) async {
    await ref
        .read(bankApiProvider)
        .payTemplate(
          _tokenOrThrow(),
          paymentId: paymentId,
          confirmCode: confirmCode,
        );
    _refresh();
  }

  Future<void> payCustom({
    required String title,
    required String account,
    required double amount,
    String confirmCode = '',
  }) async {
    await ref
        .read(bankApiProvider)
        .payCustom(
          _tokenOrThrow(),
          title: title,
          account: account,
          amount: amount,
          confirmCode: confirmCode,
        );
    _refresh();
  }

  Future<void> createTemplate({
    required String title,
    required String account,
    required double amount,
  }) async {
    await ref
        .read(bankApiProvider)
        .createTemplate(
          _tokenOrThrow(),
          title: title,
          account: account,
          amount: amount,
        );
    _refresh();
  }

  Future<void> payLoan(
    String loanId,
    double amount, {
    String confirmCode = '',
  }) async {
    await ref
        .read(bankApiProvider)
        .payLoan(
          _tokenOrThrow(),
          loanId: loanId,
          amount: amount,
          confirmCode: confirmCode,
        );
    _refresh();
  }

  Future<void> openDeposit(
    double amount, {
    int termDays = 365,
    String confirmCode = '',
  }) async {
    await ref
        .read(bankApiProvider)
        .openDeposit(
          _tokenOrThrow(),
          amount: amount,
          termDays: termDays,
          confirmCode: confirmCode,
        );
    _refresh();
  }

  Future<void> createGoal({
    required String title,
    required double target,
  }) async {
    await ref
        .read(bankApiProvider)
        .createGoal(_tokenOrThrow(), title: title, target: target);
    _refresh();
  }

  Future<void> topupGoal({
    required String goalId,
    required double amount,
  }) async {
    await ref
        .read(bankApiProvider)
        .topupGoal(_tokenOrThrow(), goalId: goalId, amount: amount);
    _refresh();
  }

  Future<void> toggleSubscription(String id) async {
    await ref.read(bankApiProvider).toggleSubscription(_tokenOrThrow(), id: id);
    _refresh();
  }

  Future<void> toggleCard(String cardId, bool frozen) async {
    await ref
        .read(bankApiProvider)
        .toggleCard(_tokenOrThrow(), cardId: cardId, frozen: frozen);
    _refresh();
  }

  Future<void> reissueCard(String cardId) async {
    await ref
        .read(bankApiProvider)
        .reissueCard(_tokenOrThrow(), cardId: cardId);
    _refresh();
  }

  Future<void> activateCashback(String offerId) async {
    await ref
        .read(bankApiProvider)
        .activateCashback(_tokenOrThrow(), offerId: offerId);
    _refresh();
  }

  Future<void> buyStock({
    required String ticker,
    int lots = 1,
    String confirmCode = '',
  }) async {
    await ref
        .read(bankApiProvider)
        .buyStock(
          _tokenOrThrow(),
          ticker: ticker,
          lots: lots,
          confirmCode: confirmCode,
        );
    _refresh();
  }

  Future<void> sellStock({required String ticker, int lots = 1}) async {
    await ref
        .read(bankApiProvider)
        .sellStock(_tokenOrThrow(), ticker: ticker, lots: lots);
    _refresh();
  }

  Future<AppUser> switchDemoAccount({required String personaId}) async {
    final user = await ref
        .read(bankApiProvider)
        .switchDemoAccount(_tokenOrThrow(), personaId: personaId);
    ref.read(authStateProvider.notifier).setUser(user);
    _refresh();
    return user;
  }
}

final Provider<BankApiClient> bankApiProvider = Provider<BankApiClient>(
  (ref) => BankApiClient(baseUrl: BackendConfig.baseUrl),
);

final StateNotifierProvider<AuthController, AuthState> authStateProvider =
    StateNotifierProvider<AuthController, AuthState>(
      (ref) => AuthController(ref),
    );

final FutureProvider<BankOverview> overviewProvider =
    FutureProvider<BankOverview>((ref) async {
      final token = ref.watch(authStateProvider).token;
      if (token == null) throw Exception('Требуется авторизация');
      return ref.read(bankApiProvider).getOverview(token);
    });

final Provider<BankingActions> bankingActionsProvider =
    Provider<BankingActions>((ref) => BankingActions(ref));

const List<DemoPersona> demoPersonas = <DemoPersona>[
  DemoPersona(
    id: 'child',
    name: 'Миша',
    age: 10,
    segment: UserSegment.child,
    subtitle: 'Ребенок • до 14',
  ),
  DemoPersona(
    id: 'teen',
    name: 'Лена',
    age: 16,
    segment: UserSegment.teen,
    subtitle: 'Подросток • 14-17',
  ),
  DemoPersona(
    id: 'adult',
    name: 'Илья',
    age: 29,
    segment: UserSegment.adult,
    subtitle: 'Взрослый • 18+',
  ),
  DemoPersona(
    id: 'business',
    name: 'Ольга ИП',
    age: 35,
    segment: UserSegment.business,
    subtitle: 'Бизнес-пользователь',
  ),
];

class ActiveAccountController extends StateNotifier<DemoPersona> {
  ActiveAccountController(this.ref) : super(demoPersonas[2]);

  final Ref ref;

  Future<void> switchAccount(DemoPersona persona) async {
    state = persona;
    final token = ref.read(authStateProvider).token;
    if (token == null) return;
    await ref
        .read(bankingActionsProvider)
        .switchDemoAccount(personaId: persona.id);
  }
}

final StateNotifierProvider<ActiveAccountController, DemoPersona>
currentPersonaProvider = StateNotifierProvider<ActiveAccountController, DemoPersona>(
  (ref) => ActiveAccountController(ref),
);

final Provider<UserSegment> currentSegmentProvider = Provider<UserSegment>(
  (ref) => ref.watch(currentPersonaProvider).segment,
);

final StateProvider<bool> presentationModeProvider = StateProvider<bool>(
  (ref) => true,
);

final Provider<MockContentRepository> mockContentRepositoryProvider =
    Provider<MockContentRepository>((ref) => const MockContentRepository());
