import '../models/app_models.dart';

/// Firebase-ready boundaries. Implement these later with Firebase packages;
/// this keeps Firebase calls out of widgets and makes the backend contract clear.
abstract class RouteRepository {
  Future<List<BusRoute>> getRoutes();
}

abstract class StaffRepository {
  Future<void> upsertStaff(StaffMember member);
  Future<List<StaffMember>> getStaff();
}

abstract class ActiveTripRepository {
  Future<void> startTrip(TripDraft trip);
  Future<void> updateLocation({
    required String tripId,
    required double latitude,
    required double longitude,
  });
  Future<void> stopTrip(String tripId);
}
