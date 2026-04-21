import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/di.dart';
import '../../../../features/beacons/presentation/pages/main_scaffold.dart';
import '../../../../features/permissions/presentation/bloc/permissions_bloc.dart';
import '../../../../features/permissions/presentation/bloc/permissions_event.dart';
import '../../../../features/permissions/presentation/bloc/permissions_state.dart';
import '../../../../features/permissions/presentation/pages/permissions_page.dart';
import '../../../../core/services/proximity_service.dart';
import '../bloc/auth_bloc.dart';
import 'login_page.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _hasStartedMonitoring = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          return BlocProvider(
            create: (context) =>
                sl<PermissionsBloc>()..add(const CheckPermissionsRequested()),
            child: BlocBuilder<PermissionsBloc, PermissionsState>(
              builder: (context, permState) {
                if (permState.isAllGranted && permState.isSetupComplete) {
                  // Only start monitoring ONCE per authenticated session
                  if (!_hasStartedMonitoring) {
                    _hasStartedMonitoring = true;
                    // Use addPostFrameCallback to avoid calling during build phase
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      sl<ProximityService>().startMonitoring();
                    });
                  }
                  return const MainScaffold();
                } else {
                  // If monitoring was started but session is reset, 
                  // allow it to be restarted later
                  _hasStartedMonitoring = false;
                  return const PermissionsPage();
                }
              },
            ),
          );
        } else if (state is AuthLoading) {
          _hasStartedMonitoring = false;
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else {
          _hasStartedMonitoring = false;
          return const LoginPage();
        }
      },
    );
  }
}
