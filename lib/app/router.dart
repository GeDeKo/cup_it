import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/accounts/presentation/accounts_screen.dart';
import '../features/analytics/presentation/analytics_screen.dart';
import '../features/applications/presentation/applications_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import '../features/business/presentation/business_analytics_screen.dart';
import '../features/business/presentation/business_dashboard_screen.dart';
import '../features/business/presentation/business_documents_screen.dart';
import '../features/business/presentation/business_payments_screen.dart';
import '../features/cards/presentation/cards_screen.dart';
import '../features/cards/presentation/card_details_screen.dart';
import '../features/dashboard/presentation/home_dashboard_screen.dart';
import '../features/demo_mode/presentation/jury_screen.dart';
import '../features/history/presentation/history_screen.dart';
import '../features/investments/presentation/investments_screen.dart';
import '../features/loans/presentation/loans_screen.dart';
import '../features/notifications/presentation/notifications_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/onboarding/presentation/splash_screen.dart';
import '../features/eligibility/presentation/branch_appointment_screen.dart';
import '../features/eligibility/presentation/restriction_explainer_screen.dart';
import '../features/offers/presentation/ai_offers_screen.dart';
import '../features/offers/presentation/lifestyle_offers_screen.dart';
import '../features/payments/presentation/payments_screen.dart';
import '../features/products/presentation/products_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/profile/presentation/feature_availability_screen.dart';
import '../features/savings/presentation/savings_screen.dart';
import '../features/security/presentation/security_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/support/presentation/support_screen.dart';
import '../features/family/presentation/parent_control_screen.dart';
import '../features/transfers/presentation/transfers_screen.dart';
import '../features/teen/presentation/teen_growth_path_screen.dart';
import 'shell_scaffold.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
    GoRoute(path: '/jury', builder: (_, __) => const JuryScreen()),
    ShellRoute(
      builder: (BuildContext context, GoRouterState state, Widget child) {
        return ShellScaffold(location: state.uri.path, child: child);
      },
      routes: [
        GoRoute(path: '/home', builder: (_, __) => const HomeDashboardScreen()),
        GoRoute(path: '/payments', builder: (_, __) => const PaymentsScreen()),
        GoRoute(path: '/catalog', builder: (_, __) => const ProductsScreen()),
        GoRoute(path: '/history', builder: (_, __) => const HistoryScreen()),
        GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
        GoRoute(
          path: '/profile/availability',
          builder: (_, __) => const FeatureAvailabilityScreen(),
        ),
        GoRoute(path: '/accounts', builder: (_, __) => const AccountsScreen()),
        GoRoute(path: '/cards', builder: (_, __) => const CardsScreen()),
        GoRoute(
          path: '/cards/:cardId',
          builder: (_, state) =>
              CardDetailsScreen(cardId: state.pathParameters['cardId'] ?? ''),
        ),
        GoRoute(
          path: '/transfers',
          builder: (_, __) => const TransfersScreen(),
        ),
        GoRoute(
          path: '/analytics',
          builder: (_, __) => const AnalyticsScreen(),
        ),
        GoRoute(path: '/savings', builder: (_, __) => const SavingsScreen()),
        GoRoute(path: '/loans', builder: (_, __) => const LoansScreen()),
        GoRoute(path: '/offers', builder: (_, __) => const AiOffersScreen()),
        GoRoute(
          path: '/lifestyle-offers',
          builder: (_, __) => const LifestyleOffersScreen(),
        ),
        GoRoute(
          path: '/teen-growth',
          builder: (_, __) => const TeenGrowthPathSection(),
        ),
        GoRoute(
          path: '/investments',
          builder: (_, __) => const InvestmentsScreen(),
        ),
        GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
        GoRoute(
          path: '/notifications',
          builder: (_, __) => const NotificationsScreen(),
        ),
        GoRoute(path: '/support', builder: (_, __) => const SupportScreen()),
        GoRoute(path: '/security', builder: (_, __) => const SecurityScreen()),
        GoRoute(
          path: '/parent-control',
          builder: (_, __) => const ParentControlScreen(),
        ),
        GoRoute(
          path: '/branch-appointment',
          builder: (_, __) => const BranchAppointmentScreen(),
        ),
        GoRoute(
          path: '/restriction-explainer',
          builder: (_, __) => const RestrictionExplainerScreen(),
        ),
        GoRoute(
          path: '/applications',
          builder: (_, __) => const ApplicationsScreen(),
        ),
        GoRoute(
          path: '/business/dashboard',
          builder: (_, __) => const BusinessDashboardScreen(),
        ),
        GoRoute(
          path: '/business/payments',
          builder: (_, __) => const BusinessPaymentsScreen(),
        ),
        GoRoute(
          path: '/business/analytics',
          builder: (_, __) => const BusinessAnalyticsScreen(),
        ),
        GoRoute(
          path: '/business/documents',
          builder: (_, __) => const BusinessDocumentsScreen(),
        ),
      ],
    ),
  ],
);
