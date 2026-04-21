import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:beacon_sdk/beacon_sdk.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/beacons/presentation/bloc/dashboard_bloc.dart';
import '../features/alerts/domain/repositories/alert_repository.dart';
import '../features/alerts/data/repositories/alert_repository_impl.dart';
import '../features/alerts/presentation/bloc/alert_bloc.dart';
import '../features/permissions/presentation/bloc/permissions_bloc.dart';
import '../core/services/notification_service.dart';
import '../core/services/proximity_service.dart';

// sl is short for Service Locator
final sl = GetIt.instance;

Future<void> initDependencies({
  bool isBackground = false,
}) async {
  // External
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => GoogleSignIn());

  // SDKs
  sl.registerLazySingleton<DistanceEstimator>(
    () => CurveFitDistanceEstimator(),
  );
  sl.registerLazySingleton<BeaconScanner>(
    () => BeaconScannerImpl(distanceEstimator: sl()),
  );

  // Services
  sl.registerLazySingleton(() => NotificationService());
  sl.registerLazySingleton<AlertRepository>(() => AlertRepositoryImpl());

  sl.registerLazySingleton(
    () => ProximityService(
      scanner: sl(),
      notifications: sl(),
      alerts: sl(),
      isBackgroundIsolate: isBackground,
    ),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      firebaseAuth: sl(),
      googleSignIn: sl(),
    ),
  );

  // Blocs
  sl.registerFactory(() => AuthBloc(authRepository: sl()));
  sl.registerFactory(() => DashboardBloc(proximityService: sl()));
  sl.registerFactory(
    () => AlertBloc(
      alertRepository: sl(),
      proximityService: sl(),
    ),
  );
  sl.registerFactory(() => PermissionsBloc());
}
