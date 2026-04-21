import 'dart:async';
import 'package:beacon_scanner/beacon_scanner.dart' as native;
import '../domain/beacon_reading.dart';
import '../domain/beacon_region.dart';
import '../domain/beacon_scanner.dart';
import '../domain/distance_estimator.dart';
import '../domain/monitoring_event.dart' as domain;

class BeaconScannerImpl implements BeaconScanner {
  final native.BeaconScanner _nativeScanner = native.BeaconScanner.instance;
  final DistanceEstimator _distanceEstimator;

  // Storage for signal smoothing (Moving Average)
  // Key: UUID-Major-Minor, Value: List of recent RSSI values
  final Map<String, List<double>> _rssiCache = {};
  final int _smoothingWindowSize = 5;

  BeaconScannerImpl({DistanceEstimator? distanceEstimator})
    : _distanceEstimator = distanceEstimator ?? CurveFitDistanceEstimator();

  @override
  Stream<List<BeaconReading>> scan(BeaconRegion region) {
    final bool isWildcard = region.uuid == null || region.uuid!.isEmpty;
    
    // Using NOT_DEFINED constants from the platform interface for wildcard support
    final native.Region nativeRegion = native.Region(
      identifier: region.identifier,
      beaconId: isWildcard
          ? null
          : native.IBeaconId(
              proximityUUID: region.uuid!,
              majorId: region.major ?? native.IBeaconId.NOT_DEFINED_MAJOR_ID,
              minorId: region.minor ?? native.IBeaconId.NOT_DEFINED_MINOR_ID,
            ),
    );

    // Debug: Log the region being scanned
    // ignore: avoid_print
    print('SDK: Starting scan for region: ${region.identifier} (UUID: ${region.uuid ?? "WILDCARD"})');

    return _nativeScanner.ranging([nativeRegion]).map((result) {
      final List<dynamic> beacons = (result as dynamic).beacons ?? [];
      
      // Debug: Log detection count
      if (beacons.isNotEmpty) {
        // ignore: avoid_print
        print('SDK: Received ${beacons.length} beacons from native scanner');
      }

      final readings = <BeaconReading>[];

      for (final dynamic b in beacons) {
        try {
          // Standardizing field access across different beacon_scanner forks/versions
          // The platform interface uses a nested 'id' object (IBeaconId)
          String uuid = '';
          int major = 0;
          int minor = 0;
          
          if (b.id != null) {
            uuid = b.id.proximityUUID ?? '';
            major = b.id.majorId ?? 0;
            minor = b.id.minorId ?? 0;
          } else {
            uuid = b.proximityUUID ?? b.uuid ?? '';
            major = b.majorId ?? b.major ?? 0;
            minor = b.minorId ?? b.minor ?? 0;
          }

          final double rssi = (b.rssi ?? 0).toDouble();
          final int txPower = b.txPower ?? -59;

          final key = '$uuid-$major-$minor';

          // Signal Smoothing: Moving Average
          final rssiList = _rssiCache.putIfAbsent(key, () => []);
          rssiList.add(rssi);
          if (rssiList.length > _smoothingWindowSize) {
            rssiList.removeAt(0);
          }

          final smoothedRssi = rssiList.reduce((a, b) => a + b) / rssiList.length;

          final reading = BeaconReading(
            uuid: uuid,
            major: major,
            minor: minor,
            rssi: smoothedRssi,
            distance: _distanceEstimator.estimate(
              txPower,
              smoothedRssi,
            ),
            timestamp: DateTime.now(),
          );
          
          readings.add(reading);
        } catch (e) {
          // ignore: avoid_print
          print('SDK: Error mapping beacon: $e');
        }
      }

      return readings;
    });
  }

  @override
  Stream<domain.MonitoringEvent> monitor(BeaconRegion region) {
    final bool isWildcard = region.uuid == null || region.uuid!.isEmpty;
    
    final native.Region nativeRegion = native.Region(
      identifier: region.identifier,
      beaconId: native.IBeaconId(
        proximityUUID: isWildcard ? native.IBeaconId.NOT_DEFINED_UUID : region.uuid!,
        majorId: region.major ?? native.IBeaconId.NOT_DEFINED_MAJOR_ID,
        minorId: region.minor ?? native.IBeaconId.NOT_DEFINED_MINOR_ID,
      ),
    );

    // ignore: avoid_print
    print('SDK: Starting monitoring for region: ${region.identifier}');

    return _nativeScanner.monitoring([nativeRegion]).map((result) {
      // Mapping native MonitoringResult to domain MonitoringEvent
      domain.MonitoringEventType type;
      switch (result.monitoringEventType) {
        case native.MonitoringEventType.didEnterRegion:
          type = domain.MonitoringEventType.didEnterRegion;
          break;
        case native.MonitoringEventType.didExitRegion:
          type = domain.MonitoringEventType.didExitRegion;
          break;
        case native.MonitoringEventType.didDetermineStateForRegion:
          type = domain.MonitoringEventType.didDetermineStateForRegion;
          break;
      }

      domain.MonitoringState state;
      switch (result.monitoringState) {
        case native.MonitoringState.inside:
          state = domain.MonitoringState.inside;
          break;
        case native.MonitoringState.outside:
          state = domain.MonitoringState.outside;
          break;
        default:
          state = domain.MonitoringState.unknown;
      }

      return domain.MonitoringEvent(
        type: type,
        state: state,
        region: region,
      );
    });
  }

  @override
  Stream<bool> get bluetoothStatus {
    return _nativeScanner.bluetoothStateChanged().map((state) {
      return state == native.BluetoothState.stateOn;
    });
  }

  @override
  Future<void> stopScan() async {
    _rssiCache.clear();
    await _nativeScanner.close();
  }
}
