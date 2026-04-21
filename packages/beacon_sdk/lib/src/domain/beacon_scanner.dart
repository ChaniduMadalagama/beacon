import 'monitoring_event.dart';
import 'beacon_reading.dart';
import 'beacon_region.dart';

abstract class BeaconScanner {
  Stream<List<BeaconReading>> scan(BeaconRegion region);
  Stream<MonitoringEvent> monitor(BeaconRegion region);
  Stream<bool> get bluetoothStatus;
  Future<void> stopScan();
}
