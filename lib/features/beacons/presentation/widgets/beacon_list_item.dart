import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class BeaconListItem extends StatelessWidget {
  final String name;
  final String uuid;
  final int major;
  final int minor;
  final double distance;
  final double rssi;
  final bool isCritical;
  final IconData categoryIcon;

  const BeaconListItem({
    super.key,
    required this.name,
    required this.uuid,
    required this.major,
    required this.minor,
    required this.distance,
    required this.rssi,
    this.isCritical = false,
    this.categoryIcon = Icons.location_on,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Proximity Indicator Bar
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: isCritical ? AppColors.warningAmber : Colors.transparent,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name, style: AppTextStyles.beaconTitle.copyWith(fontSize: 18, fontWeight: FontWeight.w900)),
                              const SizedBox(height: 6),
                              Text(
                                'UUID: ${uuid.substring(0, 18).toUpperCase()}...',
                                style: AppTextStyles.footerText.copyWith(
                                  fontSize: 9, 
                                  color: AppColors.grey,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isCritical)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'CRITICAL\nPROXIMITY',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF92400E),
                                height: 1.1,
                              ),
                            ),
                          ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('DISTANCE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFFB48A00))),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  distance.toStringAsFixed(1),
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    color: isCritical ? const Color(0xFFFBBF24) : AppColors.black,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                const Text('m', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFFBBF24))),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        _IdField(label: 'MAJOR ID', value: major.toString()),
                        const SizedBox(width: 32),
                        _IdField(label: 'MINOR ID', value: minor.toString()),
                        const Spacer(),
                        Icon(categoryIcon, color: const Color(0xFFCFD5DE), size: 28),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IdField extends StatelessWidget {
  final String label;
  final String value;

  const _IdField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: AppColors.grey, letterSpacing: 0.5)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.black)),
      ],
    );
  }
}
