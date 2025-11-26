class Category {
  final int id;
  final String name;
  final String? slug;
  final String? description;
  final String? image;

  Category({
    required this.id,
    required this.name,
    this.slug,
    this.description,
    this.image,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json['id'],
        name: json['name'],
        slug: json['slug'],
        description: json['description'],
        image: json['image'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'slug': slug,
        'description': description,
        'image': image,
      };
}

int? toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value);
  return int.tryParse(value.toString());
}

String? toStringSafe(dynamic value) {
  if (value == null) return null;
  return value.toString();
}
