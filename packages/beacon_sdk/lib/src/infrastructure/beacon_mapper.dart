import '../domain/beacon_reading.dart';

class BeaconMapper {
  static BeaconReading fromNative(Map<String, dynamic> data) {
    return BeaconReading(
      uuid: data['uuid'] as String,
      major: data['major'] as int,
      minor: data['minor'] as int,
      rssi: (data['rssi'] as num).toDouble(),
      distance: (data['distance'] as num).toDouble(),
      timestamp: DateTime.now(),
    );
  }
}
