import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryBlue = Color(0xFF0052CC);
  static const Color black = Color(0xFF1A1A1A);
  static const Color grey = Color(0xFF9BA3AF);
  static const Color lightGrey = Color(0xFFF3F4F6);
  static const Color white = Color(0xFFFFFFFF);

  // Specific UI Colors
  static const Color subtitle = Color(0xFF6B7280);
  static const Color inputBackground = Color(0xFFF9FAFB);
  static const Color badgeBackground = Color(0xFFF3F4F6);
  static const Color divider = Color(0xFFE5E7EB);
  
  // New Dashboard Colors
  static const Color activeGreen = Color(0xFF10B981);
  static const Color successGreen = Color(0xFF059669);
  static const Color warningAmber = Color(0xFFFBBF24);
  static const Color errorRed = Color(0xFFDC2626);
  static const Color lightBlue = Color(0xFFDBEAFE);
  static const Color darkBlue = Color(0xFF1E3A8A);
  static const Color activeCardBlue = Color(0xFF0052CC);
  
  // Surface Colors for Alerts
  static const Color surfaceBlue = Color(0xFFF0F7FF);
  static const Color surfaceAmber = Color(0xFFFFFBEB);
  static const Color surfaceGreen = Color(0xFFECFDF5);
  static const Color surfaceRed = Color(0xFFFEF2F2);
  static const Color surfaceGrey = Color(0xFFF9FAFB);

  // Gradients
  static const LinearGradient logoGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0052CC), Color(0xFF002D62)],
  );
}
