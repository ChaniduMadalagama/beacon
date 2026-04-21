import 'dart:math';

abstract class DistanceEstimator {
  double estimate(int txPower, double rssi);
}

class CurveFitDistanceEstimator implements DistanceEstimator {
  @override
  double estimate(int txPower, double rssi) {
    if (rssi == 0) {
      return -1.0; // No signal
    }

    // Ratio = RSSI / TX_Power
    final ratio = rssi / txPower;

    if (ratio < 1.0) {
      // Distance = Ratio^10
      return pow(ratio, 10).toDouble();
    } else {
      // Distance = (0.89976) * Ratio^7.7095 + 0.111
      return (0.89976) * pow(ratio, 7.7095) + 0.111;
    }
  }
}
