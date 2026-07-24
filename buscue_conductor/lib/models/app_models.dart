class RouteCoordinate {
  const RouteCoordinate({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;
}

class RouteStop {
  const RouteStop({
    required this.name,
    required this.time,
    required this.coordinate,
  });

  final String name;
  final String time;
  final RouteCoordinate coordinate;
}

/// Mirrors one document in Firestore's `routes` collection.
/// Keep [beaconUuid] private to the driver app; it is not shown in the UI.
class BusRoute {
  const BusRoute({
    required this.id,
    required this.name,
    required this.beaconUuid,
    required this.stops,
    this.mapUrl,
  });

  final String id;
  final String name;
  final String beaconUuid;
  final List<RouteStop> stops;
  final String? mapUrl;
}

enum StaffRole { driver, conductor, coConductor }

class StaffMember {
  const StaffMember({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    this.badgeNumber,
  });

  final String id;
  final String name;
  final String phone;
  final StaffRole role;
  final String? badgeNumber;
}

class TripDraft {
  const TripDraft({
    required this.route,
    required this.busNumber,
    required this.shift,
  });

  final BusRoute route;
  final String busNumber;
  final String shift;
}
