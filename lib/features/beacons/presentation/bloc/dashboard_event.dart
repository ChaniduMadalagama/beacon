part of 'dashboard_bloc.dart';

sealed class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

final class StartScanRequested extends DashboardEvent {}

final class StopScanRequested extends DashboardEvent {}
