class Airport {
  late int airportId;
  late String airportName;
  late String locationCountry;
  late String locationCity;

  Airport({
    required this.airportId,
    required this.airportName,
    required this.locationCountry,
    required this.locationCity,
  });

  factory Airport.fromMap(Map<String, dynamic> map) {
    return Airport(
      airportId: map['airport_id'],
      airportName: map['airport_name'],
      locationCountry: map['location_country'],
      locationCity: map['location_city'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'airport_name': airportName,
      'location_country': locationCountry,
      'location_city': locationCity,
    };
  }

  @override
  String toString() {
    return 'Airport: $airportName ($locationCity, $locationCountry)';
  }
}