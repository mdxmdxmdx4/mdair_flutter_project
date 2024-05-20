class Flight_status {
  final int statusId;
  final String statusDescription;

  Flight_status({
    required this.statusId,
    required this.statusDescription,
  });

  factory Flight_status.fromMap(Map<String, dynamic> map) {
    return Flight_status(
      statusId: map['status_id'],
      statusDescription: map['status_description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'status_id': statusId,
      'status_description': statusDescription,
    };
  }

  @override
  String toString() {
    return 'Status: $statusDescription';
  }
}
