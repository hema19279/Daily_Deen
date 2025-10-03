import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import '../core/repository/qibla_repository.dart';
import '../core/services/location_service.dart';

class QiblaViewModel extends ChangeNotifier {
  final QiblaRepository _repository = QiblaRepository();

  double qiblaDirection = 0.0;
  double deviceHeading = 0.0;

  bool _initialized = false;

  Future<void> initialize(LocationService locationService) async {
    if (_initialized) return;
    _initialized = true;

    const delay = Duration(milliseconds: 100);

    while (locationService.currentPosition == null) {
      await Future.delayed(delay);
    }

    // Step 1: Get Qibla direction from user location
    if (locationService.currentPosition != null) {
      final lat = locationService.currentPosition!.latitude;
      final lon = locationService.currentPosition!.longitude;
      qiblaDirection = _repository.calculateQiblaAngle(lat, lon);
    }

    // Step 2: Listen to compass heading
    FlutterCompass.events?.listen((event) {
      if (event.heading != null) {
        deviceHeading = event.heading!;
        notifyListeners(); // Update UI with new heading
      }
    });
  }
}
