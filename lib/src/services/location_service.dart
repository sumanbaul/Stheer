import 'dart:async';
import 'dart:ui' show Offset;
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class LocationService extends ChangeNotifier {
  StreamSubscription<Position>? _sub;
  final List<Offset> _todayRoute = <Offset>[]; // normalized points for preview
  bool _tracking = false;

  bool get isTracking => _tracking;
  List<Offset> get todayRoute => List.unmodifiable(_todayRoute);

  Future<bool> ensurePermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return false;
    }
    return true;
  }

  Future<void> startTracking() async {
    final ok = await ensurePermission();
    if (!ok) return;
    _tracking = true;
    notifyListeners();
    _sub?.cancel();
    _todayRoute.clear();
    _sub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.best, distanceFilter: 5),
    ).listen((pos) {
      // Normalize lat/lng roughly into 0..1 bounding box of today's path for preview
      // For simplicity, just map absolute ranges; a real map should use a map SDK.
      final double nx = ((pos.longitude + 180) / 360).clamp(0.0, 1.0);
      final double ny = (1 - (pos.latitude + 90) / 180).clamp(0.0, 1.0);
      _todayRoute.add(Offset(nx, ny));
      if (_todayRoute.length > 200) {
        _todayRoute.removeAt(0);
      }
      notifyListeners();
    });
  }

  Future<void> stopTracking() async {
    await _sub?.cancel();
    _sub = null;
    _tracking = false;
    notifyListeners();
  }

  @override
  Future<void> dispose() async {
    await _sub?.cancel();
    super.dispose();
  }
}


