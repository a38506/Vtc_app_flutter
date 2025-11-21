class ProductSearchItem {
  final String id;
  final String name;
  final String? description;
  final double? price;
  final int? stockQuantity;
  final String? thumbnail;
  final List<String>? gallery;

  ProductSearchItem({
    required this.id,
    required this.name,
    this.description,
    this.price,
    this.stockQuantity,
    this.thumbnail,
    this.gallery,
  });

  factory ProductSearchItem.fromJson(Map<String, dynamic> json) {
    return ProductSearchItem(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'],
      price: json['price'] != null ? double.tryParse(json['price'].toString()) : null,
      stockQuantity: json['stock_quantity'],
      thumbnail: json['images'] != null ? json['images']['thumbnail'] : null,
      gallery: json['images'] != null && json['images']['gallery'] != null
          ? List<String>.from(json['images']['gallery'])
          : [],
    );
  }
}
