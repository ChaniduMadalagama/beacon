import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class StatItem extends StatelessWidget {
  final String label;
  final String value;
  final String? unit;
  final bool isActive;

  const StatItem({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: isActive ? AppColors.activeCardBlue : AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.statLabel.copyWith(
              color: isActive ? AppColors.white.withValues(alpha: 0.8) : AppColors.grey,
              fontSize: 9,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: AppTextStyles.statNumber.copyWith(
                  color: isActive ? AppColors.white : AppColors.darkBlue,
                  fontSize: 32,
                ),
              ),
              if (unit != null)
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    unit!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isActive ? AppColors.white.withValues(alpha: 0.8) : AppColors.subtitle,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class StatusBanner extends StatelessWidget {
  final String status;
  final Color statusColor;

  const StatusBanner({
    super.key,
    required this.status,
    this.statusColor = AppColors.primaryBlue,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'STATUS: $status'.toUpperCase(),
          style: AppTextStyles.dashboardStatus.copyWith(
            color: statusColor,
            fontSize: 10,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}
