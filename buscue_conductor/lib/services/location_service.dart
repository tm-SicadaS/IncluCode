/// Lightweight location primitives and a simple stubbed service.
///
/// This removes the dependency on the `geolocator` package while keeping a
/// small API surface the rest of the app can use. The service currently
/// produces no live location data and will return an error when asked for the
/// current position. Replace with a concrete implementation if/when needed.

class LocationPosition {
  final double latitude;
  final double longitude;
  const LocationPosition(this.latitude, this.longitude);
}

class LocationService {
  const LocationService();

  Future<LocationPosition> requestCurrentPosition() async {
    throw const PermissionDeniedException('Location services removed from app.');
  }

  Stream<LocationPosition> get positionStream => Stream<LocationPosition>.empty();
}

class LocationServiceDisabledException implements Exception {
  const LocationServiceDisabledException();
}

class PermissionDeniedException implements Exception {
  final String? message;
  const PermissionDeniedException([this.message]);
}
