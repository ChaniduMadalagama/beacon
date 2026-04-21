import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../app/di.dart';
import '../bloc/alert_bloc.dart';
import '../../domain/entities/beacon_alert.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class AlertsPage extends StatelessWidget {
  const AlertsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<AlertBloc>()..add(FetchAlertsRequested()),
      child: Builder(
        builder: (context) => Scaffold(
          backgroundColor: const Color(0xFFFBFDFF),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: const Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: Icon(Icons.sensors, color: AppColors.primaryBlue),
            ),
            title: const Text(
              'Alerts',
              style: TextStyle(
                color: Color(0xFF1E3A8A),
                fontWeight: FontWeight.w900,
                fontSize: 22,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.delete_sweep_rounded,
                  color: AppColors.errorRed,
                  size: 22,
                ),
                onPressed: () {
                  context.read<AlertBloc>().add(ClearAlertsRequested());
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.tune_rounded,
                  color: AppColors.black,
                  size: 22,
                ),
                onPressed: () {},
              ),
            ],
          ),
          body: BlocBuilder<AlertBloc, AlertState>(
            builder: (context, state) {
              if (state is AlertLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is AlertLoaded) {
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      _SummarySection(
                        activeScans: state.activeScansCount,
                        nearbyBeacons: state.nearbyBeaconsCount,
                      ),
                      if (state.alerts.isEmpty)
                        _buildEmptyState()
                      else
                        ListView.builder(
                          padding: const EdgeInsets.all(24),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: state.alerts.length,
                          itemBuilder: (context, index) {
                            return _AlertCard(alert: state.alerts[index]);
                          },
                        ),
                    ],
                  ),
                );
              } else if (state is AlertLoading) {
                return const _ShimmerLoading();
              } else if (state is AlertError) {
                return Center(child: Text('Error: ${state.message}'));
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        const SizedBox(height: 100),
        Container(
          padding: const EdgeInsets.all(32),
          decoration: const BoxDecoration(
            color: Color(0xFFE8F0FE),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.notifications_none_rounded,
            color: AppColors.primaryBlue,
            size: 64,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'No alerts recorded yet',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 12),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 48),
          child: Text(
            'Nearby beacon events and hardware status updates will appear here in real-time.',
            textAlign: TextAlign.center,
            style: AppTextStyles.subtitle,
          ),
        ),
      ],
    );
  }
}

class _SummarySection extends StatelessWidget {
  final int activeScans;
  final int nearbyBeacons;

  const _SummarySection({
    required this.activeScans,
    required this.nearbyBeacons,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Row(
        children: [
          Expanded(
            child: _SummaryCard(
              label: 'ACTIVE SCANS',
              value: activeScans.toString(),
              accentColor: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _SummaryCard(
              label: 'NEARBY BEACONS',
              value: nearbyBeacons.toString().padLeft(2, '0'),
              accentColor: AppColors.warningAmber,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color accentColor;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: accentColor, width: 5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              color: AppColors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final BeaconAlert alert;
  const _AlertCard({required this.alert});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> theme = _getThemeForStyle(alert.style);
    final Color accentColor = theme['color'];
    final Color surfaceColor = theme['surface'];
    final IconData icon = theme['icon'];

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: accentColor, width: 5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: accentColor, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          alert.type.toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.grey,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          alert.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  alert.body,
                  style: AppTextStyles.subtitle.copyWith(
                    fontSize: 13,
                    height: 1.5,
                    color: const Color(0xFF4B5563),
                  ),
                ),
                const SizedBox(height: 20),

                // Metrics Bar
                _buildMetricsSection(alert, accentColor),

                const SizedBox(height: 16),

                // ID Box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${_getIdLabel(alert)} : ${alert.uuid.toUpperCase()}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Action Button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  alert.actionLabel,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsSection(BeaconAlert alert, Color accentColor) {
    if (alert.type.contains('HARDWARE')) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'STATUS',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: AppColors.grey,
                  ),
                ),
                Text(
                  'OFF',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: accentColor,
                  ),
                ),
              ],
            ),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Hardware ID: BT_01',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ],
        ),
      );
    }

    if (alert.type.contains('PERMISSION')) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PERMISSION',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: AppColors.grey,
                  ),
                ),
                Text(
                  'DENIED',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFB48A00),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Requirement: Always',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // Default Distance/Threshold bar
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                alert.style.contains('hardware')
                    ? 'LAST SEEN'
                    : 'CURRENT DISTANCE',
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  color: AppColors.grey,
                ),
              ),
              Text(
                alert.currentDistance >= 0
                    ? '${alert.currentDistance.toStringAsFixed(1)}m'
                    : '-',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: accentColor,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Threshold: ${alert.thresholdMeters.toStringAsFixed(1)}m',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getIdLabel(BeaconAlert alert) {
    if (alert.type.contains('PERMISSION')) return 'PERM_ID';
    if (alert.type.contains('HARDWARE')) return 'SYSTEM_PAYLOAD';
    return 'UUID';
  }

  Map<String, dynamic> _getThemeForStyle(String style) {
    switch (style) {
      case 'success_green':
        return {
          'color': const Color(0xFF10B981),
          'surface': const Color(0xFFF0FDF4),
          'icon': Icons.check_circle_rounded,
        };
      case 'amber_warning':
        return {
          'color': const Color(0xFFFBBF24),
          'surface': const Color(0xFFFFFBEB),
          'icon': Icons.warning_amber_rounded,
        };
      case 'error_red':
        return {
          'color': const Color(0xFFEF4444),
          'surface': const Color(0xFFFEF2F2),
          'icon': Icons.sensors_off_rounded,
        };
      case 'hardware_grey':
        return {
          'color': const Color(0xFFEF4444),
          'surface': const Color(0xFFF1F5F9),
          'icon': Icons.bluetooth_disabled_rounded,
        };
      case 'info_blue':
      default:
        return {
          'color': const Color(0xFF0052CC),
          'surface': const Color(0xFFE8F0FE),
          'icon': Icons.track_changes_outlined,
        };
    }
  }
}
class _ShimmerLoading extends StatelessWidget {
  const _ShimmerLoading();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          // Shimmer Summary
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Row(
              children: [
                Expanded(child: _shimmerBox(height: 100, radius: 20)),
                const SizedBox(width: 16),
                Expanded(child: _shimmerBox(height: 100, radius: 20)),
              ],
            ),
          ),
          // Shimmer List
          ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            shrinkWrap: true,
            itemCount: 5,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _shimmerBox(height: 120, radius: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _shimmerBox({required double height, required double radius}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
