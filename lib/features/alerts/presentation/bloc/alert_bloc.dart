import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/beacon_alert.dart';
import '../../domain/repositories/alert_repository.dart';
import '../../../../core/services/proximity_service.dart';

part 'alert_event.dart';
part 'alert_state.dart';

class AlertBloc extends Bloc<AlertEvent, AlertState> {
  final AlertRepository _alertRepository;
  final ProximityService _proximityService;
  StreamSubscription? _alertsSubscription;

  AlertBloc({
    required AlertRepository alertRepository,
    required ProximityService proximityService,
  })  : _alertRepository = alertRepository,
        _proximityService = proximityService,
        super(AlertInitial()) {
    on<FetchAlertsRequested>(_onFetchAlertsRequested);
    on<_AlertsUpdated>(_onAlertsUpdated);
    on<ClearAlertsRequested>(_onClearAlertsRequested);
  }

  Future<void> _onFetchAlertsRequested(
    FetchAlertsRequested event,
    Emitter<AlertState> emit,
  ) async {
    emit(AlertLoading());

    await _alertsSubscription?.cancel();
    _alertsSubscription = _alertRepository.watchAlerts().listen((alerts) {
      add(_AlertsUpdated(alerts));
    });
  }

  void _onAlertsUpdated(_AlertsUpdated event, Emitter<AlertState> emit) {
    emit(
      AlertLoaded(
        alerts: event.alerts,
        activeScansCount: 12, // Mock or real from scanning state
        nearbyBeaconsCount: event.alerts
            .where(
              (a) =>
                  a.type == 'IMMEDIATE_PROXIMITY' ||
                  a.type == 'PROXIMITY_THRESHOLD',
            )
            .length,
      ),
    );
  }

  Future<void> _onClearAlertsRequested(
    ClearAlertsRequested event,
    Emitter<AlertState> emit,
  ) async {
    await _alertRepository.clearAlerts();
    _proximityService.resetNotificationHistory();
  }

  @override
  Future<void> close() {
    _alertsSubscription?.cancel();
    return super.close();
  }
}

// Internal event for stream updates
class _AlertsUpdated extends AlertEvent {
  final List<BeaconAlert> alerts;
  const _AlertsUpdated(this.alerts);
}
