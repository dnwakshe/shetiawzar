/// Record of a customer enquiry placed through the app.
class EnquiryRecord {
  final String id;
  final String customerName;
  final String customerPhone;
  final String? notes;
  final String itemsSummary;
  final double totalAmount;
  final DateTime createdAt;

  const EnquiryRecord({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    this.notes,
    required this.itemsSummary,
    required this.totalAmount,
    required this.createdAt,
  });

  String get formattedDate {
    final day = createdAt.day.toString().padLeft(2, '0');
    final month = createdAt.month.toString().padLeft(2, '0');
    final year = createdAt.year;
    final hour = createdAt.hour.toString().padLeft(2, '0');
    final minute = createdAt.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }
}
