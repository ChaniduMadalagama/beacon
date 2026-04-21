import 'beacon_region.dart';

enum MonitoringEventType { didEnterRegion, didExitRegion, didDetermineStateForRegion }

enum MonitoringState { inside, outside, unknown }

class MonitoringEvent {
  final MonitoringEventType type;
  final MonitoringState state;
  final BeaconRegion region;

  const MonitoringEvent({
    required this.type,
    required this.region,
    this.state = MonitoringState.unknown,
  });

  @override
  String toString() => 'MonitoringEvent{type: $type, state: $state, region: ${region.identifier}}';
}
