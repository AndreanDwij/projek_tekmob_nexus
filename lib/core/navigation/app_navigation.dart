import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

class AppNav {
  static void toLogin(BuildContext context) => context.go('/login');
  static void toRegister(BuildContext context) => context.go('/register');
  static void toHome(BuildContext context) => context.go('/home');
  static void logout(BuildContext context) => context.go('/login');

  static void toMap(BuildContext context) => context.go('/map');
  static void toCommunity(BuildContext context) => context.go('/community');
  static void toProfile(BuildContext context) => context.go('/profile');

  static void toReportList(BuildContext context) => context.push('/report');
  static void toReportCreate(BuildContext context) => context.push('/report/create');
  static void toReportDetail(BuildContext context, String id) =>
      context.push('/report/detail/$id');

  static void toEventDetail(BuildContext context, String id) =>
      context.push('/community/detail/$id');

  static void toRewardList(BuildContext context) => context.push('/reward');
  static void toRewardDetail(BuildContext context, String id) =>
      context.push('/reward/detail/$id');

  static void toCarbon(BuildContext context) => context.push('/carbon');
  static void toLeaderboard(BuildContext context) => context.push('/leaderboard');
  static void toNotifications(BuildContext context) => context.push('/notifications');
  static void toNotificationDetail(BuildContext context, String id) =>
      context.push('/notifications/detail/$id');
  static void toEditProfile(BuildContext context) => context.push('/profile/edit');
  static void toSettings(BuildContext context) => context.push('/settings');
  static void toHelp(BuildContext context) => context.push('/help');

  static void back(BuildContext context) => context.pop();
}
