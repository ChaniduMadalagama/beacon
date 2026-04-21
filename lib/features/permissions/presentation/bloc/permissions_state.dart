import 'package:equatable/equatable.dart';

enum CustomPermissionStatus { initial, granted, denied, permanentlyDenied }

class PermissionsState extends Equatable {
  final CustomPermissionStatus locationStatus;
  final CustomPermissionStatus bluetoothStatus;
  final CustomPermissionStatus notificationStatus;
  final bool isLoading;
  final bool isSetupComplete;

  const PermissionsState({
    this.locationStatus = CustomPermissionStatus.initial,
    this.bluetoothStatus = CustomPermissionStatus.initial,
    this.notificationStatus = CustomPermissionStatus.initial,
    this.isLoading = false,
    this.isSetupComplete = false,
  });

  bool get isAllGranted =>
      locationStatus == CustomPermissionStatus.granted &&
      bluetoothStatus == CustomPermissionStatus.granted &&
      notificationStatus == CustomPermissionStatus.granted;

  PermissionsState copyWith({
    CustomPermissionStatus? locationStatus,
    CustomPermissionStatus? bluetoothStatus,
    CustomPermissionStatus? notificationStatus,
    bool? isLoading,
    bool? isSetupComplete,
  }) {
    return PermissionsState(
      locationStatus: locationStatus ?? this.locationStatus,
      bluetoothStatus: bluetoothStatus ?? this.bluetoothStatus,
      notificationStatus: notificationStatus ?? this.notificationStatus,
      isLoading: isLoading ?? this.isLoading,
      isSetupComplete: isSetupComplete ?? this.isSetupComplete,
    );
  }

  @override
  List<Object?> get props => [
        locationStatus,
        bluetoothStatus,
        notificationStatus,
        isLoading,
        isSetupComplete,
      ];
}
