class Ticket {
  final int ticketNum;
  final int flightNumber;
  final int placeNumber;
  final double price;
  final int statusId;
  final int systemUserId;
  final String ticketClass;

  Ticket({
    required this.ticketNum,
    required this.flightNumber,
    required this.placeNumber,
    required this.price,
    required this.statusId,
    required this.systemUserId,
    required this.ticketClass,
  });

  factory Ticket.fromMap(Map<String, dynamic> map) {
    return Ticket(
      ticketNum: map['ticket_num'],
      flightNumber: map['flight_number'],
      placeNumber: map['place_number'],
      price: map['price'],
      statusId: map['status_id'],
      systemUserId: map['system_user_id'],
      ticketClass: map['ticket_class'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'flight_number': flightNumber,
      'place_number': placeNumber,
      'price': price,
      'status_id': statusId,
      'system_user_id': systemUserId,
      'ticket_class': ticketClass,
    };
  }

  @override
  String toString() {
    return 'Ticket #$ticketNum: Flight $flightNumber, Seat $placeNumber, Price: $price';
  }
}
