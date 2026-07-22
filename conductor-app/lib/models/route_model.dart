class RouteModel {
  final String id;
  final String routeName;
  final String bleUuid;

  RouteModel({
    required this.id,
    required this.routeName,
    required this.bleUuid,
  });

  factory RouteModel.fromMap(String id, Map<String, dynamic> data) {
    return RouteModel(
      id: id,
      routeName: data['routeName'] ?? '',
      bleUuid: data['bleUuid'] ?? '',
    );
  }
}
