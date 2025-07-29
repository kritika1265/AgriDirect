class Rental {
  final String id;
  final String toolId;
  final String renterId;
  final String ownerId;
  final DateTime startDate;
  final DateTime endDate;
  final double totalAmount;
  final String status;
  final String paymentStatus;
  final DateTime createdAt;
  final String? notes;

  Rental({
    required this.id,
    required this.toolId,
    required this.renterId,
    required this.ownerId,
    required this.startDate,
    required this.endDate,
    required this.totalAmount,
    required this.status,
    required this.paymentStatus,
    required this.createdAt,
    this.notes,
  });

  factory Rental.fromJson(Map<String, dynamic> json) {
    return Rental(
      id: json['id'] ?? '',
      toolId: json['tool_id'] ?? '',
      renterId: json['renter_id'] ?? '',
      ownerId: json['owner_id'] ?? '',
      startDate: DateTime.parse(json['start_date'] ?? DateTime.now().toIso8601String()),
      endDate: DateTime.parse(json['end_date'] ?? DateTime.now().toIso8601String()),
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      paymentStatus: json['payment_status'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      notes: json['notes'],
    );
  }
}

