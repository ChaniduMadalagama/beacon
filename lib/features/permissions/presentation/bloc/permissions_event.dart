import 'package:equatable/equatable.dart';

abstract class PermissionsEvent extends Equatable {
  const PermissionsEvent();

  @override
  List<Object?> get props => [];
}

class LocationPermissionRequested extends PermissionsEvent {
  const LocationPermissionRequested();
}

class BluetoothPermissionRequested extends PermissionsEvent {
  const BluetoothPermissionRequested();
}

class NotificationPermissionRequested extends PermissionsEvent {
  const NotificationPermissionRequested();
}

class SetupCompleteRequested extends PermissionsEvent {
  const SetupCompleteRequested();
}

class CheckPermissionsRequested extends PermissionsEvent {
  const CheckPermissionsRequested();
}
