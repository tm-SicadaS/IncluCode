import '../models/app_models.dart';

/// Temporary in-app store. Replace its methods with a repository backed by
/// Firebase once the project is configured. The screens never need to change.
class AppSession {
  AppSession._();

  static final instance = AppSession._();

  final List<BusRoute> routes = [
    const BusRoute(
      id: 'thrissur-guruvayur',
      name: 'Thrissur to Guruvayur',
      beaconUuid: 'b6b2d9b0-9e7d-4cbf-9a3a-01',
      mapUrl: 'https://www.openstreetmap.org/#map=12/10.56/76.13',
      stops: [
        RouteStop(name: 'Thrissur', time: '08:00 AM', coordinate: RouteCoordinate(latitude: 10.5276, longitude: 76.2144)),
        RouteStop(name: 'Ollur', time: '08:15 AM', coordinate: RouteCoordinate(latitude: 10.4863, longitude: 76.2009)),
        RouteStop(name: 'Chavakkad', time: '09:20 AM', coordinate: RouteCoordinate(latitude: 10.5830, longitude: 76.0388)),
        RouteStop(name: 'Guruvayur', time: '09:40 AM', coordinate: RouteCoordinate(latitude: 10.5940, longitude: 76.0410)),
      ],
    ),
    const BusRoute(
      id: 'kochi-aluva',
      name: 'Kochi to Aluva',
      beaconUuid: '2d2e4f11-b280-42bb-88cf-02',
      stops: [
        RouteStop(name: 'Kochi', time: '08:00 AM', coordinate: RouteCoordinate(latitude: 9.9312, longitude: 76.2673)),
        RouteStop(name: 'Kaloor', time: '08:15 AM', coordinate: RouteCoordinate(latitude: 9.9940, longitude: 76.2999)),
        RouteStop(name: 'Aluva', time: '09:10 AM', coordinate: RouteCoordinate(latitude: 10.1076, longitude: 76.3516)),
      ],
    ),
  ];

  final List<StaffMember> staff = [];
  TripDraft? currentTrip;

  void addRoute(BusRoute route) => routes.add(route);

  void saveStaff(Iterable<StaffMember> members) {
    for (final member in members) {
      final index = staff.indexWhere(
        (saved) => saved.phone == member.phone && saved.role == member.role,
      );
      if (index == -1) {
        staff.add(member);
      } else {
        staff[index] = member;
      }
    }
  }
}
