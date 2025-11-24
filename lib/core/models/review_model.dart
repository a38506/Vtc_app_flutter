class Review {
  final int id;
  final int productId;
  final int customerId;
  final int? orderId;
  final int rating;
  final String title;
  final String content;
  final List<String> images;
  final String? customerName;

  Review({
    required this.id,
    required this.productId,
    required this.customerId,
    this.orderId,
    required this.rating,
    required this.title,
    required this.content,
    this.images = const [],
    this.customerName,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: int.parse(json['id'].toString()),
      productId: int.parse(json['product_id'].toString()),
      customerId: int.parse(json['customer_id'].toString()),
      orderId: json['order_id'] != null
          ? int.parse(json['order_id'].toString())
          : null,
      rating: int.parse(json['rating'].toString()),
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      customerName: json['customer_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'customer_id': customerId,
      'order_id': orderId,
      'rating': rating,
      'title': title,
      'content': content,
      'images': images,
    };
  }
}
