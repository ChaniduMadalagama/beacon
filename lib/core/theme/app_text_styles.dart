import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w900,
    color: AppColors.black,
    letterSpacing: -0.8,
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.subtitle,
    height: 1.5,
  );

  static const TextStyle buttonTextWhite = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );

  // New Dashboard Styles
  static const TextStyle dashboardStatus = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w800,
    color: AppColors.primaryBlue,
    letterSpacing: 2.0,
  );

  static const TextStyle statNumber = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w900,
    color: AppColors.darkBlue,
  );

  static const TextStyle statLabel = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w900,
    color: AppColors.subtitle,
    letterSpacing: 1.0,
  );

  static const TextStyle beaconTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.black,
  );

  static const TextStyle beaconIdLabel = TextStyle(
    fontSize: 9,
    fontWeight: FontWeight.w800,
    color: AppColors.grey,
    letterSpacing: 0.5,
  );

  static const TextStyle beaconIdValue = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.black,
  );

  static const TextStyle buttonTextBlack = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.black,
  );

  static const TextStyle dividerText = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: AppColors.grey,
    letterSpacing: 1.2,
  );

  static const TextStyle badgeText = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.subtitle,
    letterSpacing: 0.5,
  );

  static const TextStyle footerText = TextStyle(
    fontSize: 12,
    color: AppColors.grey,
  );

  static const TextStyle footerLink = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryBlue,
  );
}
