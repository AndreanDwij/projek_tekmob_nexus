import 'package:flutter/material.dart';

class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'EcoLife';
  static const String appVersion = '1.0.0';

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String reportsCollection = 'reports';
  static const String eventsCollection = 'events';
  static const String rewardsCollection = 'rewards';
  static const String redemptionsCollection = 'redemptions';
  static const String notificationsCollection = 'notifications';
  static const String communityPostsCollection = 'community_posts';
  static const String carbonFootprintsCollection = 'carbon_footprints';

  // Storage Paths
  static const String reportImagesPath = 'report_images';
  static const String profileImagesPath = 'profile_images';
  static const String communityImagesPath = 'community_images';

  // Eco Point Constants
  static const int reportPoint = 10;
  static const int reportVerifiedPoint = 25;
  static const int eventJoinPoint = 15;
  static const int carbonCalculationPoint = 5;

  // Validation
  static const int minPasswordLength = 8;
  static const int maxReportImageCount = 3;
  static const double maxReportImageSize = 5.0;

  // Location
  static const double defaultLatitude = -6.2088;
  static const double defaultLongitude = 106.8456;
  static const String defaultLocationName = 'Jakarta';

  // Pagination
  static const int pageSize = 10;
}

class AppColors {
  AppColors._();

  // Primary
  static const Color primary = Color(0xFF16A34A);
  static const Color primaryLight = Color(0xFF22C55E);
  static const Color primaryDark = Color(0xFF15803D);

  // Secondary
  static const Color secondary = Color(0xFF3B82F6);
  static const Color earthBrown = Color(0xFFA16207);
  static const Color leafGreen = Color(0xFF84CC16);

  // Neutral
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFF1F5F9);

  // Text
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9CA3AF);
  static const Color textDisable = Color(0xFFD1D5DB);
  static const Color textWhite = Color(0xFFFFFFFF);

  // Status
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFFACC15);
  static const Color danger = Color(0xFFEF4444);
  static const Color info = Color(0xFF0EA5E9);
}

class AppSpacing {
  AppSpacing._();

  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;
  static const double xxxxl = 48;
  static const double xxxxxl = 64;
}

class AppRadius {
  AppRadius._();

  static const double small = 8;
  static const double medium = 12;
  static const double large = 16;
  static const double extraLarge = 24;
  static const double circle = 999;
}

class AppElevation {
  AppElevation._();

  static const double level1 = 2;
  static const double level2 = 4;
  static const double level3 = 8;
  static const double level4 = 12;
}

class AppSizes {
  AppSizes._();

  static const double buttonHeight = 52;
  static const double textFieldHeight = 52;
  static const double bottomNavHeight = 72;
  static const double appBarHeight = 56;
  static const double fabDiameter = 60;
  static const double avatarDefault = 48;
  static const double avatarMedium = 64;
  static const double avatarLarge = 96;
  static const double iconSmall = 20;
  static const double iconMedium = 24;
  static const double iconLarge = 28;
  static const double iconXLarge = 32;
  static const double iconXXLarge = 40;
}
