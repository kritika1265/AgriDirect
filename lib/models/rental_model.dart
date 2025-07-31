/// Rental model representing a tool rental transaction
class Rental {
  /// Creates a new Rental instance
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

  /// Unique identifier for the rental
  final String id;
  
  /// ID of the tool being rented
  final String toolId;
  
  /// ID of the person renting the tool
  final String renterId;
  
  /// ID of the tool owner
  final String ownerId;
  
  /// Start date of the rental period
  final DateTime startDate;
  
  /// End date of the rental period
  final DateTime endDate;
  
  /// Total amount for the rental
  final double totalAmount;
  
  /// Current status of the rental
  final String status;
  
  /// Payment status of the rental
  final String paymentStatus;
  
  /// When the rental record was created
  final DateTime createdAt;
  
  /// Optional notes about the rental
  final String? notes;

  /// Creates a Rental instance from JSON data
  factory Rental.fromJson(Map<String, dynamic> json) => Rental(
    id: json['id']?.toString() ?? '',
    toolId: json['tool_id']?.toString() ?? '',
    renterId: json['renter_id']?.toString() ?? '',
    ownerId: json['owner_id']?.toString() ?? '',
    startDate: json['start_date'] != null 
        ? DateTime.parse(json['start_date'].toString())
        : DateTime.now(),
    endDate: json['end_date'] != null 
        ? DateTime.parse(json['end_date'].toString())
        : DateTime.now(),
    totalAmount: double.tryParse(json['total_amount']?.toString() ?? '0') ?? 0.0,
    status: json['status']?.toString() ?? '',
    paymentStatus: json['payment_status']?.toString() ?? '',
    createdAt: json['created_at'] != null 
        ? DateTime.parse(json['created_at'].toString())
        : DateTime.now(),
    notes: json['notes']?.toString(),
  );
}