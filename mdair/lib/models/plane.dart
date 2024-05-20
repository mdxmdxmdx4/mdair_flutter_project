class Plane {
  late int planeId;
  late String model;
  late int businessSeatsCapacity;
  late int economySeatsCapacity;

  Plane({
    required this.planeId,
    required this.model,
    required this.businessSeatsCapacity,
    required this.economySeatsCapacity,
  });

  factory Plane.fromMap(Map<String, dynamic> map) {
    return Plane(
      planeId: map['plane_id'],
      model: map['model'],
      businessSeatsCapacity: map['business_seats_capacity'],
      economySeatsCapacity: map['economy_seats_capacity'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'model': model,
      'business_seats_capacity': businessSeatsCapacity,
      'economy_seats_capacity': economySeatsCapacity,
    };
  }

  @override
  String toString() {
    return 'Plane: $model (Business: $businessSeatsCapacity, Economy: $economySeatsCapacity)';
  }
}
