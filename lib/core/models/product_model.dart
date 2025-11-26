import 'category_model.dart';

int? toInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is String) return int.tryParse(v);
  return null;
}

double? toDouble(dynamic v) {
  if (v == null) return null;
  if (v is double) return v;
  if (v is int) return v.toDouble();
  if (v is String) return double.tryParse(v);
  return null;
}

String? toStringSafe(dynamic v) {
  if (v == null) return null;
  return v.toString();
}

List<String> toStringList(dynamic v) {
  if (v == null) return [];
  if (v is List) return v.map((e) => e.toString()).toList();
  return [];
}

// ----------------------------
// 🧩 MODEL: Product Variant
// ----------------------------
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
      id: toInt(json['id']) ?? 0,
      name: toStringSafe(json['name']) ?? '',
      sku: toStringSafe(json['sku']) ?? '',
      price: toDouble(json['price']) ?? 0,
      stockQuantity: toInt(json['stock_quantity']) ?? 0,
      weight: toDouble(json['weight']),
      image: toStringSafe(json['image']),
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

// ----------------------------
// 🧩 MODEL: Product Images
// ----------------------------
class ProductImages {
  final List<String> gallery;
  final String? thumbnail;

  ProductImages({List<String>? gallery, this.thumbnail})
      : gallery = gallery ?? [];

  factory ProductImages.fromJson(Map<String, dynamic> json) => ProductImages(
        gallery: toStringList(json['gallery']),
        thumbnail: toStringSafe(json['thumbnail']),
      );

  List<String> get all =>
      [if (thumbnail != null && thumbnail!.trim().isNotEmpty) thumbnail!, ...gallery];

  Map<String, dynamic> toJson() => {
        'gallery': gallery,
        'thumbnail': thumbnail,
      };
}

// ----------------------------
// 🧩 MODEL: Product Review
// ----------------------------
class ProductReview {
  final int id;
  final int productId;
  final int customerId;
  final int? orderId;
  final double rating;
  final String? title;
  final String? content;
  final List<String>? images;
  final String status;
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
        id: toInt(json['id']) ?? 0,
        productId: toInt(json['product_id']) ?? 0,
        customerId: toInt(json['customer_id']) ?? 0,
        orderId: toInt(json['order_id']),
        rating: toDouble(json['rating']) ?? 0,
        title: toStringSafe(json['title']),
        content: toStringSafe(json['content']),
        images: toStringList(json['images']),
        status: toStringSafe(json['status']) ?? 'pending',
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

// ----------------------------
// 🧩 MODEL: Product
// ----------------------------
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
  final Category? category;
  final String? category_name;

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
    this.category,
    this.category_name,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: toInt(json['id']) ?? 0,
        name: toStringSafe(json['name']) ?? '',
        slug: toStringSafe(json['slug']) ?? '',
        sku: toStringSafe(json['sku']),
        categoryId: toInt(json['category_id']),
        unitId: toInt(json['unit_id']),
        description: toStringSafe(json['description']),
        images: json['images'] != null ? ProductImages.fromJson(json['images']) : null,
        price: toDouble(json['price']) ?? 0,
        comparePrice: toDouble(json['compare_price']),
        costPrice: toDouble(json['cost_price']),
        weight: toDouble(json['weight']),
        dimensions: toStringSafe(json['dimensions']),
        stockQuantity: toInt(json['stock_quantity']) ?? 0,
        minStock: toInt(json['min_stock']),
        trackInventory: json['track_inventory'],
        isFresh: json['is_fresh'],
        shelfLifeDays: toInt(json['shelf_life_days']),
        storageConditions: toStringSafe(json['storage_conditions']),
        origin: toStringSafe(json['origin']),
        harvestSeason: toStringSafe(json['harvest_season']),
        organicCertified: json['organic_certified'],
        isFeatured: json['is_featured'],
        isActive: json['is_active'],
        seoTitle: toStringSafe(json['seo_title']),
        seoDescription: toStringSafe(json['seo_description']),
        createdBy: toInt(json['created_by']),
        createdAt: toStringSafe(json['created_at']),
        updatedAt: toStringSafe(json['updated_at']),
        deletedAt: toStringSafe(json['deleted_at']),
        searchVector: toStringSafe(json['search_vector']),
        shortDescription: toStringSafe(json['short_description']),
        specifications: json['specifications'] is Map<String, dynamic>
            ? json['specifications']
            : null,
        variants: json['variants'] != null
            ? (json['variants'] as List).map((v) => ProductVariant.fromJson(v)).toList()
            : null,
        rating: toDouble(json['rating']),
        reviewCount: toInt(json['review_count']),
        reviews: json['reviews'] != null
            ? (json['reviews'] as List).map((r) => ProductReview.fromJson(r)).toList()
            : [],
        category: json['category'] != null ? Category.fromJson(json['category']) : null,
        category_name: json['category_name'] != null
            ? toStringSafe(json['category_name'])
            : null,
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
        'category': category?.toJson(),
        'category_name': category_name,
      };
}

// ----------------------------
// 🧩 MODEL: Pagination
// ----------------------------
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
        currentPage: toInt(json['current_page']) ?? toInt(json['currentPage']) ?? 1,
        totalPages: toInt(json['total_pages']) ?? toInt(json['totalPages']) ?? 1,
        pageSize: toInt(json['page_size']) ?? toInt(json['pageSize']) ?? 10,
        totalCount: toInt(json['total_count']) ?? toInt(json['totalItems']) ?? 0,
        hasNext: json['has_next'] ?? json['hasNext'] ?? false,
        hasPrevious: json['has_previous'] ?? json['hasPrevious'] ?? false,
      );
}

// ----------------------------
// 🧩 MODEL: Product List Response
// ----------------------------
class ProductListResponse {
  final List<Product> data;
  final PaginationMeta pagination;

  ProductListResponse({required this.data, required this.pagination});

  factory ProductListResponse.fromJson(Map<String, dynamic> json) =>
      ProductListResponse(
        data: (json['data'] as List).map((p) => Product.fromJson(p)).toList(),
        pagination: PaginationMeta.fromJson(json['pagination']),
      );
}
