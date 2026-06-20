class Brand {
  final int id;
  final String name;
  Brand({required this.id, required this.name});
  factory Brand.fromJson(Map<String, dynamic> j) => Brand(id: j['id'], name: j['name']);
}

class Category {
  final int id;
  final String name;
  Category({required this.id, required this.name});
  factory Category.fromJson(Map<String, dynamic> j) => Category(id: j['id'], name: j['name']);
}

class Review {
  final int id;
  final int rating;
  final String? comment;
  final String userName;
  final String? avatarUrl;
  final int userId;
  Review({
    required this.id,
    required this.rating,
    this.comment,
    required this.userName,
    this.avatarUrl,
    required this.userId,
  });
  factory Review.fromJson(Map<String, dynamic> j) => Review(
        id: j['id'],
        rating: j['rating'],
        comment: j['comment'],
        userId: j['user']?['id'] ?? j['userId'] ?? 0,
        userName: j['user']?['fullName'] ?? 'User',
        avatarUrl: j['user']?['avatarUrl'],
      );
}

class Product {
  final int id;
  final String title;
  final String? description;
  final double price;
  final double? salePrice;
  final int stockQty;
  final String? cpu;
  final int? ramGb;
  final int? storageGb;
  final double? screenSize;
  final double ratingAvg;
  final int ratingCount;
  final String? thumbnailUrl;
  final String? brandName;
  final String? categoryName;
  final List<String> images;
  final List<Review> reviews;

  Product({
    required this.id,
    required this.title,
    this.description,
    required this.price,
    this.salePrice,
    required this.stockQty,
    this.cpu,
    this.ramGb,
    this.storageGb,
    this.screenSize,
    required this.ratingAvg,
    required this.ratingCount,
    this.thumbnailUrl,
    this.brandName,
    this.categoryName,
    this.images = const [],
    this.reviews = const [],
  });

  bool get inStock => stockQty > 0;
  double get effectivePrice => salePrice ?? price;

  factory Product.fromJson(Map<String, dynamic> j) {
    double d(v) => v == null ? 0 : double.parse(v.toString());
    return Product(
      id: j['id'],
      title: j['title'] ?? '',
      description: j['description'],
      price: d(j['price']),
      salePrice: j['salePrice'] == null ? null : d(j['salePrice']),
      stockQty: j['stockQty'] ?? 0,
      cpu: j['cpu'],
      ramGb: j['ramGb'],
      storageGb: j['storageGb'],
      screenSize: j['screenSize'] == null ? null : d(j['screenSize']),
      ratingAvg: d(j['ratingAvg']),
      ratingCount: j['ratingCount'] ?? 0,
      thumbnailUrl: j['thumbnailUrl'],
      brandName: j['brand']?['name'],
      categoryName: j['category']?['name'],
      images: (j['images'] as List?)?.map((e) => e['imageUrl'] as String).toList() ?? [],
      reviews: (j['reviews'] as List?)?.map((e) => Review.fromJson(e)).toList() ?? [],
    );
  }
}
