part of 'alert_bloc.dart';

sealed class AlertState extends Equatable {
  const AlertState();

  @override
  List<Object?> get props => [];
}

final class AlertInitial extends AlertState {}

final class AlertLoading extends AlertState {}

final class AlertLoaded extends AlertState {
  final List<BeaconAlert> alerts;
  final int activeScansCount;
  final int nearbyBeaconsCount;

  const AlertLoaded({
    required this.alerts,
    required this.activeScansCount,
    required this.nearbyBeaconsCount,
  });

  @override
  List<Object?> get props => [alerts, activeScansCount, nearbyBeaconsCount];
}

final class AlertError extends AlertState {
  final String message;
  const AlertError(this.message);

  @override
  List<Object?> get props => [message];
}
