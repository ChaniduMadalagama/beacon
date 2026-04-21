import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/dashboard_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../widgets/beacon_list_item.dart';
import '../widgets/dashboard_widgets.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFDFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: Padding(
          padding: const EdgeInsets.all(10.0),
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              String? photoUrl;
              if (state is Authenticated) photoUrl = state.user.photoUrl;
              return CircleAvatar(
                backgroundColor: AppColors.divider,
                backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                child: photoUrl == null ? const Icon(Icons.person, size: 16, color: AppColors.grey) : null,
              );
            },
          ),
        ),
        title: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            String title = 'Proximity Aware';
            if (state is Authenticated && state.user.displayName != null && state.user.displayName!.isNotEmpty) {
              title = 'Hi, ${state.user.displayName!.split(' ')[0]}';
            }
            return Text(
              title,
              style: const TextStyle(
                color: Color(0xFF1E3A8A),
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            );
          },
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings_input_antenna_rounded, color: AppColors.primaryBlue, size: 22),
          ),
          IconButton(
            onPressed: () => context.read<AuthBloc>().add(const SignOutRequested()),
            icon: const Icon(Icons.logout_rounded, color: AppColors.grey, size: 22),
          ),
        ],
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 32),
                
                // Scanning Logo
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F0FE),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.track_changes_outlined,
                      color: AppColors.primaryBlue,
                      size: 50,
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                const StatusBanner(status: 'ACTIVE'),
                const SizedBox(height: 8),
                const Text(
                  'Precision Scanning',
                  style: AppTextStyles.heading1,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Actively monitoring Bluetooth Low Energy signals in your immediate perimeter.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.subtitle,
                ),
                
                const SizedBox(height: 32),
                
                // Stats Row
                Row(
                  children: [
                    Expanded(
                      child: StatItem(
                        label: 'ACTIVE NODES',
                        value: state is DashboardLoaded ? state.beacons.length.toString() : '0',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatItem(
                        label: 'STRONGEST RSSI',
                        value: state is DashboardLoaded && state.beacons.isNotEmpty
                            ? state.beacons.first.rssi.toInt().toString()
                            : '-42',
                        unit: 'dBm',
                        isActive: true, // Make it Blue
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 40),
                
                // List Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Detected Beacons',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF1A1A1A)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Nearby localized identifiers',
                          style: AppTextStyles.subtitle.copyWith(fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    TextButton.icon(
                      onPressed: () => context.read<DashboardBloc>().add(StartScanRequested()),
                      icon: const Text(
                        'REFRESH', 
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5)
                      ),
                      label: const Icon(Icons.refresh_rounded, size: 16),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primaryBlue,
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                _buildBeaconsList(state),
                const SizedBox(height: 120),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF003D9E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: AppColors.white),
      ),
    );
  }

  Widget _buildBeaconsList(DashboardState state) {
    if (state is DashboardLoading) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(40.0),
        child: CircularProgressIndicator(),
      ));
    }
    
    if (state is DashboardLoaded) {
      if (state.beacons.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(40.0),
            child: Text('No beacons found.', style: AppTextStyles.subtitle),
          ),
        );
      }
      return Column(
        children: state.beacons.map((beacon) {
          final isCritical = beacon.distance < 5.0;
          return BeaconListItem(
            name: _mockNameForBeacon(beacon.uuid),
            uuid: beacon.uuid,
            major: beacon.major,
            minor: beacon.minor,
            distance: beacon.distance,
            rssi: beacon.rssi,
            isCritical: isCritical,
            categoryIcon: _iconForBeacon(beacon.uuid),
          );
        }).toList(),
      );
    }

    if (state is DashboardError) {
      return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
    }

    return Container();
  }

  String _mockNameForBeacon(String uuid) {
    if (uuid.contains('E2C5')) return 'Conference Room B';
    if (uuid.contains('B12F')) return 'Asset Tag: #A882';
    if (uuid.contains('2A12')) return 'Server Hall 4 Gateway';
    return 'Unknown Beacon';
  }

  IconData _iconForBeacon(String uuid) {
    if (uuid.contains('E2C5')) return Icons.location_on_rounded;
    if (uuid.contains('B12F')) return Icons.bluetooth_audio_rounded;
    if (uuid.contains('2A12')) return Icons.print_rounded;
    return Icons.devices_other_rounded;
  }
}
