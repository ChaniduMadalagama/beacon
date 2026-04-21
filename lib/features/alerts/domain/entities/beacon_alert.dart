class BeaconAlert {
  final String type;
  final String title;
  final String body;
  final double thresholdMeters;
  final double currentDistance;
  final String style;
  final String uuid;
  final String actionLabel;
  final Map<String, dynamic> payload;

  const BeaconAlert({
    required this.type,
    required this.title,
    required this.body,
    required this.thresholdMeters,
    required this.currentDistance,
    required this.style,
    required this.uuid,
    required this.actionLabel,
    required this.payload,
  });

  factory BeaconAlert.fromJson(Map<String, dynamic> json) {
    return BeaconAlert(
      type: json['type'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      thresholdMeters: (json['threshold_meters'] as num).toDouble(),
      currentDistance: (json['current_distance'] as num).toDouble(),
      style: json['style'] as String,
      uuid: json['uuid'] as String? ?? 'N/A',
      actionLabel: json['action_label'] as String? ?? 'View',
      payload: json['payload'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'title': title,
      'body': body,
      'threshold_meters': thresholdMeters,
      'current_distance': currentDistance,
      'style': style,
      'uuid': uuid,
      'action_label': actionLabel,
      'payload': payload,
    };
  }
}
