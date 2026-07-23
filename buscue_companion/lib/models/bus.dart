class Bus {
  final String route;
  final String from;
  final String to;
  final int arrivingInMinutes;

  const Bus({
    required this.route,
    required this.from,
    required this.to,
    required this.arrivingInMinutes,
  });

  String get arrivalLabel => 'Arriving in $arrivingInMinutes min';
}
