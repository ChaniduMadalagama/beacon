part of 'alert_bloc.dart';

sealed class AlertEvent extends Equatable {
  const AlertEvent();

  @override
  List<Object?> get props => [];
}

final class FetchAlertsRequested extends AlertEvent {}

final class ClearAlertsRequested extends AlertEvent {}
