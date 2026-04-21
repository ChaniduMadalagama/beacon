import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/dashboard_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

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
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 32),

            // Designer Avatar Section
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer concentric ring
                  Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                    ),
                  ),
                  // Inner decorative ring
                  Container(
                    width: 115,
                    height: 115,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF2DD4BF).withValues(alpha: 0.3), width: 3),
                    ),
                  ),
                  // Hero Avatar
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      String? photoUrl;
                      if (state is Authenticated) photoUrl = state.user.photoUrl;
                      return Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: const Color(0xFFF3F4F6),
                          backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                          child: photoUrl == null ? const Icon(Icons.person, size: 40, color: AppColors.grey) : null,
                        ),
                      );
                    },
                  ),
                  // Verified Badge
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E3A8A),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2)),
                        ],
                      ),
                      child: const Icon(Icons.verified_user_rounded, color: Colors.white, size: 14),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // User Info
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                String name = 'Anonymous User';
                String email = 'Not authenticated';
                if (state is Authenticated) {
                  name = state.user.displayName ?? 'No Name';
                  email = state.user.email ?? 'No Email';
                }
                return Column(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF1A1A1A)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF6B7280)),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 32),

            // Metrics Grid
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    label: 'ACTIVE NODES',
                    value: BlocBuilder<DashboardBloc, DashboardState>(
                      builder: (context, state) {
                        String count = '0';
                        if (state is DashboardLoaded) count = state.beacons.length.toString();
                        return Text(
                          count,
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF1E3A8A)),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _MetricCard(
                    label: 'SIGNAL HEALTH',
                    value: BlocBuilder<DashboardBloc, DashboardState>(
                      builder: (context, state) {
                        double health = 0;
                        Color healthColor = AppColors.errorRed;

                        if (state is DashboardLoaded && state.beacons.isNotEmpty) {
                          // Calculate average RSSI
                          final double avgRssi = state.beacons.map((b) => b.rssi).reduce((a, b) => a + b) / state.beacons.length;
                          
                          // Convert RSSI to percentage (Range: -110 to -50)
                          health = (((avgRssi + 110) / (110 - 50)) * 100).clamp(0, 100);
                          
                          // Determine color
                          if (health > 70) {
                            healthColor = const Color(0xFF10B981); // Green
                          } else if (health > 40) {
                            healthColor = const Color(0xFFFBBF24); // Yellow/Amber
                          } else {
                            healthColor = const Color(0xFFEF4444); // Red
                          }
                        }

                        return Text(
                          '${health.toInt()}%',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: healthColor,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // Configuration Section
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'CONFIGURATION',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Column(
                children: [
                  _ConfigTile(
                    icon: Icons.notifications_none_rounded,
                    title: 'Notification Preferences',
                    subtitle: 'Manage proximity alerts and system logs',
                  ),
                  _ConfigTile(
                    icon: Icons.settings_input_antenna_rounded,
                    title: 'iBeacon Protocol Specs',
                    subtitle: 'UUID, Major, and Minor broadcast settings',
                  ),
                  _ConfigTile(
                    icon: Icons.bar_chart_rounded,
                    title: 'Distance Algorithm Explanation',
                    subtitle: 'RSSI path loss model and trilateration',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Scan Active Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFFFB800),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: const Color(0xFFFFB800).withValues(alpha: 0.2), blurRadius: 15, offset: const Offset(0, 8)),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: const Icon(Icons.track_changes_outlined, color: Color(0xFFFFB800), size: 24),
                  ),
                  const SizedBox(width: 16),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BACKGROUND SCAN ACTIVE',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Color(0xFF1E3A8A)),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Precision Tracking: 0.2m variance',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1E3A8A)),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Sign Out Button
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton.icon(
                onPressed: () => context.read<AuthBloc>().add(const SignOutRequested()),
                icon: const Icon(Icons.logout_rounded, size: 20),
                label: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFEE2E2),
                  foregroundColor: const Color(0xFFDC2626),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              'VERSION 4.2.0-STABLE',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFFCBD5E1), letterSpacing: 1),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final dynamic value;

  const _MetricCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8)),
          ),
          const SizedBox(height: 8),
          value is Widget ? value : Text(
            value.toString(),
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF1E3A8A)),
          ),
        ],
      ),
    );
  }
}

class _ConfigTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ConfigTile({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: const Color(0xFF1E3A8A), size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 15,
          color: Color(0xFF1A1A1A),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF64748B),
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1)),
      onTap: () {},
    );
  }
}
