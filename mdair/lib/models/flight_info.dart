class FlightInfo {
  final int flightId;
  final String departureTime;
  final String arrivalTime;
  final String duration;
  final String price;
  final String departureAirport;
  final String destinationAirport;
  final int availableSeats;
  final bool isExpanded;

  FlightInfo({
    required this.flightId,
    required this.departureTime,
    required this.arrivalTime,
    required this.duration,
    required this.price,
    required this.departureAirport,
    required this.destinationAirport,
    required this.availableSeats,
    this.isExpanded = false,
  });

  @override
  String toString() {
    return ' $flightId FlightInfo{departureTime: $departureTime, '
        'arrivalTime: $arrivalTime, duration: $duration, '
        'price: $price, departureAirport: $departureAirport, '
        'destinationAirport: $destinationAirport, '
        'availableSeats: $availableSeats}';
  }
}

String calculateTimeDifference(String startTimeStr, String endTimeStr) {
  List<String> start = startTimeStr.split(':');
  List<String> end = endTimeStr.split(':');

  int startHour = int.parse(start[0]);
  int startMinute = int.parse(start[1]);
  int endHour = int.parse(end[0]);
  int endMinute = int.parse(end[1]);

  if (endHour < startHour || (endHour == startHour && endMinute < startMinute)) {
    endHour += 24;
  }

  int totalStartMinutes = startHour * 60 + startMinute;
  int totalEndMinutes = endHour * 60 + endMinute;

  int diffMinutes = totalEndMinutes - totalStartMinutes;

  int diffHours = diffMinutes ~/ 60;
  diffMinutes %= 60;

  return '${diffHours}h ${diffMinutes}m';
}

class FlightResult {
  final int ticketNum;
  final int seatNumber;
  final double price;
  final String departureDate;
  final String departureAirport;
  final String arrivalAirport;
  final int flightNumber;
  final String ticketClass;

  FlightResult({
    required this.ticketNum,
    required this.seatNumber,
    required this.price,
    required this.departureDate,
    required this.departureAirport,
    required this.arrivalAirport,
    required this.flightNumber,
    required this.ticketClass,
  });
}

