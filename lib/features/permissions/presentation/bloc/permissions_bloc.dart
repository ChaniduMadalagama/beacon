import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../app/di.dart';
import 'permissions_event.dart';
import 'permissions_state.dart';

class PermissionsBloc extends Bloc<PermissionsEvent, PermissionsState> {
  PermissionsBloc() : super(const PermissionsState()) {
    on<CheckPermissionsRequested>(_onCheckPermissions);
    on<LocationPermissionRequested>(_onLocationPermissionRequested);
    on<BluetoothPermissionRequested>(_onBluetoothPermissionRequested);
    on<NotificationPermissionRequested>(_onNotificationPermissionRequested);
    on<SetupCompleteRequested>(_onSetupCompleteRequested);
  }

  Future<void> _onSetupCompleteRequested(
    SetupCompleteRequested event,
    Emitter<PermissionsState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_setup_complete', true);
    emit(state.copyWith(isSetupComplete: true));
  }

  Future<void> _onCheckPermissions(
    CheckPermissionsRequested event,
    Emitter<PermissionsState> emit,
  ) async {
    final location = await Permission.locationAlways.status;
    
    // Cross-platform bluetooth status
    PermissionStatus bluetooth;
    if (Platform.isAndroid) {
      bluetooth = await Permission.bluetoothScan.status;
    } else {
      bluetooth = await Permission.bluetooth.status;
    }
    
    final notification = await Permission.notification.status;
    
    final prefs = await SharedPreferences.getInstance();
    final isSetupComplete = prefs.getBool('is_setup_complete') ?? false;

    emit(state.copyWith(
      locationStatus: _mapStatus(location),
      bluetoothStatus: _mapStatus(bluetooth),
      notificationStatus: _mapStatus(notification),
      isSetupComplete: isSetupComplete,
    ));
  }

  Future<void> _onLocationPermissionRequested(
    LocationPermissionRequested event,
    Emitter<PermissionsState> emit,
  ) async {
    try {
      if (Platform.isIOS) {
        final whenInUseStatus = await Permission.locationWhenInUse.request();
        if (whenInUseStatus.isGranted) {
          final alwaysStatus = await Permission.locationAlways.request();
          emit(state.copyWith(locationStatus: _mapStatus(alwaysStatus)));
        } else {
          emit(state.copyWith(locationStatus: _mapStatus(whenInUseStatus)));
        }
      } else {
        // On Android 11+ (API 30+), sequential request is required for Always access.
        // First, request "While in use" (foreground location).
        final whenInUseStatus = await Permission.location.request();
        
        if (whenInUseStatus.isGranted) {
          // Then request "Always" (background location).
          final alwaysStatus = await Permission.locationAlways.request();
          emit(state.copyWith(locationStatus: _mapStatus(alwaysStatus)));
        } else {
          emit(state.copyWith(locationStatus: _mapStatus(whenInUseStatus)));
        }
      }
    } catch (e) {
      // Log error but don't crash
      emit(state.copyWith(locationStatus: CustomPermissionStatus.denied));
    }
  }

  Future<void> _onBluetoothPermissionRequested(
    BluetoothPermissionRequested event,
    Emitter<PermissionsState> emit,
  ) async {
    try {
      PermissionStatus status;
      if (Platform.isAndroid) {
        status = await Permission.bluetoothScan.request();
      } else {
        // On iOS, Permission.bluetooth is the primary one for beacon scanning
        status = await Permission.bluetooth.request();
      }
      emit(state.copyWith(bluetoothStatus: _mapStatus(status)));
    } catch (e) {
      emit(state.copyWith(bluetoothStatus: CustomPermissionStatus.denied));
    }
  }

  Future<void> _onNotificationPermissionRequested(
    NotificationPermissionRequested event,
    Emitter<PermissionsState> emit,
  ) async {
    try {
      final bool granted = await sl<NotificationService>().requestPermissions();
      emit(state.copyWith(
        notificationStatus:
            granted ? CustomPermissionStatus.granted : CustomPermissionStatus.denied,
      ));
    } catch (e) {
      emit(state.copyWith(notificationStatus: CustomPermissionStatus.denied));
    }
  }

  CustomPermissionStatus _mapStatus(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
      case PermissionStatus.provisional:
      case PermissionStatus.limited:
        return CustomPermissionStatus.granted;
      case PermissionStatus.denied:
        return CustomPermissionStatus.denied;
      case PermissionStatus.permanentlyDenied:
      case PermissionStatus.restricted:
        return CustomPermissionStatus.permanentlyDenied;
    }
  }
}
