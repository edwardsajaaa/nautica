/// Model data untuk peralatan selam (equipment).
class Equipment {
  final int? id;
  final String name;
  final int stock;
  final double pricePerItem;

  const Equipment({
    this.id,
    required this.name,
    required this.stock,
    required this.pricePerItem,
  });

  /// Konversi dari Map (database row) ke object.
  factory Equipment.fromMap(Map<String, dynamic> map) {
    return Equipment(
      id: map['id'] as int?,
      name: map['name'] as String,
      stock: map['stock'] as int? ?? 0,
      pricePerItem: (map['price_per_item'] as num).toDouble(),
    );
  }

  /// Konversi object ke Map untuk disimpan ke database.
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'stock': stock,
      'price_per_item': pricePerItem,
    };
  }

  Equipment copyWith({
    int? id,
    String? name,
    int? stock,
    double? pricePerItem,
  }) {
    return Equipment(
      id: id ?? this.id,
      name: name ?? this.name,
      stock: stock ?? this.stock,
      pricePerItem: pricePerItem ?? this.pricePerItem,
    );
  }
}
