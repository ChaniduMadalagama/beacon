import 'dart:async';
import 'package:beacon/core/services/proximity_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:beacon_sdk/beacon_sdk.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final ProximityService _proximityService;
  StreamSubscription<List<BeaconReading>>? _scanSubscription;

  // Persistence Cache & Smoothing logic
  final Map<String, BeaconReading> _cachedBeacons = {};
  final Map<String, List<double>> _rssiHistory = {}; // Buffer for Moving Average
  final Map<String, DateTime> _lastSeen = {};
  final Duration _staleThreshold = const Duration(seconds: 8);
  static const int _windowSize = 10; // Smoothing window size

  DashboardBloc({required ProximityService proximityService})
    : _proximityService = proximityService,
      super(DashboardInitial()) {
    on<StartScanRequested>(_onStartScanRequested);
    on<StopScanRequested>(_onStopScanRequested);
    on<_BeaconsUpdated>(_onBeaconsUpdated);
  }

  Future<void> _onStartScanRequested(
    StartScanRequested event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    await _scanSubscription?.cancel();

    _proximityService.forceRanging(true);

    _scanSubscription = _proximityService.beaconStream.listen(
      (beacons) {
        add(_BeaconsUpdated(beacons));
      },
      onError: (e) {
        emit(DashboardError(e.toString()));
      },
    );
  }

  void _onBeaconsUpdated(_BeaconsUpdated event, Emitter<DashboardState> emit) {
    final now = DateTime.now();

    // 1. Update cache & history with newly seen beacons
    for (final beacon in event.beacons) {
      final key = '${beacon.uuid}-${beacon.major}-${beacon.minor}';
      
      // Update RSSI History for Moving Average
      final history = _rssiHistory[key] ?? [];
      history.add(beacon.rssi);
      if (history.length > _windowSize) history.removeAt(0);
      _rssiHistory[key] = history;

      // Calculate smoothed RSSI
      final avgRssi = history.reduce((a, b) => a + b) / history.length;
      
      // Create smoothed reading
      final smoothedBeacon = beacon.copyWith(rssi: avgRssi);
      
      _cachedBeacons[key] = smoothedBeacon;
      _lastSeen[key] = now;
    }

    // 2. Remove stale beacons
    _lastSeen.removeWhere((key, lastTime) {
      final isStale = now.difference(lastTime) > _staleThreshold;
      if (isStale) {
        _cachedBeacons.remove(key);
        _rssiHistory.remove(key);
      }
      return isStale;
    });

    // 3. Emit the merged and filtered list
    emit(DashboardLoaded(List<BeaconReading>.from(_cachedBeacons.values)));
  }

  Future<void> _onStopScanRequested(
    StopScanRequested event,
    Emitter<DashboardState> emit,
  ) async {
    await _scanSubscription?.cancel();
    _proximityService.forceRanging(false);
    _cachedBeacons.clear();
    _lastSeen.clear();
    emit(DashboardInitial());
  }

  @override
  Future<void> close() {
    _scanSubscription?.cancel();
    _proximityService.forceRanging(false);
    return super.close();
  }
}

class _BeaconsUpdated extends DashboardEvent {
  final List<BeaconReading> beacons;
  const _BeaconsUpdated(this.beacons);
  @override
  List<Object?> get props => [beacons];
}
