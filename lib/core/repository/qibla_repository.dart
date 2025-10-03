import 'dart:math' as math;

class QiblaRepository {
  double calculateQiblaAngle(double lat, double lon) {
    const kaabaLat = 21.4225;
    const kaabaLon = 39.8262;

    final latRad = lat * math.pi / 180;
    final deltaLon = (kaabaLon - lon) * math.pi / 180;
    final kaabaLatRad = kaabaLat * math.pi / 180;

    final y = math.sin(deltaLon);
    final x = math.cos(latRad) * math.tan(kaabaLatRad) - math.sin(latRad) * math.cos(deltaLon);

    final bearing = math.atan2(y, x);
    return (bearing * 180 / math.pi + 360) % 360;
  }
}