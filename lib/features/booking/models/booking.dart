/// Model data untuk pemesanan (booking).
class Booking {
  final int? id;
  final String customerName;
  final String tourDate;
  final double totalPrice;
  final String status; // 'pending', 'confirmed', 'cancelled'

  const Booking({
    this.id,
    required this.customerName,
    required this.tourDate,
    required this.totalPrice,
    this.status = 'pending',
  });

  /// Konversi dari Map (database row) ke object.
  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      id: map['id'] as int?,
      customerName: map['customer_name'] as String,
      tourDate: map['tour_date'] as String,
      totalPrice: (map['total_price'] as num).toDouble(),
      status: map['status'] as String? ?? 'pending',
    );
  }

  /// Konversi object ke Map untuk disimpan ke database.
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'customer_name': customerName,
      'tour_date': tourDate,
      'total_price': totalPrice,
      'status': status,
    };
  }

  Booking copyWith({
    int? id,
    String? customerName,
    String? tourDate,
    double? totalPrice,
    String? status,
  }) {
    return Booking(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      tourDate: tourDate ?? this.tourDate,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
    );
  }
}
