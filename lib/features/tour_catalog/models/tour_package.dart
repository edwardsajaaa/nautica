/// Model data untuk paket wisata tur.
class TourPackage {
  final int? id;
  final String title;
  final String description;
  final double price;
  final String? imagePath;

  const TourPackage({
    this.id,
    required this.title,
    required this.description,
    required this.price,
    this.imagePath,
  });

  /// Konversi dari Map (database row) ke object.
  factory TourPackage.fromMap(Map<String, dynamic> map) {
    return TourPackage(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String,
      price: (map['price'] as num).toDouble(),
      imagePath: map['image_path'] as String?,
    );
  }

  /// Konversi object ke Map untuk disimpan ke database.
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'description': description,
      'price': price,
      'image_path': imagePath,
    };
  }

  /// Membuat salinan dengan nilai yang diperbarui.
  TourPackage copyWith({
    int? id,
    String? title,
    String? description,
    double? price,
    String? imagePath,
  }) {
    return TourPackage(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}
