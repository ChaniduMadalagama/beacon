import 'package:beacon/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'firebase_options.dart';
import 'app/app.dart';
import 'app/di.dart';
import 'core/services/notification_service.dart';
import 'features/beacons/presentation/bloc/dashboard_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (Mandatory)
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Dependencies
  await initDependencies();

  // Initialize Foreground Task
  FlutterForegroundTask.initCommunicationPort();
  _initForegroundTask();

  // Initialize Notifications
  final notificationService = sl<NotificationService>();
  await notificationService.init();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              sl<AuthBloc>()..add(const AuthSubscriptionRequested()),
        ),
        BlocProvider(
          create: (context) => sl<DashboardBloc>()..add(StartScanRequested()),
        ),
      ],
      child: const BeaconApp(),
    ),
  );
}

void _initForegroundTask() {
  FlutterForegroundTask.init(
    androidNotificationOptions: AndroidNotificationOptions(
      channelId: 'beacon_scanner_service',
      channelName: 'Active Monitoring',
      channelDescription:
          'Maintains background beacon scanning for proximity alerts.',
      channelImportance: NotificationChannelImportance.LOW,
      priority: NotificationPriority.LOW,
    ),
    iosNotificationOptions: const IOSNotificationOptions(
      showNotification: true,
      playSound: false,
    ),
    foregroundTaskOptions: ForegroundTaskOptions(
      eventAction: ForegroundTaskEventAction.repeat(5000),
      autoRunOnBoot: false,
      autoRunOnMyPackageReplaced: true,
      allowWakeLock: true,
      allowWifiLock: true,
    ),
  );
}
