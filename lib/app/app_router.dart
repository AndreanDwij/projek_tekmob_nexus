import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/widgets/app_bottom_nav.dart';
import '../features/splash/splash_page.dart';
import '../features/auth/login_page.dart';
import '../features/auth/register_page.dart';
import '../features/dashboard/dashboard_page.dart';
import '../features/map/map_page.dart';
import '../features/community/community_page.dart';
import '../features/community/event_detail_page.dart';
import '../features/report/report_list_page.dart';
import '../features/report/report_create_page.dart';
import '../features/report/report_detail_page.dart';
import '../features/reward/reward_page.dart';
import '../features/reward/reward_detail_page.dart';
import '../features/carbon/carbon_footprint_page.dart';
import '../features/leaderboard/leaderboard_page.dart';
import '../features/notification/notification_page.dart';
import '../features/notification/notification_detail_page.dart';
import '../features/profile/profile_page.dart';
import '../features/profile/edit_profile_page.dart';
import '../features/profile/settings_page.dart';
import '../features/profile/help_page.dart';
import '../features/profile/privacy_policy_page.dart';
import '../features/profile/terms_page.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return Scaffold(
          body: child,
          bottomNavigationBar: AppBottomNav(
            currentLocation: state.matchedLocation,
          ),
        );
      },
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => const DashboardPage(),
        ),
        GoRoute(
          path: '/map',
          builder: (context, state) => const MapPage(),
        ),
        GoRoute(
          path: '/community',
          builder: (context, state) => const CommunityPage(),
          routes: [
            GoRoute(
              path: 'detail/:id',
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                return EventDetailPage(eventId: id);
              },
            ),
          ],
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfilePage(),
        ),
      ],
    ),
    GoRoute(
      path: '/report',
      builder: (context, state) => const ReportListPage(),
      routes: [
        GoRoute(
          path: 'create',
          builder: (context, state) => const ReportCreatePage(),
        ),
        GoRoute(
          path: 'detail/:id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return ReportDetailPage(reportId: id);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/reward',
      builder: (context, state) => const RewardPage(),
      routes: [
        GoRoute(
          path: 'detail/:id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return RewardDetailPage(rewardId: id);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/carbon',
      builder: (context, state) => const CarbonFootprintPage(),
    ),
    GoRoute(
      path: '/leaderboard',
      builder: (context, state) => const LeaderboardPage(),
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationPage(),
      routes: [
        GoRoute(
          path: 'detail/:id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return NotificationDetailPage(notificationId: id);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/profile/edit',
      builder: (context, state) => const EditProfilePage(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
    ),
    GoRoute(
      path: '/help',
      builder: (context, state) => const HelpPage(),
    ),
    GoRoute(
      path: '/privacy-policy',
      builder: (context, state) => const PrivacyPolicyPage(),
    ),
    GoRoute(
      path: '/terms',
      builder: (context, state) => const TermsPage(),
    ),
  ],
);