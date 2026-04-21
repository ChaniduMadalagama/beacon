import 'dart:async';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import '../../app/di.dart';
import 'proximity_service.dart';

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(BackgroundScannerTask());
}

class BackgroundScannerTask extends TaskHandler {
  StreamSubscription? _proximitySubscription;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    // 1. Re-initialize minimal dependencies for the background isolate
    // Note: We pass isBackground: true so ProximityService knows its role
    await initDependencies(isBackground: true);

    // 2. Start Proximity Monitoring in the background
    final proximityService = sl<ProximityService>();
    proximityService.startMonitoring();

    // 3. Optional: Listen to internal beacon stream to send status back to UI
    _proximitySubscription = proximityService.beaconStream.listen((beacons) {
      final data = beacons.map((b) => b.toJson()).toList();
      FlutterForegroundTask.sendDataToMain(data);
    });
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    // This runs periodically if configured, can be used for heartbeats
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    await _proximitySubscription?.cancel();
    sl<ProximityService>().stopMonitoring();
  }

  @override
  void onNotificationPressed() {
    FlutterForegroundTask.launchApp();
  }

  @override
  void onReceiveData(Object data) {
    if (data is Map && data['event'] == 'FORCE_RANGING') {
      final bool value = data['value'] as bool;
      sl<ProximityService>().forceRanging(value);
    }
  }
}
