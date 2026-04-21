import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/beacon_alert.dart';
import '../../domain/repositories/alert_repository.dart';

class AlertRepositoryImpl implements AlertRepository {
  static const String _storageKey = 'beacon_alerts_v1';
  final StreamController<List<BeaconAlert>> _alertsController = 
      StreamController<List<BeaconAlert>>.broadcast();

  @override
  Future<List<BeaconAlert>> getAlerts() async {
    // Simulated Latency (Requirement: "Synthetic delay of e.g. 2 seconds")
    await Future.delayed(const Duration(seconds: 2));

    final prefs = await SharedPreferences.getInstance();
    List<String>? jsonList = prefs.getStringList(_storageKey);

    // Initial Dataset Integration (Load prompt JSON if empty)
    if (jsonList == null || jsonList.isEmpty) {
      final initialAlerts = [
        {
          'type': 'BACKGROUND_DETECTION',
          'title': 'New Beacon Found',
          'body': "You are near 'Conference Room B'. Open the app for details.",
          'threshold_meters': 10.0,
          'current_distance': 8.5,
          'style': 'info_blue',
          'uuid': 'E2C56DB5-DFFB-48D2-B060-D0F5A71096E0',
          'actionLabel': 'Open App'
        },
        {
          'type': 'PROXIMITY_THRESHOLD',
          'title': 'Proximity Alert',
          'body': 'Welcome! You are now within 5 meters of the beacon.',
          'threshold_meters': 5.0,
          'current_distance': 4.8,
          'style': 'amber_warning',
          'uuid': 'E2C56DB5-DFFB-48D2-B060-D0F5A71096E0',
          'actionLabel': 'View Details'
        },
        {
          'type': 'IMMEDIATE_PROXIMITY',
          'title': 'Touchpoint Reached',
          'body': "You are standing directly at 'Private Office 4'. Tap to check-in.",
          'threshold_meters': 1.0,
          'current_distance': 0.8,
          'style': 'success_green',
          'uuid': 'A1221100-3344-4BC2-A901-EE203344CC89',
          'actionLabel': 'Auto Check-in'
        },
        {
          'type': 'SIGNAL_LOST',
          'title': 'Connection Dropped',
          'body': "Signal for 'West Wing Lobby' has been lost due to interference.",
          'threshold_meters': 0.0,
          'current_distance': -1.0,
          'style': 'error_red',
          'uuid': 'F4980120-E4F1-4E7B-9E33-0245648A044B',
          'actionLabel': 'Retry Connection'
        },
        {
          'type': 'HARDWARE_ERROR',
          'title': 'Bluetooth Disabled',
          'body': 'Scanning has stopped because Bluetooth was turned off.',
          'threshold_meters': 0.0,
          'current_distance': 0.0,
          'style': 'hardware_grey',
          'uuid': 'SYSTEM_PAYLOAD | BT_OFF',
          'actionLabel': 'Open Settings'
        },
        {
          'type': 'PERMISSION_DENIED',
          'title': 'Location Access Required',
          'body': "Background scanning requires 'Always Allow' location permissions.",
          'threshold_meters': 0.0,
          'current_distance': 0.0,
          'style': 'amber_warning',
          'uuid': 'SYSTEM_PAYLOAD | PERM_DENIED',
          'actionLabel': 'Request Permission'
        }
      ];
      
      jsonList = initialAlerts.map((e) => json.encode(e)).toList();
      await prefs.setStringList(_storageKey, jsonList);
    }
    
    final alerts = jsonList.map((jsonStr) {
      return BeaconAlert.fromJson(json.decode(jsonStr));
    }).toList().reversed.toList(); // Most recent first

    _alertsController.add(alerts);
    return alerts;
  }

  @override
  Stream<List<BeaconAlert>> watchAlerts() {
    // Initial fetch to populate the stream
    getAlerts();
    return _alertsController.stream;
  }

  @override
  Future<void> addAlert(BeaconAlert alert) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_storageKey) ?? [];
    
    final alertJson = json.encode(alert.toJson());
    jsonList.add(alertJson);
    
    // Keep only last 50 alerts to manage storage
    if (jsonList.length > 50) {
      jsonList.removeAt(0);
    }
    
    await prefs.setStringList(_storageKey, jsonList);
    
    // Notify listeners
    await getAlerts();
  }

  @override
  Future<void> clearAlerts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
    _alertsController.add([]);
  }
}
