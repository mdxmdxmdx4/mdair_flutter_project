class TicketStatus {
  final int statusNum;
  final String statusDescription;

  TicketStatus({
    required this.statusNum,
    required this.statusDescription,
  });

  factory TicketStatus.fromMap(Map<String, dynamic> map) {
    return TicketStatus(
      statusNum: map['status_num'],
      statusDescription: map['status_description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'status_num': statusNum,
      'status_description': statusDescription,
    };
  }

  @override
  String toString() {
    return 'Ticket Status #$statusNum: $statusDescription';
  }
}
