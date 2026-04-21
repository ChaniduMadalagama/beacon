class BeaconReading {
  final String uuid;
  final int major;
  final int minor;
  final double rssi;
  final double distance;
  final DateTime timestamp;

  const BeaconReading({
    required this.uuid,
    required this.major,
    required this.minor,
    required this.rssi,
    required this.distance,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'uuid': uuid,
        'major': major,
        'minor': minor,
        'rssi': rssi,
        'distance': distance,
        'timestamp': timestamp.toIso8601String(),
      };

  factory BeaconReading.fromJson(Map<String, dynamic> json) => BeaconReading(
        uuid: json['uuid'] as String,
        major: json['major'] as int,
        minor: json['minor'] as int,
        rssi: (json['rssi'] as num).toDouble(),
        distance: (json['distance'] as num).toDouble(),
        timestamp: DateTime.parse(json['timestamp'] as String),
      );

  BeaconReading copyWith({
    String? uuid,
    int? major,
    int? minor,
    double? rssi,
    double? distance,
    DateTime? timestamp,
  }) {
    return BeaconReading(
      uuid: uuid ?? this.uuid,
      major: major ?? this.major,
      minor: minor ?? this.minor,
      rssi: rssi ?? this.rssi,
      distance: distance ?? this.distance,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
