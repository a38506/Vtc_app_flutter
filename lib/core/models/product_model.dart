/// ----------------------------
/// 🧩 MODEL: Product Variant
/// ----------------------------
class ProductVariant {
  final int id;
  final String name;
  final String sku;
  final double price;
  final int stockQuantity;
  final double? weight;
  final String? image;

  ProductVariant({
    required this.id,
    required this.name,
    required this.sku,
    required this.price,
    required this.stockQuantity,
    this.weight,
    this.image,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: json['id'] is String ? int.tryParse(json['id']) ?? 0 : (json['id'] ?? 0),
      name: json['name'] ?? '',
      sku: json['sku'] ?? '',
      price: json['price'] != null
          ? (json['price'] is String
              ? double.tryParse(json['price']) ?? 0
              : (json['price'] as num).toDouble())
          : 0,
      stockQuantity: json['stock_quantity'] is String
          ? int.tryParse(json['stock_quantity']) ?? 0
          : (json['stock_quantity'] ?? 0),
      weight: json['weight'] != null
          ? (json['weight'] is String
              ? double.tryParse(json['weight'])
              : (json['weight'] as num).toDouble())
          : null,
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'sku': sku,
        'price': price,
        'stock_quantity': stockQuantity,
        'weight': weight,
        'image': image,
      };
}

/// ----------------------------
/// 🧩 MODEL: Product Images
/// ----------------------------
class ProductImages {
  final List<String> gallery;
  final String? thumbnail;

  ProductImages({List<String>? gallery, this.thumbnail})
      : gallery = gallery ?? [];

  factory ProductImages.fromJson(Map<String, dynamic> json) => ProductImages(
        gallery: (json['gallery'] as List?)?.map((e) => e.toString()).toList() ?? [],
        thumbnail: json['thumbnail'],
      );

  List<String> get all => [if (thumbnail != null) thumbnail!, ...gallery];

  Map<String, dynamic> toJson() => {
        'gallery': gallery,
        'thumbnail': thumbnail,
      };
}

/// ----------------------------
/// 🧩 MODEL: Product Review
/// ----------------------------
class ProductReview {
  final int id;
  final int productId;
  final int customerId;
  final int? orderId;
  final double rating;
  final String? title;
  final String? content;
  final List<String>? images;
  final String status; // 'pending' | 'approved' | 'rejected'
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductReview({
    required this.id,
    required this.productId,
    required this.customerId,
    this.orderId,
    required this.rating,
    this.title,
    this.content,
    this.images,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductReview.fromJson(Map<String, dynamic> json) => ProductReview(
        id: json['id'] ?? 0,
        productId: json['product_id'] ?? 0,
        customerId: json['customer_id'] ?? 0,
        orderId: json['order_id'],
        rating: (json['rating'] as num).toDouble(),
        title: json['title'],
        content: json['content'],
        images: (json['images'] as List?)?.map((e) => e.toString()).toList(),
        status: json['status'] ?? 'pending',
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: DateTime.parse(json['updated_at']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'product_id': productId,
        'customer_id': customerId,
        'order_id': orderId,
        'rating': rating,
        'title': title,
        'content': content,
        'images': images,
        'status': status,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}

/// ----------------------------
/// 🧩 MODEL: Product
/// ----------------------------
class Product {
  final int id;
  final String name;
  final String slug;
  final String? sku;
  final int? categoryId;
  final int? unitId;
  final String? description;
  final ProductImages? images;
  final double price;
  final double? comparePrice;
  final double? costPrice;
  final double? weight;
  final String? dimensions;
  final int stockQuantity;
  final int? minStock;
  final bool? trackInventory;
  final bool? isFresh;
  final int? shelfLifeDays;
  final String? storageConditions;
  final String? origin;
  final String? harvestSeason;
  final bool? organicCertified;
  final bool? isFeatured;
  final bool? isActive;
  final String? seoTitle;
  final String? seoDescription;
  final int? createdBy;
  final String? createdAt;
  final String? updatedAt;
  final String? deletedAt;
  final String? searchVector;
  final String? shortDescription;
  final Map<String, dynamic>? specifications;
  final List<ProductVariant>? variants;
  final double? rating;
  final int? reviewCount;
  final List<ProductReview>? reviews;

  Product({
    required this.id,
    required this.name,
    required this.slug,
    this.sku,
    this.categoryId,
    this.unitId,
    this.description,
    this.images,
    required this.price,
    this.comparePrice,
    this.costPrice,
    this.weight,
    this.dimensions,
    required this.stockQuantity,
    this.minStock,
    this.trackInventory,
    this.isFresh,
    this.shelfLifeDays,
    this.storageConditions,
    this.origin,
    this.harvestSeason,
    this.organicCertified,
    this.isFeatured,
    this.isActive,
    this.seoTitle,
    this.seoDescription,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.searchVector,
    this.shortDescription,
    this.specifications,
    this.variants,
    this.rating,
    this.reviewCount,
    this.reviews,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'] is String ? int.tryParse(json['id']) ?? 0 : (json['id'] ?? 0),
        name: json['name'] ?? '',
        slug: json['slug'] ?? '',
        sku: json['sku'],
        categoryId: json['category_id'] is String ? int.tryParse(json['category_id']) : json['category_id'],
        unitId: json['unit_id'] is String ? int.tryParse(json['unit_id']) : json['unit_id'],
        description: json['description'],
        images: json['images'] != null ? ProductImages.fromJson(json['images']) : null,
        price: json['price'] != null ? (json['price'] is String ? double.tryParse(json['price']) ?? 0 : (json['price'] as num).toDouble()) : 0,
        comparePrice: json['compare_price'] != null ? (json['compare_price'] is String ? double.tryParse(json['compare_price']) : (json['compare_price'] as num).toDouble()) : null,
        costPrice: json['cost_price'] != null ? (json['cost_price'] is String ? double.tryParse(json['cost_price']) : (json['cost_price'] as num).toDouble()) : null,
        weight: json['weight'] != null ? (json['weight'] is String ? double.tryParse(json['weight']) : (json['weight'] as num).toDouble()) : null,
        dimensions: json['dimensions'],
        stockQuantity: json['stock_quantity'] is String ? int.tryParse(json['stock_quantity']) ?? 0 : (json['stock_quantity'] ?? 0),
        minStock: json['min_stock'],
        trackInventory: json['track_inventory'],
        isFresh: json['is_fresh'],
        shelfLifeDays: json['shelf_life_days'],
        storageConditions: json['storage_conditions'],
        origin: json['origin'],
        harvestSeason: json['harvest_season'],
        organicCertified: json['organic_certified'],
        isFeatured: json['is_featured'],
        isActive: json['is_active'],
        seoTitle: json['seo_title'],
        seoDescription: json['seo_description'],
        createdBy: json['created_by'],
        createdAt: json['created_at']?.toString(),
        updatedAt: json['updated_at']?.toString(),
        deletedAt: json['deleted_at']?.toString(),
        searchVector: json['search_vector'],
        shortDescription: json['short_description'],
        specifications: json['specifications'] is Map<String, dynamic> ? json['specifications'] : null,
        variants: json['variants'] != null ? (json['variants'] as List).map((v) => ProductVariant.fromJson(v)).toList() : null,
        rating: json['rating'] != null ? (json['rating'] is String ? double.tryParse(json['rating']) : (json['rating'] as num).toDouble()) : null,
        reviewCount: json['review_count'] is String ? int.tryParse(json['review_count']) : json['review_count'],
        reviews: json['reviews'] != null ? (json['reviews'] as List).map((r) => ProductReview.fromJson(r)).toList() : [],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'slug': slug,
        'sku': sku,
        'category_id': categoryId,
        'unit_id': unitId,
        'description': description,
        'images': images?.toJson(),
        'price': price,
        'compare_price': comparePrice,
        'cost_price': costPrice,
        'weight': weight,
        'dimensions': dimensions,
        'stock_quantity': stockQuantity,
        'min_stock': minStock,
        'track_inventory': trackInventory,
        'is_fresh': isFresh,
        'shelf_life_days': shelfLifeDays,
        'storage_conditions': storageConditions,
        'origin': origin,
        'harvest_season': harvestSeason,
        'organic_certified': organicCertified,
        'is_featured': isFeatured,
        'is_active': isActive,
        'seo_title': seoTitle,
        'seo_description': seoDescription,
        'created_by': createdBy,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'deleted_at': deletedAt,
        'search_vector': searchVector,
        'short_description': shortDescription,
        'specifications': specifications,
        'variants': variants?.map((v) => v.toJson()).toList(),
        'rating': rating,
        'review_count': reviewCount,
        'reviews': reviews?.map((r) => r.toJson()).toList(),
      };
}

/// ----------------------------
/// 🧩 MODEL: Pagination
/// ----------------------------
class PaginationMeta {
  final int currentPage;
  final int totalPages;
  final int pageSize;
  final int totalCount;
  final bool hasNext;
  final bool hasPrevious;

  PaginationMeta({
    required this.currentPage,
    required this.totalPages,
    required this.pageSize,
    required this.totalCount,
    required this.hasNext,
    required this.hasPrevious,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) => PaginationMeta(
        currentPage: json['current_page'] ?? json['currentPage'] ?? 1,
        totalPages: json['total_pages'] ?? json['totalPages'] ?? 1,
        pageSize: json['page_size'] ?? json['pageSize'] ?? 10,
        totalCount: json['total_count'] ?? json['totalItems'] ?? 0,
        hasNext: json['has_next'] ?? json['hasNext'] ?? false,
        hasPrevious: json['has_previous'] ?? json['hasPrevious'] ?? false,
      );
}

/// ----------------------------
/// 🧩 MODEL: Product List Response
/// ----------------------------
class ProductListResponse {
  final List<Product> data;
  final PaginationMeta pagination;

  ProductListResponse({required this.data, required this.pagination});

  factory ProductListResponse.fromJson(Map<String, dynamic> json) => ProductListResponse(
        data: (json['data'] as List).map((p) => Product.fromJson(p)).toList(),
        pagination: PaginationMeta.fromJson(json['pagination']),
      );
}
