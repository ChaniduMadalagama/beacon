class BeaconRegion {
  final String identifier;
  final String? uuid;
  final int? major;
  final int? minor;

  const BeaconRegion({
    required this.identifier,
    this.uuid,
    this.major,
    this.minor,
  });
}
