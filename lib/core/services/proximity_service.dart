import 'dart:async';
import 'package:beacon_sdk/beacon_sdk.dart';
import '../../features/alerts/domain/entities/beacon_alert.dart';
import '../../features/alerts/domain/repositories/alert_repository.dart';
import 'notification_service.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'background_scanner_task.dart';

class ProximityService {
  final BeaconScanner _scanner;
  final NotificationService _notifications;
  final AlertRepository _alerts;
  final bool isBackgroundIsolate;

  StreamSubscription? _monitoringSub;
  StreamSubscription? _rangingSub;
  StreamSubscription? _bluetoothSub;

  final _beaconsController = StreamController<List<BeaconReading>>.broadcast();
  Stream<List<BeaconReading>> get beaconStream => _beaconsController.stream;

  bool _isForcedRanging = false;
  bool _isMonitoring = false;
  bool _isCallbackRegistered = false;

  // Track session-level notifications to avoid spam
  final Set<String> _notifiedEntry = {};
  final Set<String> _notified5Meters = {};
  final Set<String> _notified1Meter = {};
  bool _notifiedBluetoothOff = false;

  ProximityService({
    required BeaconScanner scanner,
    required NotificationService notifications,
    required AlertRepository alerts,
    this.isBackgroundIsolate = false,
  }) : _scanner = scanner,
       _notifications = notifications,
       _alerts = alerts;

  void startMonitoring() {
    if (_isMonitoring) return;
    _isMonitoring = true;

    _stopAll();
    const region = BeaconRegion(identifier: 'GlobalMonitor');

    // 1. Monitor Background Region Events
    _monitoringSub = _scanner.monitor(region).listen(_handleMonitoringEvent);

    // 2. Monitor Bluetooth Status
    _bluetoothSub = _scanner.bluetoothStatus.listen(_handleBluetoothStatus);

    // 3. Start Foreground Service if not already running (only in UI isolate)
    if (!isBackgroundIsolate) {
      _startBackgroundService();
      _listenToBackgroundTask();
    }
  }

  void _listenToBackgroundTask() {
    if (_isCallbackRegistered) return;
    _isCallbackRegistered = true;

    FlutterForegroundTask.addTaskDataCallback((data) {
      if (data is List) {
        final readings = data.map((item) {
          return BeaconReading.fromJson(Map<String, dynamic>.from(item));
        }).toList();
        _beaconsController.add(readings);
      } else if (data is Map && data['event'] == 'RESET_NOTIFICATIONS') {
        resetNotificationHistory();
      }
    });
  }

  void _handleMonitoringEvent(MonitoringEvent event) {
    final regionId = event.region.identifier;

    if (event.type == MonitoringEventType.didEnterRegion ||
        (event.type == MonitoringEventType.didDetermineStateForRegion &&
            event.state == MonitoringState.inside)) {
      if (!_notifiedEntry.contains(regionId)) {
        _notifiedEntry.add(regionId);
        _triggerAlert(
          type: 'BACKGROUND_DETECTION',
          title: 'New Beacon Found',
          body: "You are near 'Conference Room B'. Open the app for details.",
          style: 'info_blue',
          uuid: event.region.uuid ?? 'Global',
          actionLabel: 'Open App',
        );
      }

      // Start ranging for precision updates when inside
      _updateRangingState();
    } else if (event.type == MonitoringEventType.didExitRegion ||
        (event.type == MonitoringEventType.didDetermineStateForRegion &&
            event.state == MonitoringState.outside)) {
      if (_notifiedEntry.contains(regionId)) {
        _notifiedEntry.remove(regionId);
        _notified5Meters.remove(regionId);
        _notified1Meter.remove(regionId);

        _triggerAlert(
          type: 'SIGNAL_LOST',
          title: 'Connection Dropped',
          body:
              "Signal for 'West Wing Lobby' has been lost due to interference.",
          style: 'error_red',
          uuid: event.region.uuid ?? 'Global',
          actionLabel: 'Retry Connection',
        );
      }
      _updateRangingState();
    }
  }

  void _startRanging(BeaconRegion region) {
    _rangingSub?.cancel();
    _rangingSub = _scanner.scan(region).listen((readings) {
      _beaconsController.add(readings);
      if (readings.isEmpty) return;

      // Check for closest beacon
      final closest = readings.reduce(
        (a, b) => a.distance < b.distance ? a : b,
      );
      final id = closest.uuid;

      // 1. Proximity Alert (5m)
      if (closest.distance < 5.0 && !_notified5Meters.contains(id)) {
        _notified5Meters.add(id);
        _triggerAlert(
          type: 'PROXIMITY_THRESHOLD',
          title: 'Proximity Alert',
          body: 'Welcome! You are now within 5 meters of the beacon.',
          style: 'amber_warning',
          uuid: id,
          actionLabel: 'View Details',
          currentDistance: closest.distance,
          threshold: 5.0,
        );
      }

      // 2. Touchpoint Reached (1m)
      if (closest.distance < 1.0 && !_notified1Meter.contains(id)) {
        _notified1Meter.add(id);
        _triggerAlert(
          type: 'IMMEDIATE_PROXIMITY',
          title: 'Touchpoint Reached',
          body:
              "You are standing directly at 'Private Office 4'. Tap to check-in.",
          style: 'success_green',
          uuid: id,
          actionLabel: 'Auto Check-in',
          currentDistance: closest.distance,
          threshold: 1.0,
        );
      }
    });
  }

  void _updateRangingState() {
    const region = BeaconRegion(identifier: 'AllBeacons');

    // Ranging should be active if we are "inside" a region OR if the UI forces it
    final shouldRange = _notifiedEntry.isNotEmpty || _isForcedRanging;

    if (shouldRange) {
      // If we are in UI isolate and background service is running, it handles ranging
      if (!isBackgroundIsolate && _rangingSub == null) {
        FlutterForegroundTask.isRunningService.then((isRunning) {
          if (!isRunning) {
            _startRanging(region);
          }
        });
      } else if (isBackgroundIsolate && _rangingSub == null) {
        _startRanging(region);
      }
    } else {
      _stopRanging();
    }
  }

  void forceRanging(bool enable) {
    _isForcedRanging = enable;
    _updateRangingState();

    // Sync state with Background isolate if we are in UI
    if (!isBackgroundIsolate) {
      FlutterForegroundTask.sendDataToTask({
        'event': 'FORCE_RANGING',
        'value': enable,
      });
    }
  }

  Future<void> _startBackgroundService() async {
    if (await FlutterForegroundTask.isRunningService) return;

    await FlutterForegroundTask.startService(
      notificationTitle: 'Active Monitoring',
      notificationText: 'Scanning for nearby beacons...',
      callback: startCallback,
    );
  }

  void _handleBluetoothStatus(bool isOn) {
    if (!isOn && !_notifiedBluetoothOff) {
      _notifiedBluetoothOff = true;
      _triggerAlert(
        type: 'HARDWARE_ERROR',
        title: 'Bluetooth Disabled',
        body: 'Scanning has stopped because Bluetooth was turned off.',
        style: 'hardware_grey',
        uuid: 'SYSTEM_PAYLOAD | BT_OFF',
        actionLabel: 'Open Settings',
      );
    } else if (isOn) {
      _notifiedBluetoothOff = false;
    }
  }

  /// Clears internal debouncing logic so alerts can re-trigger
  void resetNotificationHistory() {
    _notifiedEntry.clear();
    _notified5Meters.clear();
    _notified1Meter.clear();
    _notifiedBluetoothOff = false;

    // If we are in UI, tell the background service to also reset
    if (!isBackgroundIsolate) {
      FlutterForegroundTask.sendDataToTask({'event': 'RESET_NOTIFICATIONS'});
    }
  }

  Future<void> _triggerAlert({
    required String type,
    required String title,
    required String body,
    required String style,
    required String uuid,
    required String actionLabel,
    double currentDistance = 0.0,
    double threshold = 0.0,
  }) async {
    final alert = BeaconAlert(
      type: type,
      title: title,
      body: body,
      thresholdMeters: threshold,
      currentDistance: currentDistance,
      style: style,
      uuid: uuid,
      actionLabel: actionLabel,
      payload: {},
    );

    // 1. Save to Persistent DB
    await _alerts.addAlert(alert);

    // 2. Show System Notification
    await _notifications.showNotification(
      id: alert.hashCode,
      title: title,
      body: body,
    );
  }

  void _stopRanging() {
    _rangingSub?.cancel();
    _rangingSub = null;
  }

  void _stopAll() {
    _monitoringSub?.cancel();
    _rangingSub?.cancel();
    _bluetoothSub?.cancel();
  }

  void stopMonitoring() async {
    _isMonitoring = false;
    _stopAll();
    await _scanner.stopScan();
    await _beaconsController.close();
    await FlutterForegroundTask.stopService();
  }
}
