class Flight {
  int flightNumber;
  int planeId;
  int departureAirportId;
  int destinationAirportId;
  String departureDatetime;
  String arriveDatetime;
  int availableSeats;
  int status;

  Flight({
    required this.flightNumber,
    required this.planeId,
    required this.departureAirportId,
    required this.destinationAirportId,
    required this.departureDatetime,
    required this.arriveDatetime,
    required this.availableSeats,
    required this.status,
  });

  factory Flight.fromMap(Map<String, dynamic> map) {
    return Flight(
      flightNumber: map['flight_number'],
      planeId: map['plane_id'],
      departureAirportId: map['departure_airport_id'],
      destinationAirportId: map['destination_airport_id'],
      departureDatetime: map['departure_datetime'],
      arriveDatetime: map['arrive_datetime'],
      availableSeats: map['available_seats'],
      status: map['status'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'plane_id': planeId,
      'departure_airport_id': departureAirportId,
      'destination_airport_id': destinationAirportId,
      'departure_datetime': departureDatetime,
      'arrive_datetime': arriveDatetime,
      'available_seats': availableSeats,
      'status': status,
    };
  }

  @override
  String toString() {
    return 'Flight #$flightNumber: $departureDatetime - $arriveDatetime';
  }
}
