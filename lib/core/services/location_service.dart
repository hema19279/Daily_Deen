import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationService extends ChangeNotifier {
  Position? _currentPosition;
  bool _locationDeniedForever = false;

  Position? get currentPosition => _currentPosition;
  bool get locationDeniedForever => _locationDeniedForever;

  Future<void> getUserLocation(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!context.mounted) return;
      await _showLocationDialog(
        context,
        "Location services are disabled. Please enable them.",
        onRetry: () => getUserLocation(context), // Retry after enabling
      );
      return;
    }

    // 2. Check permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.unableToDetermine) {
      permission = await Geolocator.requestPermission();
      if (!context.mounted) return;
      await _showLocationDialog(
          context,
          "Location permission is required to continue.",
          onRetry: () => getUserLocation(context),
        );
        return;
      
    }

    if (permission == LocationPermission.deniedForever) {
      _locationDeniedForever = true;
      if (!context.mounted) return;
      await _showLocationDialog(
        context,
        "Location permission is permanently denied. Please enable it in settings.",
        showSettings: true,
      );
      notifyListeners();
      return;
    }

    // 3. Permission granted, get location
    try {
      _currentPosition = await Geolocator.getCurrentPosition();
      notifyListeners();
    } catch (e) {
      if (!context.mounted) return;
      await _showLocationDialog(context, "Error retrieving location: $e");
    }
  }

  Future<void> _showLocationDialog(
    BuildContext context,
    String message, {
    VoidCallback? onRetry,
    bool showSettings = false,
  }) async {
    await showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text("Location Access"),
          content: Text(message),
          actions: [
            if (onRetry != null)
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  onRetry();
                },
                child: const Text("Try Again"),
              ),
            if (showSettings)
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Geolocator.openAppSettings();
                },
                child: const Text("Open Settings"),
              ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }
}
