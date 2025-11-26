class WishlistItem {
  final int productId;
  final String name;
  final String slug;
  final double price;
  final List<String> images;

  WishlistItem({
    required this.productId,
    required this.name,
    required this.slug,
    required this.price,
    required this.images,
  });

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    final product = json["product"] as Map<String, dynamic>;

    final int id = int.tryParse(product["id"].toString()) ?? 0;
    final double price = double.tryParse(product["price"].toString()) ?? 0.0;

    // images
    final imagesMap = product["images"] as Map<String, dynamic>? ?? {};
    final List<String> images = [];

    if (imagesMap["gallery"] != null && imagesMap["gallery"] is List) {
      images.addAll((imagesMap["gallery"] as List).map((e) => e.toString()));
    }

    final thumbnail = imagesMap["thumbnail"]?.toString() ?? '';
    if (thumbnail.isNotEmpty && !images.contains(thumbnail)) {
      images.add(thumbnail);
    }

    return WishlistItem(
      productId: id,
      name: product["name"]?.toString() ?? '',
      slug: product["slug"]?.toString() ?? '',
      price: price,
      images: images,
    );
  }
}
