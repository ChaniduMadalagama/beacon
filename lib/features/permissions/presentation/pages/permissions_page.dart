import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/permissions_bloc.dart';
import '../bloc/permissions_event.dart';
import '../bloc/permissions_state.dart';

class PermissionsPage extends StatelessWidget {
  const PermissionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFDFF),
      appBar: AppBar(
        automaticallyImplyLeading: false, // Removed back button
        title: const Text(
          'Setup',
          style: TextStyle(
            color: Color(0xFF1E3A8A),
            fontWeight: FontWeight.w900,
            fontSize: 22,
          ),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),

                // Designer Illustration Container
                Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(48),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 40,
                        offset: const Offset(0, 20),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.track_changes_outlined,
                      size: 80,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                ),

                const SizedBox(height: 48),

                // Core Messaging
                const Text(
                  'Precision is key',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1A1A1A),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'To accurately detect proximity and keep your environment secure, we need a few keys to the kingdom.',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 48),

                // Permission Stack
                const Column(
                  children: [
                    _PermissionToggleItem(
                      type: _PermissionType.location,
                      title: 'Enable Location Services (Always)',
                      subtitle: 'Required for background awareness',
                    ),
                    SizedBox(height: 16),
                    _PermissionToggleItem(
                      type: _PermissionType.bluetooth,
                      title: 'Enable Bluetooth Scan',
                      subtitle: 'Detects nearby trusted devices',
                    ),
                    SizedBox(height: 16),
                    _PermissionToggleItem(
                      type: _PermissionType.notification,
                      title: 'Enable Notifications',
                      subtitle: 'Get alerts for nearby detections',
                    ),
                  ],
                ),

                const SizedBox(height: 48),

                // Primary Action Button
                BlocBuilder<PermissionsBloc, PermissionsState>(
                  builder: (context, state) {
                    final isAllGranted = state.isAllGranted;

                    return Column(
                      children: [
                        Container(
                          width: double.infinity,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: isAllGranted
                                ? const LinearGradient(
                                    colors: [
                                      Color(0xFF10B981),
                                      Color(0xFF059669),
                                    ],
                                  )
                                : AppColors.logoGradient,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    (isAllGranted
                                            ? const Color(0xFF10B981)
                                            : const Color(0xFF0052CC))
                                        .withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: isAllGranted
                                  ? () => context.read<PermissionsBloc>().add(
                                      const SetupCompleteRequested(),
                                    )
                                  : null,
                              borderRadius: BorderRadius.circular(16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    isAllGranted
                                        ? 'Go to Home'
                                        : 'Grant Permissions',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Icon(
                                    isAllGranted
                                        ? Icons.check_circle_outline
                                        : Icons.arrow_forward_rounded,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (isAllGranted) ...[
                          const SizedBox(height: 16),
                          const Text(
                            'All systems ready! Tap above to enter.',
                            style: TextStyle(
                              color: Color(0xFF10B981),
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),

                const SizedBox(height: 32),

                // Footer Assurance
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lock_rounded,
                      size: 14,
                      color: Color(0xFF94A3B8),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'DATA IS ENCRYPTED AND STORED LOCALLY',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF94A3B8),
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum _PermissionType { location, bluetooth, notification }

class _PermissionToggleItem extends StatelessWidget {
  final _PermissionType type;
  final String title;
  final String subtitle;

  const _PermissionToggleItem({
    required this.type,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PermissionsBloc, PermissionsState>(
      builder: (context, state) {
        final isGranted = switch (type) {
          _PermissionType.location =>
            state.locationStatus == CustomPermissionStatus.granted,
          _PermissionType.bluetooth =>
            state.bluetoothStatus == CustomPermissionStatus.granted,
          _PermissionType.notification =>
            state.notificationStatus == CustomPermissionStatus.granted,
        };

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: isGranted,
                activeTrackColor: const Color(
                  0xFF0052CC,
                ).withValues(alpha: 0.3),
                activeThumbColor: const Color(0xFF0052CC),
                onChanged: (value) {
                  if (value) {
                    final bloc = context.read<PermissionsBloc>();
                    switch (type) {
                      case _PermissionType.location:
                        bloc.add(const LocationPermissionRequested());
                      case _PermissionType.bluetooth:
                        bloc.add(const BluetoothPermissionRequested());
                      case _PermissionType.notification:
                        bloc.add(const NotificationPermissionRequested());
                    }
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
