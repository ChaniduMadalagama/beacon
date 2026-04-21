import '../entities/beacon_alert.dart';

abstract class AlertRepository {
  Future<List<BeaconAlert>> getAlerts();
  Stream<List<BeaconAlert>> watchAlerts();
  Future<void> addAlert(BeaconAlert alert);
  Future<void> clearAlerts();
}
